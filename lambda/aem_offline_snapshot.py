# -*- coding: utf8 -*-

"""
Lambda function to manange AEM stack offline backups. It uses a SNS topic to help
orchestrate sequence of steps
"""


import os
import boto3
import logging
import json
import datetime


__author__ = 'Andy Wang (andy.wang@shinesolutions.com)'
__copyright__ = 'Shine Solutions'
__license__ = 'Apache License, Version 2.0'


# setting up logger
logger = logging.getLogger(__name__)
logger.setLevel(int(os.getenv('LOG_LEVEL', logging.INFO)))


# AWS resources
ssm = boto3.client('ssm')
ec2 = boto3.client('ec2')
s3 = boto3.client('s3')
dynamodb = boto3.client('dynamodb')


# reading in config info from either s3 or within bundle
bucket = os.getenv('S3_BUCKET')
prefix = os.getenv('S3_PREFIX')
if bucket is not None and prefix is not None:
    config_file = '/tmp/config.json'
    s3.download_file(bucket, '{}/config.json'.format(prefix), config_file)
else:
    logger.info('Unable to locate config.json in S3, searching within bundle')
    config_file = 'config.json'

with open(config_file, 'r') as f:
    content = ''.join(f.readlines()).replace('\n', '')
    logger.debug('config file: ' + content)
    config = json.loads(content)
    task_document_mapping = config['document_mapping']
    offline_snapshot_config = config['offline_snapshot']
    environment = config['environment']


class MyEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime.datetime):
            return obj.strftime('%Y-%m-%dT%H:%M:%S.000Z')

        return json.JSONEncoder.default(self, obj)


def instance_ids_by_tags(filters):
    response = ec2.describe_instances(
        Filters=filters
    )
    response2 = json.loads(json.dumps(response, cls=MyEncoder))

    instance_ids = []
    for reservation in response2['Reservations']:
        instance_ids += [instance['InstanceId'] for instance in reservation['Instances']]
    return instance_ids

ssm_common_parameters = {
    'OutputS3BucketName': offline_snapshot_config['cmd-output-bucket'],
    'OutputS3KeyPrefix': offline_snapshot_config['cmd-output-prefix'],
    'ServiceRoleArn': offline_snapshot_config['ssm-service-role-arn'],
    'NotificationConfig': {
        'NotificationArn': offline_snapshot_config['sns-topic-arn'],
        'NotificationEvents': [
            'Success'
        ],
        'NotificationType': 'Command'
    }
}


def send_ssm_cmd(cmd_details):
    print('calling ssm commands')
    parameters = ssm_common_parameters.copy()
    parameters.update(cmd_details)
    return json.loads(json.dumps(ssm.send_command(**parameters),
                      cls=MyEncoder))


def manage_aem_service(target_instances, action):
    # boto3 ssm client does not accept multiple filter for Targets
    details = {
        'InstanceIds': target_instances,
        'DocumentName': task_document_mapping['manage-service'],
        'TimeoutSeconds': 120,
        'Comment': 'Start or Stop AEM service',
        'Parameters': {
            'action': [action]
        }
    }
    return send_ssm_cmd(details)


def offline_compaction(target_instances):
    details = {
        'InstanceIds': target_instances,
        'DocumentName': task_document_mapping['offline-compaction'],
        'TimeoutSeconds': 120,
        'Comment': 'run offline compaction on author instances'
    }
    return send_ssm_cmd(details)


def offline_snapshot(target_instances):
    details = {
        'InstanceIds': target_instances,
        'DocumentName': task_document_mapping['offline-snapshot'],
        'TimeoutSeconds': 120,
        'Comment': 'run offline ebs snapshot on targeted instances'
    }
    return send_ssm_cmd(details)


def stack_health_check(stack_prefix):
    """
    Simple AEM stack health check based on the number of author-primary,
    author-standby and publisher instances.
    """

    base_filter = [{
            'Name': 'tag:StackPrefix',
            'Values': [stack_prefix]
    }, {
        'Name': 'instance-state-name',
        'Values': ['running']
    }]

    author_primary_filter = base_filter + [
        {
            'Name': 'tag:Component',
            'Values': ['author-primary']
        }
    ]

    author_primary_instances = instance_ids_by_tags(author_primary_filter)

    author_standby_filter = base_filter + [
        {
            'Name': 'tag:Component',
            'Values': ['author-standby']
        }
    ]

    author_standby_instances = instance_ids_by_tags(author_standby_filter)

    publish_filter = base_filter + [
        {
            'Name': 'tag:Component',
            'Values': ['publish']
        }
    ]

    publish_instances = instance_ids_by_tags(publish_filter)

    if (len(author_primary_instances) == 1 and
       len(author_standby_instances) == 1 and
       len(publish_instances) >= config['offline_snapshot']['min-publish-instances']):
        return {
          'author-primary': author_primary_instances[0],
          'author-standby': author_standby_instances[0],
          'publish': publish_instances[0]
        }

    if len(author_primary_instances) != 1:
        logger.error('Found {} author-primary instances. Unhealthy stack.'.format(len(author_primary_instances)))

    if len(author_standby_instances) != 1:
        logger.error('Found {} author-standby instances. Unhealthy stack.'.format(len(author_standby_instances)))

    if len(publish_instances) < config['offline_snapshot']['min-publish-instances']:
        logger.error('Found {} publish instances. Unhealthy stack.'.format(len(publish_instances)))

    return Exception('Unhealthy Stack')


def start_offline_snapshot(instance_info):
    """
    offline snapshot is a complicated process, requiring a few things happen in the
    right order. This function will kick start the process. The bulk of operations
    will happen in another lambada function.
    """

    details = {
        'InstanceIds': [instance_info['author-standby']],
        'DocumentName': task_document_mapping["manage-service"],
        'TimeoutSeconds': 120,
        'Comment': 'kicking start offline snapshot with stopping AEM service on author-standby',
        'Parameters': {
            'action': ['stop']
        }
    }

    return send_ssm_cmd(details)


def put_state_in_dynamodb(instance_info, command_id):
    """
    schema:
    key: environment(hash) + task(range)
    cmd_id: current state
    instance_ids: map containing authour-primary, author-stand and publish
                  instance ids
    ttl: one day
    """

    # ideally set TTL attribute in CF tempalte
    # dynamodb.update_time_to_live(
    #     TableName=offline_snapshot_config['dynamodb-table'],
    #     TimeToLiveSpecification={
    #         'Enabled': True,
    #         'AttributeName': 'ttl'
    #     }
    # )

    # item ttl is set to 1 day
    ttl = (datetime.datetime.now() -
           datetime.datetime.fromtimestamp(0)).total_seconds()
    ttl += datetime.timedelta(days=1).total_seconds()

    instances = {key: {'S': value} for (key, value) in instance_info.items()}

    dynamodb.put_item(
        TableName=offline_snapshot_config['dynamodb-table'],
        Item={
            'environment': {
                'S': environment
            },
            'task': {
                'S': 'offline_snapshot'
            },
            'instance_ids': {
                'M': instances
            },
            'command_state': {
                'M': {
                    command_id: {
                        'S': 'STOP_AUTHOR_STANDBY'
                    }
                }
            },
            'ttl': {
                'N': str(ttl)
            }
        }
    )


# dynamodb is used to host state information
def get_state_from_dynamodb():

    item = dynamodb.get_item(
        TableName=offline_snapshot_config['dynamodb-table'],
        Key={
            'environment': {
                'S': environment
            },
            'task': {
                'S': 'offline_snapshot'
            }
        },
        ConsistentRead=True,
        ReturnConsumedCapacity='NONE',
        ProjectionExpression='command_state, instance_ids'
    )

    return item


def update_state_in_dynamodb(command_id, current_state):

    item_update = {
        'TableName': offline_snapshot_config['dynamodb-table'],
        'Key': {
            'environment': {
                'S': environment
            },
            'task': {
                'S': 'offline_snapshot'
            }
        },
        'UpdateExpression': 'SET command_state.#cmd_id = :state',
        'ExpressionAttributeNames': {
            '#cmd_id': command_id
        },
        'ExpressionAttributeValues': {
            ':state': {
                'S': current_state
            }
        }
    }

    dynamodb.update_item(**item_update)


def delete_state_from_dynamodb():
    item_key = {
        'TableName': offline_snapshot_config['dynamodb-table'],
        'Key': {
            'environment': {
                'S': environment
            },
            'task': {
                'S': 'offline_snapshot'
            }
        }
    }
    dynamodb.delete_item(**item_key)


def sns_message_processor(event, context):

    for record in event['Records']:
        message_text = record['Sns']['Message']
        logger.debug(message_text)
        message = json.loads(message_text.replace('\'', '"'))

        # message that start offline snapshot has a task key
        response = None
        if 'task' in message and message['task'] == 'offline-snapshot':

            instance_info = stack_health_check(message['stack_prefix'])
            if instance_info is None:
                raise Exception("Unhealthy Stack")

            response = start_offline_snapshot(instance_info)
            put_state_in_dynamodb(instance_info, response['Command']['CommandId'])
            return response
        else:
            # extract important piece of information from the message
            cmd_id = message['commandId']
            item = get_state_from_dynamodb()

            state = item['Item']['command_state']['M'][cmd_id]['S']
            author_primary_id = item['Item']['instance_ids']['M']['author-primary']['S']
            author_standby_id = item['Item']['instance_ids']['M']['author-standby']['S']
            publish_id = item['Item']['instance_ids']['M']['publish']['S']

            if state == 'STOP_AUTHOR_STANDBY':
                response = manage_aem_service([author_primary_id, publish_id], 'stop')

                update_state_in_dynamodb(response['Command']['CommandId'],
                                         'STOP_AUTHOR_PRIMARY')

            elif state == 'STOP_AUTHOR_PRIMARY':
                response = offline_compaction([author_primary_id, author_standby_id])

                update_state_in_dynamodb(response['Command']['CommandId'],
                                         'OFFLINE_COMPACTION')

            elif state == 'OFFLINE_COMPACTION':
                response = offline_snapshot([author_primary_id, publish_id])

                update_state_in_dynamodb(response['Command']['CommandId'],
                                         'OFFLINE_BACKUP')

            elif state == 'OFFLINE_BACKUP':
                response = manage_aem_service([author_primary_id], 'start')

                update_state_in_dynamodb(response['Command']['CommandId'],
                                         'START_AUTHOR_PRIMARY')

            elif state == 'START_AUTHOR_PRIMARY':
                response = manage_aem_service([author_standby_id, publish_id], 'start')

                update_state_in_dynamodb(response['Command']['CommandId'],
                                         'START_AUTHOR_STANDBY')

            elif state == 'START_AUTHOR_STANDBY':
                delete_state_from_dynamodb()
                print('done')

            else:
                raise Exception('Unknown state')

            return response

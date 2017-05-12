# -*- coding: utf8 -*-

"""
Lambda function to manage AEM stack offline backups. It uses a SNS topic to help
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


def send_ssm_cmd(cmd_details):
    print('calling ssm commands')
    return json.loads(json.dumps(ssm.send_command(**cmd_details),
                      cls=MyEncoder))


def get_author_primary_ids(stack_prefix):
    filters = [
        {
            'Name': 'tag:StackPrefix',
            'Values': [stack_prefix]
        }, {
            'Name': 'instance-state-name',
            'Values': ['running']
        }, {
            'Name': 'tag:Component',
            'Values': ['author-primary']
        }
    ]

    return instance_ids_by_tags(filters)


def get_author_standby_ids(stack_prefix):
    filters = [
        {
            'Name': 'tag:StackPrefix',
            'Values': [stack_prefix]
        }, {
            'Name': 'instance-state-name',
            'Values': ['running']
        }, {
            'Name': 'tag:Component',
            'Values': ['author-standby']
        }
    ]

    return instance_ids_by_tags(filters)


def get_publish_ids(stack_prefix):
    filters = [
        {
            'Name': 'tag:StackPrefix',
            'Values': [stack_prefix]
        }, {
            'Name': 'instance-state-name',
            'Values': ['running']
        }, {
            'Name': 'tag:Component',
            'Values': ['publish']
        }
    ]

    return instance_ids_by_tags(filters)


def stack_health_check(stack_prefix, min_publish_instances):
    """
    Simple AEM stack health check based on the number of author-primary,
    author-standby and publisher instances.
    """

    author_primary_instances = get_author_primary_ids(stack_prefix)

    author_standby_instances = get_author_standby_ids(stack_prefix)

    publish_instances = get_publish_ids(stack_prefix)

    if (len(author_primary_instances) == 1 and
       len(author_standby_instances) == 1 and
       len(publish_instances) >= min_publish_instances):
        return {
          'author-primary': author_primary_instances[0],
          'author-standby': author_standby_instances[0],
          'publish': publish_instances[0]
        }

    if len(author_primary_instances) != 1:
        logger.error('Found {} author-primary instances. Unhealthy stack.'.format(len(author_primary_instances)))

    if len(author_standby_instances) != 1:
        logger.error('Found {} author-standby instances. Unhealthy stack.'.format(len(author_standby_instances)))

    if len(publish_instances) < min_publish_instances:
        logger.error('Found {} publish instances. Unhealthy stack.'.format(len(publish_instances)))

    return Exception('Unhealthy Stack')


def put_state_in_dynamodb(table_name, command_id, environment, state, instance_info):
    """
    schema:
    key: command_id
    attr:
      environment: S usually stack_prefix
      command_state: S
      instance_info:  M instance role : instance id
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

    item = {
        'command_id': {
            'S': command_id
        },
        'environment': {
            'S': environment
        },
        'state': {
            'S': state
        },
        'instance_info': {
            'M': instance_info
        },
        'ttl': {
            'N': str(ttl)
        }
    }

    dynamodb.put_item(
        TableName=table_name,
        Item=item
    )


# dynamodb is used to host state information
def get_state_from_dynamodb(table_name, command_id):

    item = dynamodb.get_item(
        TableName=table_name,
        Key={
            'command_id': {
                'S': command_id
            }
        },
        ConsistentRead=True,
        ReturnConsumedCapacity='NONE',
        ProjectionExpression='environment, state, instance_info'
    )

    return item


def sns_message_processor(event, context):
    """
    offline snapshot is a complicated process, requiring a few things happen in the
    right order. This function will kick start the process. The bulk of operations
    will happen in another lambada function.
    """

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
        dynamodb_table = config['offline_snapshot']['dynamodb-table']


    ssm_common_params = {
        'TimeoutSeconds': 120,
        'OutputS3BucketName': offline_snapshot_config['cmd-output-bucket'],
        'OutputS3KeyPrefix': offline_snapshot_config['cmd-output-prefix'],
        'ServiceRoleArn': offline_snapshot_config['ssm-service-role-arn'],
        'NotificationConfig': {
            'NotificationArn': offline_snapshot_config['sns-topic-arn'],
            'NotificationEvents': [
                'Success',
                'Failed'
            ],
            'NotificationType': 'Command'
        }
    }

    for record in event['Records']:
        message_text = record['Sns']['Message']
        logger.debug(message_text)
        message = json.loads(message_text.replace('\'', '"'))

        # message that start offline snapshot has a task key
        response = None
        if 'task' in message and message['task'] == 'offline-snapshot':

            stack_prefix = message['stack_prefix']
            instances = stack_health_check(
                stack_prefix,
                config['offline_snapshot']['min-publish-instances']
            )
            if instances is None:
                raise Exception('Unhealthy Stack')

            ssm_params = ssm_common_params.copy()
            ssm_params.update(
                {
                    'InstanceIds': [instances['author-standby']],
                    'DocumentName': task_document_mapping['manage-service'],
                    'Comment': 'Kick start offline snapshot with stopping AEM service on Author standby instance',
                    'Parameters': {
                        'action': ['stop']
                    }
                }
            )

            response = send_ssm_cmd(ssm_params)

            instance_info = {key: {'S': value} for (key, value) in instances.items()}
            put_state_in_dynamodb(
                dynamodb_table,
                response['Command']['CommandId'],
                stack_prefix,
                'STOP_AUTHOR_STANDBY',
                instance_info
            )
            return response
        else:
            cmd_id = message['commandId']

            if message['status'] == 'Failed':
                raise Exception('Command {} failed.'.format(cmd_id))

            # get back the state of this task
            item = get_state_from_dynamodb(
                dynamodb_table,
                cmd_id
            )
            state = item['Item']['state']['S']
            stack_prefix = item['Item']['environment']['S']
            instance_info = item['Item']['instance_info']

            author_primary_id = instance_info['M']['author-primary']['S']
            author_standby_id = instance_info['M']['author-standby']['S']
            publish_id = instance_info['M']['publish']['S']

            if state == 'STOP_AUTHOR_STANDBY':
                ssm_params = ssm_common_params.copy()
                ssm_params.update(
                    {
                        'InstanceIds': [author_primary_id, publish_id],
                        'DocumentName': task_document_mapping['manage-service'],
                        'Comment': 'Stop AEM service on Author primary and Publish instances',
                        'Parameters': {
                            'action': ['stop']
                        }
                    }
                )

                response = send_ssm_cmd(ssm_params)
                put_state_in_dynamodb(
                    dynamodb_table,
                    response['Command']['CommandId'],
                    stack_prefix,
                    'STOP_AUTHOR_PRIMARY',
                    instance_info
                )

            elif state == 'STOP_AUTHOR_PRIMARY':
                ssm_params = ssm_common_params.copy()
                ssm_params.update(
                    {
                        'InstanceIds': [author_primary_id, author_standby_id],
                        'DocumentName': task_document_mapping['offline-compaction'],
                        'Comment': 'Run offline compaction on Author primary and standby instances'
                    }
                )

                response = send_ssm_cmd(ssm_params)
                put_state_in_dynamodb(
                    dynamodb_table,
                    response['Command']['CommandId'],
                    stack_prefix,
                    'OFFLINE_COMPACTION',
                    instance_info
                )

            elif state == 'OFFLINE_COMPACTION':
                ssm_params = ssm_common_params.copy()
                ssm_params.update(
                    {
                        'InstanceIds': [author_primary_id, publish_id],
                        'DocumentName': task_document_mapping['offline-snapshot'],
                        'Comment': 'Run offline EBS snapshot on Author primary and Publish instances'
                    }
                )

                response = send_ssm_cmd(ssm_params)
                put_state_in_dynamodb(
                    dynamodb_table,
                    response['Command']['CommandId'],
                    stack_prefix,
                    'OFFLINE_BACKUP',
                    instance_info
                )

            elif state == 'OFFLINE_BACKUP':
                ssm_params = ssm_common_params.copy()
                ssm_params.update(
                    {
                        'InstanceIds': [author_primary_id],
                        'DocumentName': task_document_mapping['manage-service'],
                        'Comment': 'Start AEM service on Author primary instance',
                        'Parameters': {
                            'action': ['start']
                        }
                    }
                )

                response = send_ssm_cmd(ssm_params)
                put_state_in_dynamodb(
                    dynamodb_table,
                    response['Command']['CommandId'],
                    stack_prefix,
                    'START_AUTHOR_PRIMARY',
                    instance_info
                )

            elif state == 'START_AUTHOR_PRIMARY':
                ssm_params = ssm_common_params.copy()
                ssm_params.update(
                    {
                        'InstanceIds': [author_standby_id, publish_id],
                        'DocumentName': task_document_mapping['manage-service'],
                        'Comment': 'Start AEM service on Author standby and Publish instances',
                        'Parameters': {
                            'action': ['start']
                        }
                    }
                )
                response = send_ssm_cmd(ssm_params)
                put_state_in_dynamodb(
                    dynamodb_table,
                    response['Command']['CommandId'],
                    stack_prefix,
                    'START_AUTHOR_STANDBY',
                    instance_info
                )

            elif state == 'START_AUTHOR_STANDBY':
                print('Offline backup for environment {} finished successfully'.format(stack_prefix))

            else:
                raise Exception('Unknown state')

            return response

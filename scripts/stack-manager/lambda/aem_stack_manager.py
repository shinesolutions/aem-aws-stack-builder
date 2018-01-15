# -*- coding: utf8 -*-

"""
Lambda function to manage AEM Stack resources.
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
    return json.loads(json.dumps(ssm.send_command(**cmd_details), cls=MyEncoder))


def deploy_artifact(message, ssm_common_params):
    target_filter = [
        {
            'Name': 'tag:StackPrefix',
            'Values': [message['stack_prefix']]
        }, {
            'Name': 'instance-state-name',
            'Values': ['running']
        }, {
            'Name': 'tag:Component',
            'Values': [message['details']['component']]
        }
    ]
    # boto3 ssm client does not accept multiple filter for Targets
    details = {
        'InstanceIds': instance_ids_by_tags(target_filter),
        'Comment': 'deploy an AEM artifact',
        'Parameters': {
            'source': [message['details']['source']],
            'group': [message['details']['group']],
            'name': [message['details']['name']],
            'version': [message['details']['version']],
            'replicate': [message['details']['replicate']],
            'activate': [message['details']['activate']],
            'force': [message['details']['force']]

        }
    }
    params = ssm_common_params.copy()
    params.update(details)
    return send_ssm_cmd(params)


def deploy_artifacts(message, ssm_common_params):
    target_filter = [
        {
            'Name': 'tag:StackPrefix',
            'Values': [message['stack_prefix']]
        }, {
            'Name': 'instance-state-name',
            'Values': ['running']
        }, {
            'Name': 'tag:Component',
            'Values': ['author-primary',
                       'author-standby',
                       'publish',
                       'author-dispatcher',
                       'publish-dispatcher'
                       ]
        }
    ]
    # boto3 ssm client does not accept multiple filter for Targets
    details = {
        'InstanceIds': instance_ids_by_tags(target_filter),
        'Comment': 'deploying artifacts based on a descriptor file',
        'Parameters': {
            'descriptorFile': [message['details']['descriptor_file']]
        }
    }
    params = ssm_common_params.copy()
    params.update(details)
    return send_ssm_cmd(params)


def export_package(message, ssm_common_params):
    target_filter = [
        {
            'Name': 'tag:StackPrefix',
            'Values': [message['stack_prefix']]
        }, {
            'Name': 'instance-state-name',
            'Values': ['running']
        }, {
            'Name': 'tag:Component',
            'Values': [message['details']['component']]
        }
    ]

    encoded = json.dumps(message['details']['package_filter'])
    logger.debug('encoded filter: {}'.format(encoded))
    logger.debug('escaped filter: {}'.format(json.dumps(encoded)))

    # boto3 ssm client does not accept multiple filter for Targets
    details = {
        'InstanceIds': instance_ids_by_tags(target_filter),
        'Comment': 'exporting AEM pacakges as backup based on package group, name and filter',
        'Parameters': {
            'packageGroup': [message['details']['package_group']],
            'packageName': [message['details']['package_name']],
            'packageFilter': [json.dumps(encoded)]
        }
    }
    params = ssm_common_params.copy()
    params.update(details)
    return send_ssm_cmd(params)


def import_package(message, ssm_common_params):
    target_filter = [
        {
            'Name': 'tag:StackPrefix',
            'Values': [message['stack_prefix']]
        }, {
            'Name': 'instance-state-name',
            'Values': ['running']
        }, {
            'Name': 'tag:Component',
            'Values': [message['details']['component']]
        }
    ]
    # boto3 ssm client does not accept multiple filter for Targets
    details = {
        'InstanceIds': instance_ids_by_tags(target_filter),
        'Comment': 'import AEM backed up pacakges for a stack based on group, name and timestamp',
        'Parameters': {
            'sourceStackPrefix': [message['details']['source_stack_prefix']],
            'packageGroup': [message['details']['package_group']],
            'packageName': [message['details']['package_name']],
            'packageDatestamp': [message['details']['package_datestamp']]
        }
    }
    params = ssm_common_params.copy()
    params.update(details)
    return send_ssm_cmd(params)


def promote_author(message, ssm_common_params):
    target_filter = [
        {
            'Name': 'tag:StackPrefix',
            'Values': [message['stack_prefix']]
        }, {
            'Name': 'instance-state-name',
            'Values': ['running']
        }, {
            'Name': 'tag:Component',
            'Values': ['author-standby']
        }
    ]
    # boto3 ssm client does not accept multiple filter for Targets
    details = {
        'InstanceIds': instance_ids_by_tags(target_filter),
        'Comment': 'promote standby author instance to be the primary'
    }
    params = ssm_common_params.copy()
    params.update(details)
    return send_ssm_cmd(params)


def enable_crxde(message, ssm_common_params):
    target_filter = [
        {
            'Name': 'tag:StackPrefix',
            'Values': [message['stack_prefix']]
        }, {
            'Name': 'instance-state-name',
            'Values': ['running']
        }, {
            'Name': 'tag:Component',
            'Values': [message['details']['component']]
        }
    ]
    # boto3 ssm client does not accept multiple filter for Targets
    details = {
        'InstanceIds': instance_ids_by_tags(target_filter),
        'Comment': 'enable crxde on selected AEM instances by component'
    }
    params = ssm_common_params.copy()
    params.update(details)
    return send_ssm_cmd(params)


def run_adhoc_puppet(message, ssm_common_params):
    target_filter = [
        {
            'Name': 'tag:StackPrefix',
            'Values': [message['stack_prefix']]
        }, {
            'Name': 'instance-state-name',
            'Values': ['running']
        }, {
            'Name': 'tag:Component',
            'Values': [message['details']['component']]
        }
    ]
    # boto3 ssm client does not accept multiple filter for Targets
    details = {
        'InstanceIds': instance_ids_by_tags(target_filter),
        'Comment': 'Run adhoc puppet code on selected instances',
        'Parameters': {
            'adhocPuppetFile': [message['details']['puppet_tar_file']]
        }
    }
    params = ssm_common_params.copy()
    params.update(details)
    return send_ssm_cmd(params)


def put_state_in_dynamodb(table_name, command_id, environment, task, state, timestamp, **kwargs):

    """
    schema:
    key: command_id, ec2 run command id, or externalId if provided and no cmd
         has ran yet
    attr:
      environment: S usually stack_prefix
      state: S STOP_AUTHOR_STANDBY, STOP_AUTHOR_PRIMARY, .... Succeeded, Failed
      timestamp: S, example: 2017-05-16T01:57:05.9Z
      ttl: one day
    Optional attr:
      instance_info: M, exmaple: author-primary: i-13ad9rxxxx
      last_command:  S, Last EC2 Run Command Id that trigggers this command,
                     used more for debugging
      externalId: S, provided by external parties, like Jenkins/Bamboo job id
    """

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
        'task': {
            'S': task
        },
        'state': {
            'S': state
        },
        'timestamp': {
            'S': timestamp
        },
        'ttl': {
            'N': str(ttl)
        }
    }

    if 'InstanceInfo' in kwargs and kwargs['InstanceInfo'] is not None:
        item['instance_info'] = {'M': kwargs['InstanceInfo']}

    if 'LastCommand' in kwargs and kwargs['LastCommand'] is not None:
        item['last_command'] = {'S': kwargs['LastCommand']}

    if 'ExternalId' in kwargs and kwargs['ExternalId'] is not None:
        item['externalId'] = {'S': kwargs['ExternalId']}

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
        ProjectionExpression='environment, task, #command_state, instance_info, externalId',
        ExpressionAttributeNames={
            '#command_state': 'state'
        }
    )

    return item


def update_state_in_dynamodb(table_name, command_id, new_state, timestamp):

    item_update = {
        'TableName': table_name,
        'Key': {
            'command_id': {
                'S': command_id
            }
        },
        'UpdateExpression': 'SET #S = :sval, #T = :tval',
        'ExpressionAttributeNames': {
            '#S': 'state',
            '#T': 'timestamp'
        },
        'ExpressionAttributeValues': {
            ':sval': {
                'S': new_state
            },
            ':tval': {
                'S': timestamp
            }
        }
    }

    dynamodb.update_item(**item_update)


method_mapper = {
    'deploy-artifact': deploy_artifact,
    'deploy-artifacts': deploy_artifacts,
    'export-package': export_package,
    'import-package': import_package,
    'promote-author': promote_author,
    'enable-crxde': enable_crxde,
    'run-adhoc-puppet': run_adhoc_puppet
}


def sns_message_processor(event, context):

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
        run_command = config['ec2_run_command']

        dynamodb_table = run_command['dynamodb-table']

    responses=[]
    for record in event['Records']:
        message_text = record['Sns']['Message']
        logger.debug(message_text)

        # we could receive message from Stack Manager Topic, which trigger actions
        # and Status Topic, which tells us how the command ends
        message = json.loads(message_text.replace('\'', '"'))

        if 'task' in message and message['task'] is not None:
            method = method_mapper[message['task']]
            stack_prefix = message['stack_prefix']

            external_id = None
            if 'externalId' in message:
                external_id = message['externalId']

            logger.info('Received request for task {}'.format(method.func_name))
            ssm_common_params = {
                'TimeoutSeconds': 120,
                'DocumentName': task_document_mapping[message['task']],
                'OutputS3BucketName': run_command['cmd-output-bucket'],
                'OutputS3KeyPrefix': run_command['cmd-output-prefix'],
                'ServiceRoleArn': run_command['ssm-service-role-arn'],
                'NotificationConfig': {
                    'NotificationArn': run_command['status-topic-arn'],
                    'NotificationEvents': [
                        'Success',
                        'Failed'
                    ],
                    'NotificationType': 'Command'
                }
            }

            respone = method(message, ssm_common_params)
            put_state_in_dynamodb(
                dynamodb_table,
                respone['Command']['CommandId'],
                stack_prefix,
                message['task'],
                respone['Command']['Status'],
                respone['Command']['RequestedDateTime'],
                ExternalId=external_id
            )

            responses.append(respone)

        elif 'commandId' in message:
            cmd_id = message['commandId']
            update_state_in_dynamodb(
                dynamodb_table,
                cmd_id,
                message['status'],
                message['eventTime']
            )

            response = {
                'status': message['status']
            }
            responses.append(response)

        else:
            logger.error('Unknown message found  and ignored')

    return responses

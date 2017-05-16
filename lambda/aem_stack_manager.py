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
    # boto3 ssm client does not accept multiple filter for Targets
    details = {
        'InstanceIds': instance_ids_by_tags(target_filter),
        'Comment': 'exporting AEM pacakges as backup based on package group, name and filter',
        'Parameters': {
            'packageGroup': [message['details']['package_group']],
            'packageName': [message['details']['package_name']],
            'packageFilter': [message['details']['package_filter']]
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
            'sourceStackPrefix': [message['stack_prefix']],
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


method_mapper = {
    'deploy-artifact': deploy_artifact,
    'deploy-artifacts': deploy_artifacts,
    'export-package': export_package,
    'import-package': import_package,
    'promote-author': promote_author
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

    for record in event['Records']:
        message_text = record['Sns']['Message']
        logger.debug(message_text)
        message = json.loads(message_text.replace('\'', '"'))
        method = method_mapper.get(message['task'])

        if method is not None:
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

            return method(message, ssm_common_params)
        else:
            logger.error('Unknown task {} found on request {}'.format(
                message['task'],
                context['aws_request_id']))

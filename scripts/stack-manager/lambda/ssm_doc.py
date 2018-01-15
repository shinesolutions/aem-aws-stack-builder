# -*- coding: utf8 -*-

"""
Output a task to document name mapping for use with AEM stack manager messenger
"""

import boto3
import json
import os
import sys
from botocore.vendored import requests
import logging

__author__ = 'Michael Bloch (michael.bloch@shinesolutions.com)'
__copyright__ = 'Shine Solutions'
__license__ = 'Apache License, Version 2.0'

# Get environment variables
s3_bucket = os.getenv('S3_BUCKET')
s3_prefix = os.getenv('S3_PREFIX')
stack_prefix = os.getenv('STACK_PREFIX')
stack_name = os.getenv('STACK_NAME')
statustopicarn = os.getenv( 'TASK_STATUS_TOPIC_ARN')
ssmservicerolearn = os.getenv('SSM_SERVICE_ROLE_ARN')
cmdoutputbucket = os.getenv('S3_BUCKET')
backuparn = os.getenv('OFFLINE_BACKUP_TOPIC_ARN')
dynamodbtable = os.getenv('DYNAMO_DB_STACK_MANAGER_TABLE')

# Set variables
tmp_file = '/tmp/templist.json'

# Logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# AWS resources
s3_client = boto3.resource('s3')
cloudformation_client = boto3.resource('cloudformation')
s3_bucket = s3_client.Bucket(s3_bucket) 

# Dict ec2 run commands
ec2_run_command = {
    "ec2_run_command": {\
    "cmd-output-bucket": cmdoutputbucket,\
    "cmd-output-prefix": "SSMOutput",\
    "status-topic-arn": statustopicarn,\
    "ssm-service-role-arn": ssmservicerolearn,\
    "dynamodb-table": dynamodbtable\
    }}

# Dict Messenger -> Task Mapping
messenger_task_mapping = {
    "DeployArtifacts": "deploy-artifacts",
    "ManageService": "manage-service",
    "OfflineSnapshot": "offline-snapshot",
    "ExportPackage": "export-package",
    "DeployArtifact": "deploy-artifact",
    "OfflineCompaction": "offline-compaction",
    "PromoteAuthor": "promote-author",
    "ImportPackage": "import-package",
    'WaitUntilReady': "wait-until-ready",
    "EnableCrxde": "enable-crxde",
    "RunAdhocPuppet": "run-adhoc-puppet",
    "SSMStackName" : "StackName"
    }

# Dict Offline Snapshots
offline_snapshot = bar2 ={"offline_snapshot": {
            "min-publish-instances": 2,\
            "sns-topic-arn": backuparn
    }}

def logging_handler(log_text):
    logger.info('got event{}'.format(log_text))
    return 'Logging!'  

def aws_cf(stack_name):
    try:
        stack_outputs = cloudformation_client.Stack(stack_name).outputs
        return stack_outputs
    except Exception, e:
        responses = 'Error: Could not read Stack Description'
        status = "FAILED"
        send_cf_response(event, responseCode, PhyResId)
        return responses
    
def messenger_mapping_list(stack_outputs):
    messenger_config_list = {
        messenger_task_mapping[output['OutputKey']]: output['OutputValue']
        for output in stack_outputs
    }
    messenger_dict = dict()
    messenger_dict['document_mapping'] = messenger_config_list
    return messenger_dict

def save_dict(tmp_file, messenger_dict):
    # Update ec2_run_command dict
    ec2_run_command.update(messenger_dict)
    ec2_run_command.update(offline_snapshot)
    
    try:
        with open(tmp_file, 'w') as file:
            json.dump( ec2_run_command, file, indent=2)
    except Exception, e:
        responses = 'Error: Could not create json config'
        responseCode = "FAILED"
        send_cf_response(event, responseCode, PhyResId)
        return responses

def s3_upload(tmp_file, stack_prefix):
    config_path = 'stack-manager/lambda/config.json'
    upload_path = stack_prefix + '/' + config_path
    s3_bucket.upload_file(tmp_file, upload_path)

def script_clean():
    os.remove(tmp_file)

def send_cf_response(event, responseCode, PhyResId):
    responseUrl = event['ResponseURL']

    cf_response = {}
    cf_response['Status'] = responseCode
    cf_response['PhysicalResourceId'] = PhyResId
    cf_response['StackId'] = event['StackId']
    cf_response['RequestId'] = event['RequestId']
    cf_response['LogicalResourceId'] = event['LogicalResourceId']

    json_cf_response = json.dumps(cf_response)

    print "Response body:\n" + json_cf_response
    logging_handler(event['RequestType'])

    headers = {
        'content-type' : '',
        'content-length' : str(len(json_cf_response))
    }

    try:
        response = requests.put(responseUrl,
                                data=json_cf_response,
                                headers=headers)
    except Exception as e:
        print "Error: during sending notification to CloudFormations" + str(e)


def lambda_handler(event, context):
    # Actually execution
    PhyResId = context.log_stream_name


    if event['RequestType'] == "Delete":
        responseCode = "SUCCESS"
        send_cf_response(event, responseCode, PhyResId)
        
    elif event['RequestType'] == "Update":
        responseCode = "SUCCESS"
        send_cf_response(event, responseCode, PhyResId)

    elif event['RequestType'] == "Create":
        stack_outputs = aws_cf(stack_name)
        messenger_dict = messenger_mapping_list(stack_outputs)
        
        save_dict(tmp_file, messenger_dict)
        try:
            s3_upload(tmp_file, stack_prefix)
            script_clean()
            responseCode = "SUCCESS"
            send_cf_response(event, responseCode, PhyResId)
            responses = ec2_run_command
            return responses
        except:
            responses = 'Error: Could not upload config.json'
            responseCode = "FAILED"
            send_cf_response(event, responseCode, PhyResId)
            return responses
    else:
        responseCode = "FAILED"
        send_cf_response(event, responseCode, PhyResId)

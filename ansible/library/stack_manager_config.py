#!/usr/bin/python
# -*- coding: utf8 -*-

ANSIBLE_METADATA = {'metadata_version': '1.1'}
DOCUMENTATION = '''
---
module: stack_manager_config
Ansible module for creating AEM Stack Manager Lambda configuration file
requirements:
  - boto3 >= 1.0.0
  - python >= 2.6
options: 
    AEM_stack_name:
        description:
          - The name of the AEM Stack
        required: true
    SSM_stack_name:
        description:
          - The Stack name of the SSM Document Stack
        required: true
    S3Bucket:
        description:
          - S3 Bucket to store the configuration file
        required: true
    S3Folder:
        description:
          - S3 Folder to store the configuration file
        required: true
    TaskStatusTopicArn:
        description:
          - ARN of the SNS Topic for to query for the TaskStatus
        required: true
    SSMServiceRoleArn:
        description:
          - ARN of the SSM Service Role
        required: true
    S3BucketSSMOutput:
        description:
          - S3 Bucket to to sore the command output
        required: true
    S3PrefixSSMOutput:
        description:
          - S3 folder to store the command output
        required: true
    BackupTopicArn:
        description:
          - SNS Topic ARN of the Offline Snapshot
        required: true
    DynamoDBTableName:
        description:
          - The name of the Dynamo DB Table where Lambda stores the command status
        required: true
    state:
        description:
          - Parameter to create or delete the configuration file in the S3 Folder
        required: true

'''

EXAMPLES = '''
- name: Create Stack Manager configuration
  stack_manager_config:
    AEM_stack_name: AEM63-Full-Set
    SSM_stack_name: "AEM63-Full-Set-aem-stack-manager-ssm"
    S3Bucket: "AEM-Bucket"
    S3Folder: "AEM63/StackManager"
    TaskStatusTopicArn: arn:aws:sns:region:account-id:TaskStatusTopicArn
    SSMServiceRoleArn: arn:aws:iam::account-id:role/role-name
    S3BucketSSMOutput: "AEM-Bucket"
    S3PrefixSSMOutput: "AEM63/StackManager/SSMOutput"
    BackupTopicArn: "arn:aws:sns:region:account-id:BackupTopicArn"
    DynamoDBTableName: "AEM63-Full-Set-Stack-Manager-Table"
    state: present
  register: result
'''

import os
import sys
import tempfile
from ansible.module_utils.basic import *
from ansible.module_utils.ec2 import *

try:
    import boto3
    HAS_BOTO = True
except ImportError:
    HAS_BOTO = False

try:
    import json
    HAS_JSON = True
except ImportError:
    HAS_JSON = False

class config:
    def __init__(self, module):
        self.module = module

    def s3_upload(self, argument_spec, s3_connection, tmp_file):
        s3bucket = self.module.params.get("S3Bucket")
        s3folder = self.module.params.get("S3Folder")
        config_file = 'config.json'

        try:
            upload_path = s3folder  + '/' + config_file
            s3_bucket_connection = s3_connection.Bucket(s3bucket)
            s3_bucket_connection.upload_file(tmp_file, upload_path)
        except Exception as e:
            self.module.fail_json(msg="Error: Can't upload configuration file - " + str(e), exception=traceback.format_exc(e))

    def describe_ssmdocument_stack(self, cf_connection, stack_name, ssm_stack_name):
        try:
            stack_outputs = cf_connection.Stack(stack_name + '-' + ssm_stack_name).outputs
            if stack_outputs:
                return stack_outputs
            self.module.fail_json(msg="Error: Can not getting stack output")
        except Exception as e:
            self.module.fail_json(msg="Error: Can not establish connection - " + str(e), exception=traceback.format_exc(e))

    def create(self, argument_spec, stack_outputs, s3_connection):
        stack_name = self.module.params.get("AEM_stack_name")
        taskstatustopicarn = self.module.params.get("TaskStatusTopicArn")
        ssmservicerolearn = self.module.params.get("SSMServiceRoleArn")
        s3bucketssmoutput = self.module.params.get("S3BucketSSMOutput")
        s3prefixssmoutput = self.module.params.get("S3PrefixSSMOutput")
        backuptopicarn = self.module.params.get("BackupTopicArn")
        dynamodbtablename = self.module.params.get("DynamoDBTableName")
        changed = False

        # Create dict for run_cmd
        ec2_run_command = {
            "ec2_run_command": {\
                    "cmd-output-bucket": s3bucketssmoutput,\
                    "cmd-output-prefix": s3prefixssmoutput,\
                    "status-topic-arn": taskstatustopicarn,\
                    "ssm-service-role-arn": taskstatustopicarn,\
                    "dynamodbtablename": dynamodbtablename\
                    }}
            
        # Create dict for task mapping
        
        messenger_task_mapping = {
            "DeployArtifacts": "deploy-artifacts",
            "ManageService": "manage-service",
            "OfflineSnapshot": "offline-snapshot",
            "ExportPackage": "export-package",
            "ExportPackages": "export-packages",
            "DeployArtifact": "deploy-artifact",
            "OfflineCompaction": "offline-compaction",
            "PromoteAuthor": "promote-author",
            "ImportPackage": "import-package",
            'WaitUntilReady': "wait-until-ready",
            "EnableCrxde": "enable-crxde",
            "RunAdhocPuppet": "run-adhoc-puppet",
            "LiveSnapshot": "live-snapshot",
            "DisableCrxde": "disable-crxde",
            }
        
        messenger_config_list = {
                messenger_task_mapping[output['OutputKey']]: output['OutputValue']
                for output in stack_outputs
                }
    
        messenger_dict = dict()
        messenger_dict['document_mapping'] = messenger_config_list
        
        # Create dict for offline snapshot
        offline_snapshot ={
                "offline_snapshot": {
                    "min-publish-instances": 2,\
                            "sns-topic-arn": backuptopicarn
                }
        }

        try:
            # Create config dict
            ec2_run_command.update(messenger_dict)
            ec2_run_command.update(offline_snapshot)
            # Create temp configuration
            with tempfile.NamedTemporaryFile() as tmp_file:
                with open(tmp_file.name, 'w') as file:
                    json.dump( ec2_run_command, file, indent=2)
                config.s3_upload(self, argument_spec, s3_connection, tmp_file.name)

            result = ec2_run_command
            changed = True
        except Exception, e:
            self.module.fail_json(msg="Error: Could not create JSON Configfile - " + str(e))

        self.module.exit_json(changed=changed, stack_manager_config=result)

def main():
    argument_spec = ec2_argument_spec()
    argument_spec.update(dict(
            AEM_stack_name=dict(required=True, type='str' ),
            SSM_stack_name=dict(required=True, type='str'),
            S3Bucket=dict(required=True, type='str'),
            S3Folder=dict(required=True, type='str'),
            TaskStatusTopicArn=dict(required=True, type='str'),
            SSMServiceRoleArn=dict(required=True, type='str'),
            S3BucketSSMOutput=dict(required=True, type='str'),
            S3PrefixSSMOutput=dict(required=True, type='str'),
            BackupTopicArn=dict(required=True, type='str'),
            DynamoDBTableName=dict(required=True, type='str'),
            state=dict(default='present', choices=['present', 'absent'], type='str'),
    ))
    module = AnsibleModule(argument_spec=argument_spec)

    if not HAS_BOTO:
        module.fail_json(msg='boto required for this module')

    if not HAS_JSON:
        module.fail_json(msg='json required for this module')

    region, ec2_url, aws_connect_params = get_aws_connection_info(module, boto3=True)

    if region:
        try:
            cf_connection = boto3_conn(module, conn_type='resource',
                    resource='cloudformation', region=region,
                    endpoint=ec2_url, **aws_connect_params)
            s3_connection = boto3_conn(module, conn_type='resource',
                    resource='s3', region=region,
                    endpoint=ec2_url, **aws_connect_params)
        except (AnsibleAWSError) as e:
            module.fail_json(msg=str(e))
    else:
        module.fail_json(msg="Error: region must be specified")

    #tmp_file = '../../stage/templist.json'
    state = module.params.get("state")
    stack_name = module.params.get("AEM_stack_name")
    ssm_stack_name = module.params.get("SSM_stack_name")

    if state == 'present':
        stack_manager_config = config(module)
        
        stack_outputs = stack_manager_config.describe_ssmdocument_stack(cf_connection, stack_name, ssm_stack_name)

        stack_manager_config.create(argument_spec, stack_outputs, s3_connection)

    elif state == 'absent':
        module.exit_json(changed=changed)

if __name__ == '__main__':  
    main()

# -*- coding: utf8 -*-

"""
Output a task to document name mapping for use with AEM stack manager messenger
"""

import sys
import boto3
import json

__author__ = 'Andy Wang (andy.wang@shinesolutions.com)'
__copyright__ = 'Shine Solutions'
__license__ = 'Apache License, Version 2.0'


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('Error, Usage: {} stack_prefix stack_name output_file'.format(sys.argv[0]) )
        exit(1)
    
    stack_prefix = sys.argv[1]
    stack_name = sys.argv[2]
    output_file = sys.argv[3]

    stack_outputs = boto3.resource('cloudformation').Stack(stack_prefix + '-' + stack_name).outputs

    # for use with stack manager messenger, value is the task name in messenger
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
      "RunAdhocPuppet": "run-adhoc-puppet"
    }

    messenger_config = {
        messenger_task_mapping[output['OutputKey']]: output['OutputValue']
        for output in stack_outputs
    }

    with open(output_file, 'w') as f:
        json.dump( messenger_config, f, indent=2)

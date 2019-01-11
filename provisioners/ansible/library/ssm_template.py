#!/usr/bin/python
# -*- coding: utf8 -*-

ANSIBLE_METADATA = {'metadata_version': '1.1'}
DOCUMENTATION = '''
---
module: ssm_template
Ansible module for creating AEM Stack Manager Lambda configuration file
requirements:
  - boto3 >= 1.0.0
  - python >= 2.6
options:

    dest_file:
        description:
          - Save file to.
    ssm_command_cf_template:
        description:
          - SSM template.
        required: true
    ssm_commands_dir_cf_template:
        description:
          - Directory containing all SSM Document templates
        required: true
'''

EXAMPLES = '''
- name: Create SSM Document cloudformation tempalte
  ssm_template:
    dest_file: "{{ playbook_dir }}/../../../../stage/ssm_template.json"
    ssm_command_cf_template: "{{ playbook_dir }}/../../../../../templates/cloudformation/apps/aem-stack-manager/ssm-commands-cloudformation.yaml"
    ssm_commands_dir_cf_template: "{{ playbook_dir }}/../../../../../templates/cloudformation/apps/aem-stack-manager/ssm-commands/"
'''

import os
import sys
import tempfile
from ansible.module_utils.basic import *
from ansible.module_utils.ec2 import *

try:
    import json
except ImportError:
    module.fail_json(msg='Python library json required for this module')

try:
    import yaml
except ImportError:
    module.fail_json(msg='Python library yaml required for this module')

class CFFunctionYAMLObject(yaml.YAMLObject):

    @classmethod
    def from_yaml(cls, loader, node):
        if node.tag == u'!Ref':
            key = u'Ref'
        else:
            key = node.tag.replace('!', 'Fn::')

        val = node.value
        return {key: val}

    @classmethod
    def to_yaml(cls, dumper, data):
        return data

class CFSub(CFFunctionYAMLObject):
    yaml_tag = u'!Sub'

class CFRef(CFFunctionYAMLObject):
    yaml_tag = u'!Ref'

class CFJoin(CFFunctionYAMLObject):
    yaml_tag = u'!Join'

class CreateSSMCFTemplate:
    def __init__(self, module):
        self.module = module

    def create(self):
        cf_template = self._read_ssm_cf_template()

        for ssm_command in cf_template['Resources']:
            cf_template_content = self._read_ssm_command_cf_template(ssm_command)
            del cf_template['Parameters'][ssm_command + "IncludeFileParameter"]
            del cf_template['Resources'][ssm_command]['Properties']['Content']['Fn::Transform']
            cf_template['Resources'][ssm_command]['Properties']['Content'].update(cf_template_content)

        result = yaml.safe_dump(cf_template, default_flow_style=False)

        return result

    def _read_ssm_cf_template(self):
        cf_template_file = self.module.params.get("ssm_command_cf_template")

        try:
            with open(cf_template_file, 'r') as ymlfile:
                cf_template = yaml.load(ymlfile)

                return cf_template
        except Exception as e:
            self.module.fail_json(msg="Error: Can't open file" + cf_template_file + " - " + str(e))

    def _read_ssm_command_cf_template(self, ssm_command):
        ssm_commands_dir_cf_template = self.module.params.get("ssm_commands_dir_cf_template")
        cf_template_file = ssm_commands_dir_cf_template + "/AEM-" + ssm_command + ".yaml"

        try:
            with open(cf_template_file, 'r') as ymlfile:
                cf_template = yaml.load(ymlfile)

                return cf_template
        except Exception as e:
            self.module.fail_json(msg="Error: Can't open file" + cf_template_file + " - " + str(e))

    def save(self, results):
        dest_file = self.module.params.get("dest_file")

        try:
            with open(dest_file, 'w') as ymlfile:
                ymlfile.write(results)

            result = {'changed': True, 'msg': 'Output saved to' + dest_file + '.'}

            return result

        except Exception as e:
            self.module.fail_json(msg="Error: Can't write to file" + dest_file + " - " + str(e))

def main():
    argument_spec = {}
    argument_spec.update(dict(
            ssm_command_cf_template=dict(required=True, type='str' ),
            ssm_commands_dir_cf_template=dict(required=True, type='str'),
            dest_file=dict(required=False, type='str')
    ))
    module = AnsibleModule(argument_spec=argument_spec)

    ssm_template = CreateSSMCFTemplate(module)
    results = ssm_template.create()

    if module.params.get("dest_file"):
        results = ssm_template.save(results)
    elif results:
        results = {'changed': True, 'msg': results}
    else:
        results = {'changed': False, 'msg': 'No template created'}

    module.exit_json(**results)

if __name__ == '__main__':
    main()

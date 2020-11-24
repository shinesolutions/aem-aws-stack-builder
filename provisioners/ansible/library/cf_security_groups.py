#!/usr/bin/python3

# Add security groups to CloudFormation template files.
# This will modify the CloudFormation template files.

import sys, json, glob
from ansible.module_utils.basic import *
from cfyaml import yaml


def read_template(file_name):
    with open(file_name, 'r') as f:
        template = yaml.load(f)
    return template


def write_template(file_name, template):
    with open(file_name, 'w') as f:
        text = yaml.dump(template, default_flow_style=False)
        f.write(text)


def add_security_groups_to_resource(resource_name, resource_properties, security_groups, template):

    for resource in template['Resources']:
        if resource_name == resource:
            resource_properties_list = resource_properties.split(',')
            if (len(resource_properties_list) == 1):
              resource_security_groups = template['Resources'][resource_name]['Properties'][resource_properties]
            elif (resource_properties_list[0] == 'NetworkInterfaces[0]'):
              resource_security_groups = template['Resources'][resource_name]['Properties']['NetworkInterfaces'][0][resource_properties_list[1]]
            else:
              raise Exception('Unsupported resource properties list ' + resource_properties_list)
            for secgrp in security_groups:
                resource_security_groups.append(secgrp)

    return template


def main():

    module = AnsibleModule(
      argument_spec = dict(
        template_dir = dict(required=True, type='str'),
        resource_name = dict(required=True, type='str'),
        resource_properties = dict(required=True, type='str'),
        security_groups = dict(required=True, type='list')
      )
    )

    template_dir = module.params['template_dir']
    resource_name = module.params['resource_name']
    resource_properties = module.params['resource_properties']
    security_groups = module.params['security_groups']

    template_files = glob.glob(template_dir + "*.yaml")
    for template_file in template_files:
        template = read_template(template_file)
        template = add_security_groups_to_resource(resource_name, resource_properties, security_groups, template)
        write_template(template_file, template)

    module.exit_json(changed = True, message = ", ".join(template_files))

if __name__ == '__main__':
    main()

#!/usr/bin/python

# Add security groups to CloudFormation template files.
# This will modify the CloudFormation template files,

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


def add_secgrps_to_elb(elb_resource, secgrps, template, debug_output):

    for resource in template['Resources']:
        if elb_resource in resource:
            elb_secgrps = template['Resources'][elb_resource]['Properties']['SecurityGroups']
            for secgrp in secgrps:
                #debug_output.append('Adding: ' + secgrp + ' to ' + elb_resource)
                elb_secgrps.append(secgrp)

    return template


def main():

    module = AnsibleModule(
      argument_spec = dict(
        template_dir = dict(required=True, type='str'),
        elb_resource = dict(required=True, type='str'),
        secgrps = dict(required=True, type='list')
      )
    )

    # for debug text
    debug_output = []

    template_dir = module.params['template_dir']
    elb_resource = module.params['elb_resource']
    secgrps = module.params['secgrps']

    template_files = glob.glob(template_dir + "*.yaml")
    for template_file in template_files:
        #debug_output.append('Adding Security Groups to %s' % template_file)
        template = read_template(template_file)
        template = add_secgrps_to_elb(elb_resource, secgrps, template, debug_output)
        write_template(template_file, template)

    module.exit_json(changed = True, message = ", ".join(template_files), debug_out=debug_output)

if __name__ == '__main__':
    main()

#!/usr/bin/python3

# Add tags (set in `aws.tags` configuration) to CloudFormation template files.
# This will modify the CloudFormation template files described in `tag_keys`,
# this workaround is needed due to CloudFormation template's lack of built-in support for
# injecting additional tags. Passing additional tags isn't an option because
# CloudFormation doesn't (yet?) support list parameters merging.

import sys, json, glob
from ansible.module_utils.basic import *
from cfyaml import yaml


def read_template(file_name):
    with open(file_name, "r") as f:
        template = yaml.full_load(f)
    return template


def write_template(file_name, template):
    with open(file_name, "w") as f:
        text = yaml.dump(template, default_flow_style=False)
        f.write(text)


def read_configuration():
    with open(configuration_file, "r") as f:
        configuration = yaml.full_load(f)
    return configuration


def add_tags(tags, global_tags, resource_type=None):
    for global_tag in global_tags:
        new_tag = global_tag.copy()
        if resource_type == "AWS::AutoScaling::AutoScalingGroup":
            new_tag["PropagateAtLaunch"] = True
        tags.append(new_tag)
    return tags


def add_global_tags(global_tags, template):
    for resource in template["Resources"]:
        resource_type = template["Resources"][resource]["Type"]
        if "Tags" in template["Resources"][resource]["Properties"]:
            cf_tags = template["Resources"][resource]["Properties"]["Tags"]
            tags = add_tags(cf_tags, global_tags, resource_type)

        if "TagSpecifications" in template["Resources"][resource]["Properties"]:
            tag_specifications = template["Resources"][resource]["Properties"][
                "TagSpecifications"
            ]
            for tag_specification in tag_specifications:
                tags = tag_specification["Tags"]
                new_tags = add_tags(
                    tags,
                    global_tags,
                )
    return template


def add_resource_tags(resource_tags, template, resource_key):
    resource = template["Resources"][resource_key]
    tags = resource["Properties"]["Tags"]
    for resource_tag in resource_tags:
        new_tag = resource_tag.copy()
        if resource["Type"] == "AWS::AutoScaling::AutoScalingGroup":
            new_tag["PropagateAtLaunch"] = True
        tags.append(new_tag)
    return template


def main():

    module = AnsibleModule(
        argument_spec=dict(
            template_dir=dict(required=True, type="str"),
            global_tags=dict(required=True, type="list"),
        )
    )

    template_dir = module.params["template_dir"]
    global_tags = module.params["global_tags"]

    template_files = glob.glob(template_dir + "*.yaml")
    for template_file in template_files:
        # print('Adding tags to %s' % template_file)
        template = read_template(template_file)
        template = add_global_tags(global_tags, template)
        write_template(template_file, template)

    # configuration = read_configuration()
    # for path, resources in configuration.get('templates', {}).iteritems():
    #     print('Adding tags to %s' % path)
    #     template = read_template(path)
    #     template = add_global_tags(configuration['global_tags'], template)
    #     for resource_key, resource_tags in resources.iteritems():
    #         template = add_resource_tags(resource_tags, template, resource_key)
    #
    #     write_template(path, template)

    module.exit_json(changed=True, message=", ".join(template_files))


if __name__ == "__main__":
    main()

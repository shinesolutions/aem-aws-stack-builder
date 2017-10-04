#!/usr/bin/env python
from cfyaml import yaml
import sys

# Usage validation
if len(sys.argv) != 2:
    print('Usage: add-global-tags.py <global_tags_conf>')
    raise SystemExit(1)

configuration_file = sys.argv[1]

def read_template(file_name):
    with open(file_name, 'r') as f:
        template = yaml.load(f)
    return template


def write_template(file_name, template):
    with open(file_name, 'w') as f:
        text = yaml.dump(template, default_flow_style=False)
        f.write(text)


def read_configuration():
    with open(configuration_file, 'r') as f:
        configuration = yaml.load(f)
    return configuration


def add_global_tags(global_tags, template):
    for resource in template['Resources']:
        if 'Tags' in template['Resources'][resource]['Properties']:
            tags = template['Resources'][resource]['Properties']['Tags']
            for global_tag in global_tags:
                new_tag = global_tag.copy()
                if template['Resources'][resource]['Type'] == 'AWS::AutoScaling::AutoScalingGroup':
                    new_tag['PropagateAtLaunch'] = True
                tags.append(new_tag)
    return template


def add_resource_tags(resource_tags, template, resource_key):
    resource = template['Resources'][resource_key]
    tags = resource['Properties']['Tags']
    for resource_tag in resource_tags:
        new_tag = resource_tag.copy()
        if resource['Type'] == 'AWS::AutoScaling::AutoScalingGroup':
            new_tag['PropagateAtLaunch'] = True
        tags.append(new_tag)
    return template


# Add tags to resources in the configured applications.
configuration = read_configuration()
for path, resources in configuration.get('templates', {}).iteritems():
    print('Adding tags to %s' % path)
    template = read_template(path)
    template = add_global_tags(configuration['global_tags'], template)
    for resource_key, resource_tags in resources.iteritems():
        template = add_resource_tags(resource_tags, template, resource_key)

    write_template(path, template)

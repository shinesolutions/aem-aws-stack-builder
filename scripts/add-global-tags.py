#!/usr/bin/env python
import ruamel.yaml
import sys

# Usage validation
if len(sys.argv) != 2:
    print('Usage: add-global-tags.py <global_tags_conf>')
    sys.exit(1)

tags_file_name = sys.argv[1]

# Applications configuration.
# file_name is the location of CloudFormation template file relative to current working directory
# resource_keys is an array of resource key names which tags need to be updated with the global tags
apps = {
  'author_dispatcher': {
    'file_name': './cloudformation/apps/author-dispatcher.yaml',
    'resource_keys': [
      'AuthorDispatcherAutoScalingGroup',
      'AuthorDispatcherLoadBalancer'
    ]
  },
  'author': {
    'file_name': './cloudformation/apps/author.yaml',
    'resource_keys': [
      'AuthorPrimaryInstance',
      'AuthorStandbyInstance',
      'AuthorLoadBalancer'
    ]
  },
  'chaos_monkey': {
    'file_name': './cloudformation/apps/chaos-monkey.yaml',
    'resource_keys': [
      'ChaosMonkeyAutoScalingGroup'
    ]
  },
  'orchestrator': {
    'file_name': './cloudformation/apps/orchestrator.yaml',
    'resource_keys': [
      'OrchestratorAutoScalingGroup'
    ]
  },
  'publish_dispatcher': {
    'file_name': './cloudformation/apps/publish-dispatcher.yaml',
    'resource_keys': [
      'PublishDispatcherAutoScalingGroup',
      'PublishDispatcherLoadBalancer'
    ]
  },
  'publish': {
    'file_name': './cloudformation/apps/publish.yaml',
    'resource_keys': [
      'PublishAutoScalingGroup'
    ]
  }
}

def read_template(file_name):
    file = open(file_name, 'r')
    template = ruamel.yaml.load(file, Loader=ruamel.yaml.RoundTripLoader, preserve_quotes=False)
    file.close()
    return template

def write_template(file_name, template):
    file = open(file_name, 'w')
    text = ruamel.yaml.dump(template, Dumper=ruamel.yaml.RoundTripDumper)
    file.write(text)
    file.close

def read_global_tags():
    file = open(tags_file_name, 'r')
    global_tags = ruamel.yaml.load(file, Loader=ruamel.yaml.SafeLoader)
    file.close()
    return global_tags

def add_tags(global_tags, template, resource_key):
    tags = template['Resources'][resource_key]['Properties']['Tags']
    for global_tag in global_tags:
        new_tag = {
            'Key': global_tag['Key'],
            'Value': global_tag['Value']
        }
        if resource_key.endswith('AutoScalingGroup'):
            new_tag['PropagateAtLaunch'] = True
        tags.append(new_tag)

# Add global tags to resources in the configured applications.
for app in apps:
    print('Adding tags to %s' % [app])
    file_name = apps[app]['file_name']
    template = read_template(file_name)
    global_tags = read_global_tags()
    for resource_key in apps[app]['resource_keys']:
        add_tags(global_tags['All'], template, resource_key)
        resource_tags = global_tags.get(resource_key, None)
        if resource_tags is not None:
            add_tags(resource_tags, template, resource_key)

    write_template(file_name, template)

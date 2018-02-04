#!/usr/bin/python

from ansible.module_utils.basic import *
import random
import string

def generate_facts(params):
    return """stack_prefix=%s
cron_env_path=%s
cron_https_proxy=%s
stack_manager_sns_topic_arn=%s
publish_dispatcher_allowed_client=%s
""" % (
            params['stack_prefix'],
            params['cron_env_path'],
            params['cron_https_proxy'],
            params['stack_manager_sns_topic_arn'],
            params['publish_dispatcher_allowed_client'],
        )

def main():

    module = AnsibleModule(
      argument_spec = dict(
        stack_prefix                      = dict(required=True, type='str'),
        cron_env_path                     = dict(required=True, type='str'),
        cron_https_proxy                  = dict(required=True, type='str'),
        stack_manager_sns_topic_arn       = dict(required=True, type='str'),
        publish_dispatcher_allowed_client = dict(required=True, type='str'),
      )
    )
    response = generate_facts(module.params)
    module.exit_json(changed = False, meta = response)

if __name__ == '__main__':
    main()

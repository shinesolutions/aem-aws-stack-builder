#!/usr/bin/python

from ansible.module_utils.basic import *
import random
import string

def generate_facts(params):
    return """stack_prefix=%s
aws_region=%s
cron_env_path=%s
cron_http_proxy=%s
cron_https_proxy=%s
cron_no_proxy=%s
publish_dispatcher_allowed_client=%s
""" % (
            params['stack_prefix'],
            params['aws_region'],
            params['cron_env_path'],
            params['cron_http_proxy'],
            params['cron_https_proxy'],
            params['cron_no_proxy'],
            params['publish_dispatcher_allowed_client'],
        )

def main():

    module = AnsibleModule(
      argument_spec = dict(
        stack_prefix                      = dict(required=True, type='str'),
        aws_region                        = dict(required=True, type='str'),
        cron_env_path                     = dict(required=True, type='str'),
        cron_http_proxy                   = dict(required=True, type='str'),
        cron_https_proxy                  = dict(required=True, type='str'),
        cron_no_proxy                     = dict(required=True, type='str'),
        publish_dispatcher_allowed_client = dict(required=True, type='str'),
      )
    )
    response = generate_facts(module.params)
    module.exit_json(changed = False, meta = response)

if __name__ == '__main__':
    main()

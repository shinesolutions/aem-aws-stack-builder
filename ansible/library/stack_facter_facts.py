#!/usr/bin/python

from ansible.module_utils.basic import *
import random
import string

def generate_facts(params):
    return """proxy_enabled=%s
proxy_protocol=%s
proxy_host=%s
proxy_port=%s
aem_orchestrator_version=%s
oak_run_version=%s
cron_env_path=%s
cron_https_proxy=%s
stack_manager_sns_topic_arn=%s
publish_dispatcher_allowed_client=%s
""" % (
            str(params['proxy_enabled']).lower(),
            params['proxy_protocol'],
            params['proxy_host'],
            params['proxy_port'],
            params['aem_orchestrator_version'],
            params['oak_run_version'],
            params['cron_env_path'],
            params['cron_https_proxy'],
            params['stack_manager_sns_topic_arn'],
            params['publish_dispatcher_allowed_client'],
        )

def main():

    module = AnsibleModule(
      argument_spec = dict(
        proxy_enabled                     = dict(required=True, type='bool'),
        proxy_protocol                    = dict(required=True, type='str'),
        proxy_host                        = dict(required=True, type='str'),
        proxy_port                        = dict(required=True, type='str'), # string type to allow empty value when proxy is irrelevant
        aem_orchestrator_version          = dict(required=True, type='str'),
        oak_run_version                   = dict(required=True, type='str'),
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

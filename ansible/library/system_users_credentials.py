#!/usr/bin/python

from ansible.module_utils.basic import *
import random
import string

def generate_password(length):
    return ''.join(random.SystemRandom().choice(string.ascii_letters + string.digits) for _ in range(length))

def main():

    module = AnsibleModule(
      argument_spec = dict(
        enable_default_passwords = dict(required=True, type='bool'),
      )
    )

    system_users = ['orchestrator', 'replicator', 'deployer', 'exporter', 'importer', 'admin']
    credentials = {}
    for system_user in system_users:
        credentials[system_user] = system_user if module.params['enable_default_passwords'] == True else generate_password(100)

    response = credentials
    module.exit_json(changed = False, meta = response)

if __name__ == '__main__':
    main()

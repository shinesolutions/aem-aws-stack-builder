#!/usr/bin/python

from ansible.module_utils.basic import *
import random
import string

def generate_password(length):
    return ''.join(random.SystemRandom().choice(string.ascii_letters + string.digits) for _ in range(length))

def main():

    system_users = ['orchestrator', 'replicator', 'deployer', 'exporter', 'importer']
    credentials = {}
    for system_user in system_users:
        credentials[system_user] = generate_password(100)

    module = AnsibleModule(argument_spec = {})
    response = credentials
    module.exit_json(changed = False, meta = response)

if __name__ == '__main__':
    main()

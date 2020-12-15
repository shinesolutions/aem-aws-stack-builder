#!/usr/bin/python3

# Delete SimpleDB Domain

from ansible.module_utils.basic import *
import boto3

def delete_sdb_domain(domain_name, region):
    sdb = boto3.client('sdb', region_name=region)
    sdb.delete_domain(DomainName=domain_name)

def main():

    module = AnsibleModule(
      argument_spec = dict(
        domain_name = dict(required=True, type='str'),
        region = dict(required=True, type='str')
      )
    )

    delete_sdb_domain(module.params['domain_name'], module.params['region'])

    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    module.exit_json(**result)

if __name__ == '__main__':
    main()

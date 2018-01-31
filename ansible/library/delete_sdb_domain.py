#!/usr/bin/python

# Delete SimpleDB Domain

from ansible.module_utils.basic import *
import boto3

def delete_sdb_domain(sdb_domain_name):
    sdb = boto3.client('sdb')
    sdb.delete_domain(DomainName=sdb_domain_name)

def main():

    module = AnsibleModule(
      argument_spec = dict(
        sdb_domain_name = dict(required=True, type='str')
      )
    )

    delete_sdb_domain(module.params['sdb_domain_name'])

if __name__ == '__main__':
    main()

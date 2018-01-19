#!/usr/bin/python

# Delete SimpleDB Domain

from ansible.module_utils.basic import *
import boto3

def delete_sdb_domain():
    module_args = dict(
    sdb_domain_name=dict(required=True, type='str'),
    )

    module = AnsibleModule(argument_spec=module_args)
  
    client = boto3.client('sdb')

    client.delete_domain(DomainName="module.params[sdb_domain_name]")

def main():

    delete_sdb_domain()  

if __name__ == '__main__':
    main()



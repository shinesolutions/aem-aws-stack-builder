#!/usr/bin/python

# Delete SimpleDB Domain

from ansible.module_utils.basic import *
import boto3

def delete_sdb_domain()

fields = dict(
    sdb_domain_name=dict(required=True, type='str')
  )

  module = AnsibleModule(argument_spec=fields)
  
  client = boto3.client('sdb')
  
  response = client.delete_domain(DomainName='module.params['sdb_domain_name']')  
    
  module.exit_json(changed = False, meta = response)


def main():

    delete_sdb_domain()  

if __name__ == '__main__':
    main()






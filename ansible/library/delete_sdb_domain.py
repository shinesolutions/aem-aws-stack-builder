#!/usr/bin/python

# Delete SimpleDB Domain

from ansible.module_utils.basic import *
import boto3

def main():

  fields = {
        "sdb_domain_name": {"required": True, "type": "str"},
    }

  module = AnsibleModule(argument_spec=fields)

  client = boto3.client('sdb')

  response = client.delete_domain(DomainName='module.params')  
    
  module.exit_json(changed = False, meta = response)


if __name__ == '__main__':
    main()



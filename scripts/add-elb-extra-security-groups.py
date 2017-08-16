#!/usr/bin/python

from ruamel import yaml
import sys
import boto3


def add_additional_security_groups(stack_prefix, resource_name, security_groups):

    # retrieve existing security groups
    stack_exports = boto3.client('cloudformation').list_exports()['Exports']
    elb_export = filter(lambda export: export['Name'] == '{}-{}'.format(stack_prefix, resource_name), stack_exports)[0]
    elb_name = elb_export['Value']

    elb = boto3.client('elb')
    response = elb.describe_load_balancers(
        LoadBalancerNames=[ elb_name ]
    )
    existing_sgs = response['LoadBalancerDescriptions'][0]['SecurityGroups']

    # new list of groups.
    new_sgs = list(set(existing_sgs).union(set(security_groups)))

    print('Adding security groups {} to load balancer {}'.format(security_groups, elb_name))
    response = elb.apply_security_groups_to_load_balancer(
        LoadBalancerName = elb_name,
        SecurityGroups = new_sgs
    )


if __name__ == '__main__':

    # Usage validation
    if len(sys.argv) != 3:
        print('Usage: {} stack_prefix config_file'.format(sys.argv[0]))
        raise SystemExit(1)

    with open(sys.argv[2]) as f:
        config = yaml.safe_load(f)

    for ELB in ['PublishDispatcherLoadBalancer', 'AuthorDispatcherLoadBalancer']:
        if ELB in config and config[ELB] is not None:
            add_additional_security_groups(sys.argv[1], ELB, config[ELB])

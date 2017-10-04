#!/usr/bin/env python

# -*- coding: utf8 -*-

"""
Given an AWS CloudFormation stack name, write the stack outputs in key: value
format under a given section key into a yaml file, which can be later used as
an input for subsequent processing.
"""

__author__ = 'Andy Wang (andy.wang@shinesolutions.com)'
__copyright__ = 'Shine Solutions'
__license__ = 'Apache License, Version 2.0'


import boto3
import yaml
import operator
import sys

def write_stack_outputs(stack_name, output_key, output_yaml):
    """

    """
    cloudformation = boto3.resource('cloudformation')
    stacks = cloudformation.stacks.filter(StackName=stack_name)
    output={}

    for stack in stacks:
        entries = map(operator.itemgetter('OutputKey','OutputValue'),
                      stack.outputs)
        for key, value in entries:
            output[key]=value

    with open(output_yaml,'w') as yaml_output:
        yaml.dump(
            { output_key: output},
            yaml_output,
            default_flow_style=False
        )



if __name__ == "__main__":

    if len(sys.argv) != 4:
        print('Usage: {} <stack_name> <output_key> <outout_yaml_file>'.format(
            sys.argv[0]
        ))
        sys.exit(1)

    stack_name = sys.argv[1]
    output_key = sys.argv[2]
    output_yaml = sys.argv[3]

    write_stack_outputs(stack_name, output_key, output_yaml)

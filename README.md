# aem-aws-stack-builder
Cloudformation templates (yaml) for creating an AEM Stack

Network (shared) Stacks:
* vpc
* network

AEM Application (specific) Stacks:
* roles (can be shared across stacks)
* security-groups
* messaging
* publish-dispatcher
* publish
* author
* author-dispatcher
* orchestrator
* chaos-monkey

Prerequisites:
* ec2 key pair
* ssl server certificate
* ami images for publish-dispatcher, publish, author, author-dispatcher, orchestrator, chaos-monkey (with component and version tags)
* dns hosted zone
* provisioning init script accessible via s3 bucket
* inbound_from_bastion_host_security_group
* nat gateway / internet proxy


## Installation

Requirements:

* Run `make deps` to install [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html), [Ansible](http://docs.ansible.com/ansible/intro_installation.html), and [Boto 3](https://boto3.readthedocs.io/en/latest/).
* [Configure](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-quick-configuration) AWS CLI.

## Usage

Requirements:

* Set up SSL certificate in [AWS IAM](https://aws.amazon.com/iam), check out `create-cert`, `upload-cert`, and `delete-cert` targets in the Makefile for examples.
* Set up [EC2 key pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html). The key pair name should be configured in `ansible/inventory/group_vars/apps.yaml` at `compute.key_pair_name` field.

To create the network setup (VPC, subnets, etc):

    STACK_PREFIX=mynetwork make create-network

To delete the network setup:

    STACK_PREFIX=mynetwork make delete-network

To create AEM infrastructure:

    STACK_PREFIX=myaem make create-aem

To delete AEM infrastructure:

    STACK_PREFIX=myaem make delete-aem

`STACK_PREFIX` environment variable is used to prefix the CloudFormation stack names.

It is also possible to create specific components without the complete set. Check out the Makefile for the complete list of targets.

## Configuration

Work in Progress


## Development

Requirements:

* Install [ShellCheck](https://github.com/koalaman/shellcheck#user-content-installing)

Check shell scripts, validate CloudFormation templates, check Ansible playbooks syntax:
```
make lint
```

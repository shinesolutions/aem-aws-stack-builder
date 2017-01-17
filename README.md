[![Build Status](https://img.shields.io/travis/shinesolutions/aem-aws-stack-builder.svg)](http://travis-ci.org/shinesolutions/aem-aws-stack-builder)

# AEM AWS Stack Builder
A set of [Ansible](https://www.ansible.com/) playbooks for building [Adobe Experience Manager (AEM)](http://www.adobe.com/au/marketing-cloud/enterprise-content-management.html) on [AWS](https://aws.amazon.com/) using CloudFormation stacks.

Stack Builder has been designed with a focus on modularity, allowing the separation between network set up (VPC, subnets, etc) and applications set up (AEM Author, Publish, and Dispatcher).

TODO: note on Orchestrator and Chaos Monkey.

## Installation

Requirements:

* Run `make deps` to install [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html), [Ansible](http://docs.ansible.com/ansible/intro_installation.html), and [Boto 3](https://boto3.readthedocs.io/en/latest/).
* [Configure](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-quick-configuration) AWS CLI.

## Usage

Requirements:

* Set up SSL certificate in [AWS IAM](https://aws.amazon.com/iam), check out `create-cert`, `upload-cert`, and `delete-cert` targets in the Makefile for examples.
* Set up [EC2 key pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html). The key pair name should be configured in `ansible/inventory/group_vars/apps.yaml` at `compute.key_pair_name` field.

TODO:
* ec2 key pair
* ssl server certificate
* ami images for publish-dispatcher, publish, author, author-dispatcher, orchestrator, chaos-monkey (with component and version tags)
* dns hosted zone
* provisioning init script accessible via s3 bucket
* inbound_from_bastion_host_security_group
* nat gateway / internet proxy

To create the network setup (VPC, subnets, etc):

    make create-set-network stack_prefix=mynetwork

To delete the network setup:

    make delete-set-network stack_prefix=mynetwork

To create AEM infrastructure:

    make create-set-aem stack_prefix=myaem

It is also possible to specify custom configuration files:

    make create-set-aem stack_prefix=myaem config_path=/path/to/myconf

To delete AEM infrastructure:

    make delete-set-aem stack_prefix=myaem

Makefile variables:

| Name         | Description                                      |
|--------------|--------------------------------------------------|
| stack_prefix | Prefix string added to all stack names           |
| config_path  | Path to directory containing configuration files |

It is also possible to create specific components without the complete set. Check out the Makefile for the complete list of targets.

## Configuration

|--------------------------------------------|------|
| Name                                       | Description | Default value |
|--------------------------------------------|------|
| publish_dispatcher.stack_name              | TODO |
| publish_dispatcher.instance_profile        | TODO |
| publish_dispatcher.instance_type           | TODO |
| publish_dispatcher.min_size                | TODO |
| publish_dispatcher.max_size                | TODO |
| publish_dispatcher.load_balancer.tag_name  | TODO |
| publish_dispatcher.tag_name                | TODO |
| publish_dispatcher.elb_health_check        | TODO |
| publish_dispatcher.route53_record_set_name | TODO |
| chaos_monkey.stack_name                    | TODO |
| chaos_monkey.ami_id                        | TODO |
| chaos_monkey.instance_profile              | TODO |
| chaos_monkey.instance_type                 | TODO |
| chaos_monkey.tag_name                      | TODO |
|--------------------------------------------|------|

## Development

Requirements:

* Install [ShellCheck](https://github.com/koalaman/shellcheck#user-content-installing)

Check shell scripts, validate CloudFormation templates, check Ansible playbooks syntax:
```
make lint
```

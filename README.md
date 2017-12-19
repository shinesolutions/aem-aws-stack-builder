[![Build Status](https://img.shields.io/travis/shinesolutions/aem-aws-stack-builder.svg)](http://travis-ci.org/shinesolutions/aem-aws-stack-builder)

AEM AWS Stack Builder
---------------------

A set of [Ansible](https://www.ansible.com/) playbooks for building [Adobe Experience Manager (AEM)](http://www.adobe.com/au/marketing-cloud/enterprise-content-management.html) on [AWS](https://aws.amazon.com/) using CloudFormation stacks.

Stack Builder has been designed with a focus on modularity, allowing the separation between network set up (VPC, subnets, etc) and applications set up (AEM Author, Publish, and Dispatcher), while also providing a flexible way to support multiple architectures.

Stack Builder currently supports the following AEM architectures:
* Full Set ([diagram](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/architecture-full-set.png)) - runs AEM Author, Publish, and Dispatcher on separate EC2 instances with auto-recovery and auto-scaling support, suitable for production environment
* Consolidated ([diagram](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/architecture-consolidated.png)) - runs AEM Author, Publish, and Dispatcher on a single EC2 instance, suitable for development environment

Installation
------------

- Install the following required tools:
  * [Python](https://www.python.org/downloads/) version 2.7 or latest 2.x
  * [Ruby](https://www.ruby-lang.org/en/) version 2.0.0 or later
  * [GNU Make](https://www.gnu.org/software/make/)
- Either clone AEM AWS Stack Builder `git clone https://github.com/shinesolutions/aem-aws-stack-builder.git` or download one of the [released versions](https://github.com/shinesolutions/aem-aws-stack-builder/releases)
- Resolve the [Python packages](https://pip.readthedocs.io/en/1.1/requirements.html) dependencies by running `make deps`

Usage
-----

Requirements:

The following resources need to be provisioned separate from AEM AWS Stack Builder due to various security policies at various organisations.

* Set up SSL certificate in [AWS IAM](https://aws.amazon.com/iam), check out `create-cert`, `upload-cert`, and `delete-cert` targets in the Makefile for examples.
* Set up [EC2 key pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html). The key pair name is configured in `compute.key_pair_name` field.
* Set up an S3 bucket to store stack state information. The bucket name is configured in  `s3.data_bucket_name` field.

TODO:
* ami images for publish-dispatcher, publish, author, author-dispatcher, orchestrator, chaos-monkey (with component and version tags)
* dns hosted zone
* provisioning init script accessible via s3 bucket
* inbound_from_bastion_host_security_group
* nat gateway / internet proxy

To create the network setup (VPC, subnets, etc):

    make create-set-network stack_prefix=mynetwork

To delete the network setup:

    make delete-set-network stack_prefix=mynetwork

Before creating AEM infrastructure, make sure the network resources Id's are captured in app.yaml file. This is to decouple the network stacks and AEM stacks, as we may not always have control over the underlying network infrastructure.

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

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

- Set up the required [AWS resources](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/aws-resources.md)
- Create [AWS tags and Ansible configuration files](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md)

Network stacks:
- Create VPC, subnets, along with other network resources: `make create-network stack_prefix=<network_stack_prefix> config_path=<path/to/config/dir>`. Alternatively, if you don't have the permission to create network resources, you can create a network-exports stack that contains your subnets. TODO: `make create-network-exports stack_prefix=<network_stack_prefix> config_path=<path/to/config/dir>`.

Shared stacks:
- Create roles stack which contains the IAM instance profiles and roles: `make create-roles stack_prefix=<roles_stack_prefix> config_path=<path/to/config/dir>`. If you don't have the permission to create any IAM resource, you can use the [roles CloudFormation template](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/cloudformation/apps/roles.yaml#L13) as guidance. These roles stack can be shared across multiple compute stacks.

Consolidated architecture stacks:
- Configure `security_groups.network_stack_prefix` with the `<network_stack_prefix>` value from network section above.
- Create security groups stack which contains the security groups ingress and egress: `make create-security-groups stack_prefix=<security_groups_stack_prefix> config_path=<path/to/config/dir>`. This security groups stack can be shared across multiple compute stacks to speed up compute stack creation time. Do not share a single security groups stack with multiple compute stacks when running in production.
- Configure `author_publish_dispatcher.roles_stack_prefix` with the `<roles_stack_prefix>` value, and `author_publish_dispatcher.security_groups_stack_prefix` with the `<security_groups_stack_prefix>` value, both provided in the previous steps.
- Create compute stack which contains EC2 instances running AEM: `make create-consolidated stack_prefix=<consolidated_stack_prefix> config_path=<path/to/config/dir>`.

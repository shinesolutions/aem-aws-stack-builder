[![Build Status](https://img.shields.io/travis/shinesolutions/aem-aws-stack-builder.svg)](http://travis-ci.org/shinesolutions/aem-aws-stack-builder)

AEM AWS Stack Builder
---------------------

A set of [Ansible](https://www.ansible.com/) playbooks for building [Adobe Experience Manager (AEM)](http://www.adobe.com/au/marketing-cloud/enterprise-content-management.html) architectures on [AWS](https://aws.amazon.com/) using CloudFormation stacks.

Stack Builder has been designed with a focus on modularity, allowing the separation between network set up (VPC, subnets, etc) and applications set up (AEM Author, Publish, and Dispatcher), while also providing a flexible way to support multiple architectures that run a combination of the following components:

* `author-primary` - contains [AEM Author](https://helpx.adobe.com/experience-manager/6-3/sites/authoring/using/author.html) running in primary mode
* `author-standby` - contains [AEM Author](https://helpx.adobe.com/experience-manager/6-3/sites/authoring/using/author.html) running in [standby](https://helpx.adobe.com/experience-manager/6-3/sites/deploying/using/tarmk-cold-standby.html) mode
* `publish` - contains [AEM Publish](https://helpx.adobe.com/experience-manager/6-3/sites/authoring/using/author.html)
* `author-dispatcher` - contains [AEM Dispatcher](https://helpx.adobe.com/experience-manager/dispatcher/using/dispatcher.html) with author-dispatcher configuration, sitting in front of `author` component
* `publish-dispatcher` - contains [AEM Dispatcher](https://helpx.adobe.com/experience-manager/dispatcher/using/dispatcher.html) with publish-dispatcher configuration, sitting in front of `publish` component
* `orchestrator` - contains [AEM Orchestrator](https://github.com/shinesolutions/aem-orchestrator)
* `chaos-monkey` - contains [Chaos Monkey](https://netflix.github.io/chaosmonkey/)
* `author-publish-dispatcher` - contains AEM Author, AEM Publish, and AEM Dispatcher

Stack Builder currently supports the following AEM architectures:
* Full Set ([diagram](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/architecture-full-set.png)) - runs AEM Author, Publish, and Dispatcher on separate EC2 instances with auto-recovery and auto-scaling support, suitable for all types (e.g. production, staging, testing, and development) of environments
* Consolidated ([diagram](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/architecture-consolidated.png)) - runs AEM Author, Publish, and Dispatcher on a single EC2 instance, suitable for development environments

Installation
------------

- Install the following required tools:
  * [Ruby](https://www.ruby-lang.org/en/) version 2.0.0 or later
  * [Python](https://www.python.org/downloads/) version 2.7.x
  * [GNU Make](https://www.gnu.org/software/make/)
- Either clone AEM AWS Stack Builder `git clone https://github.com/shinesolutions/aem-aws-stack-builder.git` or download one of the [released versions](https://github.com/shinesolutions/aem-aws-stack-builder/releases)
- Resolve the [Python packages](https://pip.readthedocs.io/en/1.1/requirements.html) dependencies by running `make deps`

Usage
-----

Set up common resources and configuration:
- Set up the required [AWS resources](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/aws-resources.md)
- Create [configuration file](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md)

Set up network stacks:
- Create VPC, subnets, along with other network resources:

    `make create-network stack_prefix=<network_stack_prefix> config_path=<path/to/config/dir>`.

- Alternatively, if you don't have the permission to create network resources, you can create a network-exports stack that contains your subnets. TODO:

    `make create-network-exports stack_prefix=<network_stack_prefix> config_path=<path/to/config/dir>`.

### Consolidated AEM Architecture

- Set up [configuration file for Consolidated architecture]().
- Create consolidated prerequisites stack which contains the instance profiles and security groups:

    `make create-consolidated-prerequisites stack_prefix=<consolidated_prerequisites_stack_prefix> config_path=<path/to/config/dir>`.

  This consolidated prerequisites stack can be shared across multiple consolidated main stacks in order to speed up the main stack creation time. Do not share a single consolidated prerequisites stack with multiple consolidated main stacks when running in production.
- Configure `instance_profiles_stack_prefix` and `security_groups_stack_prefix` with the `<consolidated_prerequisites_stack_prefix>` value.
- Create consolidated main stack which contains the EC2 instance and DNS record:

    `make create-consolidated-main stack_prefix=<consolidated_main_stack_prefix> config_path=<path/to/config/dir>`.

  This consolidated main stack uses the instance profiles and security groups that are defined in the consolidated prerequisites stack.
- However, if you don't care about reusing the prerequisites stack, you can use the following simpler command:

    `make create-consolidated stack_prefix=<fullset_stack_prefix> config_path=<path/to/config/dir>`.

### Full-Set AEM Architecture

- Set up [configuration file for Full-Set architecture]().
- Create full set prerequisites stack which contains the security groups and messaging SNS SQS:

    `make create-full-set-prerequisites stack_prefix=<fullset_prerequisites_stack_prefix> config_path=<path/to/config/dir>`.

  This full-set prerequisites stack must be mapped one to one to a full-set main stack.
- Configure `instance_profile_stack_prefix`, `messaging_stack_prefix`, and `security_groups_stack_prefix` with the `<fullset_prerequisites_stack_prefix>` value.
- Create full-set main stack which contains the EC2 instance and DNS records:

    `make create-full-set-main stack_prefix=<fullset_main_stack_prefix> config_path=<path/to/config/dir>`.

  Full-set prerequisites and main stacks are separated in order to allow you to save cost by terminating the main stack when unused, and at the same time to speed up environment creation time by not having to recreate the prerequisites.
- However, if you don't care about reusing the prerequisites stack, you can use the following simpler command:

    `make create-full-set stack_prefix=<fullset_stack_prefix> config_path=<path/to/config/dir>`.

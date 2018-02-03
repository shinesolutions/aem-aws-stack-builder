[![Build Status](https://img.shields.io/travis/shinesolutions/aem-aws-stack-builder.svg)](http://travis-ci.org/shinesolutions/aem-aws-stack-builder)

AEM AWS Stack Builder
---------------------

A set of [Ansible](https://www.ansible.com/) playbooks for building [Adobe Experience Manager (AEM)](http://www.adobe.com/au/marketing-cloud/enterprise-content-management.html) architectures on [AWS](https://aws.amazon.com/) using CloudFormation stacks.

Stack Builder has been designed with a focus on modularity, allowing the separation between network and application components, while also providing a flexible way to support multiple architectures that run a combination of the following components:

* `author-primary` - contains [AEM Author](https://helpx.adobe.com/experience-manager/6-3/sites/authoring/using/author.html) running in primary mode
* `author-standby` - contains [AEM Author](https://helpx.adobe.com/experience-manager/6-3/sites/authoring/using/author.html) running in [standby](https://helpx.adobe.com/experience-manager/6-3/sites/deploying/using/tarmk-cold-standby.html) mode
* `publish` - contains [AEM Publish](https://helpx.adobe.com/experience-manager/6-3/sites/authoring/using/author.html)
* `author-dispatcher` - contains [AEM Dispatcher](https://helpx.adobe.com/experience-manager/dispatcher/using/dispatcher.html) with author-dispatcher configuration, sitting in front of `author` component
* `publish-dispatcher` - contains [AEM Dispatcher](https://helpx.adobe.com/experience-manager/dispatcher/using/dispatcher.html) with publish-dispatcher configuration, sitting in front of `publish` component
* `orchestrator` - contains [AEM Orchestrator](https://github.com/shinesolutions/aem-orchestrator)
* `chaos-monkey` - contains [Chaos Monkey](https://netflix.github.io/chaosmonkey/)
* `author-publish-dispatcher` - contains AEM Author, AEM Publish, and AEM Dispatcher

Stack Builder currently supports the following AEM architectures:
* Full Set ([diagram](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/architecture-full-set.png)) - runs AEM Author, Publish, and Dispatcher on separate EC2 instances with blue-green deployment, auto-recovery, auto-scaling, backup, and compaction support, suitable for all types (e.g. production, staging, testing, and development) of environments
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

### Network

Set up common resources and configuration:
- Set up the required [AWS resources](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/aws-resources.md)
- Create [configuration file](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md)

Set up network stacks:
- Create VPC, subnets, along with other network resources:

    make create-network stack_prefix=<network_stack_prefix> config_path=<path/to/config/dir>

- Alternatively, if you don't have the permission to create network resources, you can create a network-exports stack that contains your subnets. TODO:

    make create-network-exports stack_prefix=<network_stack_prefix> config_path=<path/to/config/dir>

### AEM Full-Set Architecture

<img width="800" alt="AEM Full-Set Architecture Diagram" src="https://raw.githubusercontent.com/shinesolutions/aem-aws-stack-builder/master/docs/architecture-full-set.png"/>

Set up [configuration file for AEM Full-Set architecture]().

The simplest way to create this AEM architecture is by standing up both full set prerequisites and main stacks in one go:

    make create-full-set stack_prefix=<fullset_stack_prefix> config_path=<path/to/config/dir>

However, it is also possible to separate the prerequisites from the main stacks. A use case scenario for this set up is when you want to keep the prerequisites stack around while creating/deleting the main stack within an environment, this allows you to cut some cost and to speed up environment standing up time from the second time onward.

Create prerequisites stack which contains the instance profiles, security groups, and messaging SNS SQS resources:

    make create-full-set-prerequisites stack_prefix=<fullset_prerequisites_stack_prefix> config_path=<path/to/config/dir>

Create main stack which contains EC2 and Route53 resources:

    make create-full-set-main stack_prefix=<fullset_main_stack_prefix> prerequisites_stack_prefix=<fullset_prerequisites_stack_prefix> config_path=<path/to/config/dir>

### AEM Consolidated Architecture

<img width="500" alt="AEM Consolidated Architecture Diagram" src="https://raw.githubusercontent.com/shinesolutions/aem-aws-stack-builder/master/docs/architecture-consolidated.png"/>

Set up [configuration file for AEM Consolidated architecture]().

The simplest way to create this AEM architecture is by standing up both full set prerequisites and main stacks in one go:

    make create-consolidated stack_prefix=<consolidated_stack_prefix> config_path=<path/to/config/dir>

It is also possible to separate the prerequisites from the main stacks. A use case scenario for this set up is when you want to reuse the same prerequisites stack for multiple main stacks. Please note that having a one to many mapping between prerequisites stack to multiple main stacks is only applicable for development environments, and not for production.

Create prerequisites stack which contains the instance profiles and security groups:

    make create-consolidated-prerequisites stack_prefix=<consolidated_prerequisites_stack_prefix> config_path=<path/to/config/dir>

Create main stack which contains EC2 and Route53 resources:

    make create-consolidated-main stack_prefix=<consolidated_main_stack_prefix> prerequisites_stack_prefix=<consolidated_prerequisites_stack_prefix> config_path=<path/to/config/dir>

### AEM Stack Manager

<img width="600" alt="AEM Stack Manager Diagram" src="https://raw.githubusercontent.com/shinesolutions/aem-aws-stack-builder/master/docs/architecture-stack-manager.png"/>

Set up [configuration file for AEM Stack Manager]().

Create AEM Stack Manager stacks:

    make create-stack-manager stack_prefix=<stack_manager_stack_prefix> config_path=<path/to/config/dir>

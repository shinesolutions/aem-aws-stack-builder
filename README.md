[![Build Status](https://img.shields.io/travis/shinesolutions/aem-aws-stack-builder.svg)](http://travis-ci.org/shinesolutions/aem-aws-stack-builder)

AEM AWS Stack Builder
---------------------

A set of [Ansible](https://www.ansible.com/) playbooks for building [Adobe Experience Manager (AEM)](http://www.adobe.com/au/marketing-cloud/enterprise-content-management.html) architectures on [AWS](https://aws.amazon.com/) using CloudFormation stacks.

Stack Builder has been designed with a focus on modularity, allowing the separation between network and application components, while also providing a flexible way to support multiple architectures that run a combination of the following components across multiple AEM versions:

* `author-primary` - contains [AEM Author](https://helpx.adobe.com/experience-manager/6-3/sites/authoring/using/author.html) running in primary mode
* `author-standby` - contains [AEM Author](https://helpx.adobe.com/experience-manager/6-3/sites/authoring/using/author.html) running in [standby](https://helpx.adobe.com/experience-manager/6-3/sites/deploying/using/tarmk-cold-standby.html) mode
* `publish` - contains [AEM Publish](https://helpx.adobe.com/experience-manager/6-3/sites/authoring/using/author.html)
* `author-dispatcher` - contains [AEM Dispatcher](https://helpx.adobe.com/experience-manager/dispatcher/using/dispatcher.html) with author-dispatcher configuration, sitting in front of `author` component
* `publish-dispatcher` - contains [AEM Dispatcher](https://helpx.adobe.com/experience-manager/dispatcher/using/dispatcher.html) with publish-dispatcher configuration, sitting in front of `publish` component
* `orchestrator` - contains [AEM Orchestrator](https://github.com/shinesolutions/aem-orchestrator)
* `chaos-monkey` - contains [Chaos Monkey](https://netflix.github.io/chaosmonkey/)
* `author-publish-dispatcher` - contains AEM Author, AEM Publish, and AEM Dispatcher

Stack Builder currently supports the following AEM architectures:
* Full Set ([diagram](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/architecture-full-set.png)) - includes AEM Author, Publish, and Dispatcher on separate EC2 instances with blue-green deployment, auto-recovery, auto-scaling, backup, and compaction support, suitable for all types (e.g. production, staging, testing, and development) of environments
* Consolidated ([diagram](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/architecture-consolidated.png)) - includes AEM Author, Publish, and Dispatcher on a single EC2 instance with backup and compaction support and a much lower AWS cost footprint, suitable for testing and development environments

Other than the above AEM architectures, Stack Builder also provides the following utilities:
* Stack Manager([diagram](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/architecture-stack-manager.png)) - includes [AEM Stack Manager](https://github.com/shinesolutions/aem-stack-manager-cloud), set of AWS Lambda functions that will execute AEM functionalities via an SSM agent
* Network - includes CloudFormation templates for creating VPC, subnets, and some sample NAT Gateway and Bastion set up

Learn more about AEM AWS Stack Builder:

* [Installation](https://github.com/shinesolutions/aem-aws-stack-builder#installation)
* [Configuration](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md)
* [Usage](https://github.com/shinesolutions/aem-aws-stack-builder#usage)
  * [Network](https://github.com/shinesolutions/aem-aws-stack-builder#network)
  * [AEM Full-Set Architecture](https://github.com/shinesolutions/aem-aws-stack-builder#aem-full-set-architecture)
  * [AEM Consolidated Architecture](https://github.com/shinesolutions/aem-aws-stack-builder#aem-consolidated-architecture)
  * [AEM Stack Manager](https://github.com/shinesolutions/aem-aws-stack-builder#aem-stack-manager)
* [Testing](https://github.com/shinesolutions/aem-aws-stack-builder#testing)
* [AWS Resources](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/aws-resources.md)
* [AWS System Tags](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/aws-system-tags.md)
* [Customisation Points](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/customisation-points.md)
* [Descriptors](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/descriptors.md)
  * [Deployment Descriptor Definition](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/descriptors-definition-deployment.md)
  * [Package Backup Descriptor Definition](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/descriptors-definition-package-backup.md)
  * [Content Health Check Descriptor Definition](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/descriptors-definition-content-health-check.md)
* [Logs](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/logs.md)
* [Permission Types](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/permission-types.md)
* [Snapshot Types](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/snapshot-types.md)
* [Frequently Asked Questions](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/faq.md)
* [Troubleshooting Guide](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/troubleshooting-guide.md)
* [Upgrade Guide](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/upgrade-guide.md)
* [Stacks Structure](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/stacks-structure.md)
* [Presentations](https://github.com/shinesolutions/aem-aws-stack-builder/#presentations)

AEM AWS Stack Builder is part of [AEM OpenCloud](https://aemopencloud.io) platform.

Installation
------------

- Either clone AEM AWS Stack Builder `git clone https://github.com/shinesolutions/aem-aws-stack-builder.git` or download one of the [released versions](https://github.com/shinesolutions/aem-aws-stack-builder/releases)
- Install the following required tools:
  * [Ruby](https://www.ruby-lang.org/en/) version 2.3.0 or later
  * [Python](https://www.python.org/downloads/) version 2.7.x
  * [GNU Make](https://www.gnu.org/software/make/)<br/>

  Alternatively, you can use [AEM Platform BuildEnv](https://github.com/shinesolutions/aem-platform-buildenv) Docker container to run Packer AEM build targets.
- Resolve the [Python packages](https://pip.readthedocs.io/en/1.1/requirements.html) dependencies by running `make deps`

Usage
-----

- Set up the required [AWS resources](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/aws-resources.md)
- Create [configuration file](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md)
- Set up the configuration files by running `make config config_path=<path/to/config/dir>`
- Download open source library artifacts and upload them to S3 by running `make library config_path=<path/to/config/dir>`

### Network

Ensure [configuration file for network](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md) has been set up.

From the above base configuration, generate template network configuration file:

    make generate-network-config stack_prefix=<network_stack_prefix> config_path=<path/to/config/dir>

The above is a once off action which will create a bootstrap network configuration file at `<path/to/config/dir>/network.yaml`, this will save you the trouble of manually creating a long configuration file. Alternatively, you can create the network configuration file manually.

Create VPC stack:

    make create-vpc stack_prefix=<network_stack_prefix> config_path=<path/to/config/dir>

Create network resources stack:

    make create-network stack_prefix=<network_stack_prefix> config_path=<path/to/config/dir>

Alternatively, if you don't have the permission to create VPC and/or network resources, you can create a network-exports stack that contains the details of your subnets:

    make create-network-exports stack_prefix=<network_stack_prefix> config_path=<path/to/config/dir>

### AEM Stack Manager

<img width="600" alt="AEM Stack Manager Diagram" src="https://raw.githubusercontent.com/shinesolutions/aem-aws-stack-builder/master/docs/architecture-stack-manager.png"/>

Ensure [configuration file for AEM Stack Manager](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md) has been set up.

Create AEM Stack Manager stacks:

    make create-stack-manager stack_prefix=<stack_manager_stack_prefix> config_path=<path/to/config/dir>

### AEM Full-Set Architecture

<img width="800" alt="AEM Full-Set Architecture Diagram" src="https://raw.githubusercontent.com/shinesolutions/aem-aws-stack-builder/master/docs/architecture-full-set.png"/>

Ensure [configuration file for AEM Full-Set architecture](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md) has been set up.

The simplest way to create this AEM architecture is by standing up both full set prerequisites and main stacks in one go:

    make create-full-set stack_prefix=<fullset_stack_prefix> config_path=<path/to/config/dir>

However, it is also possible to separate the prerequisites from the main stacks. A use case scenario for this set up is when you want to keep the prerequisites stack around while creating/deleting the main stack within an environment, this allows you to cut some cost and to speed up environment standing up time from the second time onward.

Create prerequisites stack which contains the instance profiles, security groups, and messaging SNS SQS resources:

    make create-full-set-prerequisites stack_prefix=<fullset_prerequisites_stack_prefix> config_path=<path/to/config/dir>

Create main stack which contains EC2 and Route53 resources:

    make create-full-set-main stack_prefix=<fullset_main_stack_prefix> prerequisites_stack_prefix=<fullset_prerequisites_stack_prefix> config_path=<path/to/config/dir>

### AEM Consolidated Architecture

<img width="500" alt="AEM Consolidated Architecture Diagram" src="https://raw.githubusercontent.com/shinesolutions/aem-aws-stack-builder/master/docs/architecture-consolidated.png"/>

Ensure [configuration file for AEM Consolidated architecture](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md) has been set up.

The simplest way to create this AEM architecture is by standing up both full set prerequisites and main stacks in one go:

    make create-consolidated stack_prefix=<consolidated_stack_prefix> config_path=<path/to/config/dir>

It is also possible to separate the prerequisites from the main stacks. A use case scenario for this set up is when you want to reuse the same prerequisites stack for multiple main stacks. Please note that having a one to many mapping between prerequisites stack to multiple main stacks is only applicable for development environments, and not for production.

Create prerequisites stack which contains the instance profiles and security groups:

    make create-consolidated-prerequisites stack_prefix=<consolidated_prerequisites_stack_prefix> config_path=<path/to/config/dir>

Create main stack which contains EC2 and Route53 resources:

    make create-consolidated-main stack_prefix=<consolidated_main_stack_prefix> prerequisites_stack_prefix=<consolidated_prerequisites_stack_prefix> config_path=<path/to/config/dir>

Testing
-------

### Testing with remote dependencies

You can run integration test for creating, testing, and deleting the AEM Stack Manager, AEM Consolidated, AEM Full-Set environments using the command `make test-integration test_id=<sometestid>`, which downloads the dependencies from the Internet.

### Testing with local dependencies

If you're working on the dependencies of AEM AWS Stack Builder and would like to test them as part of environment creation before pushing the changes upstream, you need to:

- Clone the dependency repos [AEM AWS Stack Provisioner](https://github.com/shinesolutions/aem-aws-stack-provisioner), [Puppet AEM Resources](https://github.com/shinesolutions/puppet-aem-resources), [Puppet AEM Curator](https://github.com/shinesolutions/puppet-aem-curator), [Puppet AEM Orchestrator](https://github.com/shinesolutions/puppet-aem-orchestrator), [Puppet SimianArmy](https://github.com/shinesolutions/puppet-simianarmy), [AEM Hello World Custom Stack Provisioner](https://github.com/shinesolutions/aem-helloworld-custom-stack-provisioner), [AEM Hello World Config](https://github.com/shinesolutions/aem-helloworld-config) at the same directory level as AEM AWS Stack Builder
- Make your code changes against those dependency repos
- Run `make test-integration-local test_id=<sometestid>` for integration testing using local dependencies, which copies those local dependency repos to your local AEM AWS Stack Provisioner, packages it and versioned with your `test_id`, uploads to S3, and uses them as part of the test

Presentations
-------------

* [AEM OpenCloud](https://www.slideshare.net/cliffano/aem-opencloud)
* [AEM OpenCloud - What's New Since 2.0.0](https://www.slideshare.net/cliffano/aem-opencloud-whats-new-since-200)
* [AEM Open Cloud - The First Two Years](https://www.slideshare.net/cliffano/aem-open-cloud-the-first-two-years)
* [Open Source AEM Platform: A Short Intro](https://www.slideshare.net/cliffano/open-source-aem-platform-a-short-intro-89967729)

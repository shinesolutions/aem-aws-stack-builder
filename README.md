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

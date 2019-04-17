# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## [4.0.0] - 2019-04-07

### Added
- Add CW alarm and notifications for Stack Manager Lambda function errors #210
- Add aem-password-reset bugfix to FAQ
- Add offline-snapshot/live-snapshot issue to FAQ
- Added 'aws-create-resources' and 'aws-delete-resources' skeleton to makefile
- Add new parameter to configure ASG for Publish, Author-Dispatcher & Publish-Dispatcher

### Changed
- Upgrade AEM AWS Stack Provisioner to 3.15.0
- AEM Health Check package would be provisioned as stack data regardless whether reconfiguration is enabled or not
- Snapshot backup no longer contains just repository, it now contains the whole AEM installation

### Fixed
- Fix AEM Orchestrator data device name configuration to use user config
- Fixed error in boolean hiera parameter

## [3.6.0] - 2019-02-17

### Added
- Add AEM 6.4 SP3 Bugfix to FAQ

### Changed
- Upgrade AEM AWS Stack Provisioner to 3.6.0

### Fixed
- Fix path to staging dir in Ansible playbooks
- Fixed logic error when running pre-common.sh #257


## [3.5.0] - 2019-02-04

### Changed
- Upgrade AEM AWS Stack Provisioner to 3.5.0

### Fixed
- Fix intermittent AEM 6.4 start timeout failure due to Package Manager Servlet unreadiness

### added
- Add new parameter to remove the AEM Global Trusttore during reconfiguration

## [3.4.0] - 2019-01-31

### Added
- Add new feature to enable/disable migration of AEM Global Truststore #229
- Add missing SAML configuration documentation
- Add new hiera parameter common::aws_region #187
- Add new SSM Documents for automating AEM Upgrade
- Add new configuration parameter enable_upgrade_tools
- Add customisable cipher suite for ELBs #223
- Add new feature to configure AEM Apache http proxy configurator settings #235
- Add new parameters for all image device names
- Add new heira parameters for image device names
- Add new configuration parameters for post start sleep timer to give the AEM service more time to start before configuring AEM #214
- Add Amazon Linux 2 OS type support

### Changed
- Update deployment descriptor documentation for uninstall package feature #224
- Upgrade AEM Stack Manager to 1.3.2
- Upgrade AEM AWS Stack Provisioner to 3.4.0

## [3.3.1] - 2018-12-06

### Changed
- Upgrade AEM AWS Stack Provisioner to 3.3.1, AEM Stack Manager Messenger to 1.5.8, AEM Test Suite to 0.9.10

## [3.3.0] - 2018-11-30

### Added
- Add configuration parameters for configuring SAML authentication
- Add configuration parameters for configuring AEM Truststore
- Add configuration parameters for configuring AEM Authorizable Keystores

### Changed
- Update Stack Manager events for Offline-Snapshot & offline-compaction-snapshot to enable scheduling feature #182
- Extend schedule snapshot stack manager event to un/schedule live snapshots #212
- Upgrade AEM AWS Stack Provisioner to 3.3.0 and AEM Stack Manager Messenger to 1.5.7

## [3.2.1] - 2018-10-22

### Added
- Add Scripts to support the AEM64 Upgrade for consolidated & full-set
- Add new configuration properties aem: aem.enable_bak_files_cleanup, aem.bak_files_cleanup_max_age_in_days
- Add configuration parameters to configure wait until login page is ready during Stack Provisioning #184
- Add configuration parameters to enable random termination for each component except Author

### Changed
- Upgrade AEM AWS Stack Provisioner to 3.2.0 and AEM Stack Manager to 1.5.6
- Change default JMX ports to 5982 for AEM Author and 5983 for AEM Publish #213
- Update deprecated ansible s3 module references to aws_s3. #188
- Change default AEM Publish-Dispatcher max ASG size to 4
- Change security_groups.private_subnet_internet_outbound_cidr_ip configuration to be mandatory
- Change default security_groups.author_dispatcher_elb.extra_groups and security_groups.publish_dispatcher_elb.extra_groups to be empty
- Enforce default Java to use Oracle JDK

### Removed
- Remove deprecated configuration properties: instance_profile_stack_prefix, security_groups_stack_prefix, instance_profiles.stack_name, instance_profiles.stack_manager, security_groups.stack_name, security_groups.*.tag_name, messaging.stack_name, messaging.alarm_notification.topic_name, <component>.stack_name, <component>.tag_name, <component>.instance_profile, <component>.certificate_name, messaging.stack_name, hosted_zone

## [3.1.1] - 2018-09-12

### Added
- Add output redirection in Cloudformation templates for SSM Commands Offline Snapshot, Offline Compaction Snapshot, manage service & wait until ready
- Add new parameters to enable removing of old bak files in AEM repository

### Changed
- Lock awscli version to 1.16.10, boto3 to 1.8.5, ansible to 2.8.5
-

## [3.1.0] - 2018-08-19

### Added
- Add new configuration parameters to enabling support for reconfigure existing AEM installation
- Add new SSM Document aem-reconfiguration
- Add System Users parameters in configuration
- Add export import package to integration test

### Changed
- Update description for SSM Document install-aem-profile
- Change package installation and compaction related timeouts to 2 hours, service status check to 10 minutes
- Upgrade AEM AWS Stack Provisioner to 3.1.2
- Update default publish dispatcher log rotation config to rotate every hour

## [3.0.0] - 2018-07-17

### Added
- Add support for using snapshots containing repository with non AEM OpenCloud ownership

### Changed
- Upgrade AEM AWS Stack Provisioner to 3.x and AEM Orchestrator to 2.x for AEM 6.4 support
- Upgrade AEM Password Reset to 1.1.0 for AEM 6.4 support

### Removed
- Remove attachment of Bastion Host security group from all ELBs

## [2.3.2] - 2018-07-23

### Added
- Add support for using snapshots containing repository with non AEM OpenCloud ownership
- Add support for any number of availability zones during VPC and network provisioning #159
- Add metadata file creation for each artifact uploaded using Makefile library target #114
- Add library.aem_healthcheck_version configuration property
- Add new SSM Document install-aem-profile
- Add AEM Stack Manager Cloud to local integration test

### Changed
- Upgrade AEM AWS Stack Provisioner to 3.1.1

### Removed
- Move Custom Stack Provisioner pre step to be after facts provisioning

## [2.3.0] - 2018-07-03

### Added
- Add integration testing support using configured libraries

### Changed
- Upgrade AEM AWS Stack Provisioner to 2.6.0
- Change s3 bucket presence check to inspect the content of the bucket

## [2.2.1] - 2018-08-03

### Added
- Add configuration chaos_monkey.include_stack to include/exclude Chaos Monkey nested stack
- Add AEM version and OS type support to local integration testing
- Add configurable chaos monkey settings

### Changed
- Change snapshots.author.use_data_vol_snapshot and snapshots.publish.use_data_vol_snapshot configuration properties to accept boolean

## [2.2.0] - 2018-06-04

### Added
- Add feature to configure Logrotation per component or/and per stack
- Add cron.no_proxy configuration support

### Changed
- Stack Manager main stack name is now configurable via scheduled_jobs.aem_orchestrator.stack_manager_pair.stack_name config
- Increase default deployment delay to 60, check retries to 120, and check delay to 15
- Improve network-exports to support subnets list instead of predefined subnet A and subnet B #79
- Offline compaction scheduled job on Author Primary and Publish is disabled by default
- Revert snapshot is disabled by default

### Removed
- Move Stack Manager SSM stack to become a nested/child stack of Stack Manager main stack #149
- Remove unused aem.deployment_post_install_wait_in_seconds configuration property

## [2.1.1] - 2018-05-19

### Added
- Add revert_snapshot_type parameter to allow default launch configuration to set snapshots to offline or live types
- Add /opt/shinesolutions/aem-aws-stack-builder/stack-init-completed as an indicator that userdata has been completed successfully
- Add stack-init completion check to all Stack Manager SSM commands

### Changed
- Restructure configuration for Stack Manager snapshots purge schedule and max age
- Set snapshots purge max age unit to hour, set schedule to cron expression without function syntax
- Simplify offline snapshot events Stack Manager pairing to use stack prefix instead of SNS topic ARN
- Replace SSM template generation shell script with ssm_template Ansible module

### Removed
- Remove global fact stack_manager_sns_topic_arn

## [2.1.0] - 2018-05-11

### Added
- Add aem.enable_content_healthcheck_terminate_instance switch for instance termination for content healthcheck alarms
- Add java_opts parameter allowing custom java_opts to be specified
- Add AuthorPublishDispatcher component
- Add configuration flag for enabling CRXDE #35
- Add configuration flag for enabling default system users password #36
- Add configuration flag for enabling package and artifacts deployment on instance initialisation
- Add JVM memory opts for AEM Author and Publish #49
- Added Repo aem-stack-manager-cloud to aem-aws-stack-builder repo #63
- Added feature for Publish Dispatcher to scale up/down if CPU is above/under configured threshold #26
- Introduce AuthorPublishDispatcherSubnetList and AuthorDispatcherELBSubnetList to network-exports #64
- Introduce Consolidated architecture stacks
- Add alarm for queue size of ASG events in Full Set architecture #70
- Add variable declaration to configure jmxremote port for Author and Publish
- Add aem.version configuration
- Add CW Alarm to monitor auto scaling messaging queue
- Add Collectd proxy configuration support
- Add library build target for downloading open source artifacts #101
- Add new command mapping for AEM Stack Manager
- Introduce permission types to support various resource restrictions
- Add Simian Army artifact to library #75
- Add support for adding extra security groups to ELBs #107
- Add aem.enable_reverse_replication configuration #117
- Add AEM package deployment wait and retry configurations #122
- Add aem.enable_content_healthcheck configuration #116
- Add ec2 delete volume permission to Publish role

### Changed
- Hieradata config file is now generated based on Ansible group vars
- Replace Serverspec with InSpec for testing #50
- Modify Full-Set architecture stacks pairing to work with network, security_groups, and instance_profile stacks
- Modify AEM Author instance's https listen port from 5433 to 5432
- Enable AutoScalingGroups metrics collection #56
- Modify cloud-init's extra local.yaml config to be appended to base local.yaml
- Set Ansible config hash behaviour to merge #108

### Removed
- Remove external package installation during cloud init #43
- Remove unnecessary sleep during cloud init #51
- Move aem_password_reset_version, aem_orchestrator_version, oak_run_version stack facts to stack-provisioner-hieradata config #11

## [2.0.0] - unknown

### Added
- Add Stack Provisioner custom hiera configuration support
- Introduce parent CloudFormation stacks to Full Set architecture
- Add Puppet exit code translation in stack-init script
- Add shortcode support to CloudFormation template global tagging

### Changed
- Replace configuration file with stack output values for environment parameters

## [1.1.2] - unknown

### Changed
- Disable generated system user credentials logging #34

## [1.1.1] - 2017-06-07

### Changed
- Update aem-aws-stack-provisioner version to 1.1.1

## [1.1.0] - 2017-06-02

### Changed
- Load Balancers and Auto Scaling Groups can now be created for a variety of network setups. i.e. 1-n Availability Zones, 1-n Subnets
- Change the Publish Auto Scaling Group to use EC2 Health Check Type
- Change the Publish Dispatcher Auto Scaling Group Health Check Grace Period from 15 minutes to 20 minutes
- Enhance the s3_copy_object script to not copy files that do not exist
- Copy content-healthcheck-descriptor from source bucket
- Update aem-orchestrator version to 1.0.0
- Update aem-aws-stack-provisioner version to 1.1.0

## [1.0.0] - 2017-05-23

### Added
- Initial version

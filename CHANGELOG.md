### 2.1.1
* Restructure configuration for Stack Manager snapshots purge schedule and max age
* Set snapshots purge max age unit to hour, set schedule to cron expression without function syntax
* Simplify offline snapshot events Stack Manager pairing to use stack prefix instead of SNS topic ARN
* Remove global fact stack_manager_sns_topic_arn
* Replace SSM template generation shell script with ssm_template Ansible module
* Add revert_snapshot_type parameter to allow default launch configuration to set snapshots to offline or live types

### 2.1.0
* Add aem.enable_content_healthcheck_terminate_instance switch for instance termination for content healthcheck alarms
* Add java_opts parameter allowing custom java_opts to be specified
* Add AuthorPublishDispatcher component
* Add configuration flag for enabling CRXDE #35
* Add configuration flag for enabling default system users password #36
* Hieradata config file is now generated based on Ansible group vars
* Add configuration flag for enabling package and artifacts deployment on instance initialisation
* Replace Serverspec with InSpec for testing #50
* Remove external package installation during cloud init #43
* Remove unnecessary sleep during cloud init #51
* Add JVM memory opts for AEM Author and Publish #49
* Fix bastion configuration passing
* Modify Full-Set architecture stacks pairing to work with network, security_groups, and instance_profile stacks
* Modify AEM Author instance's https listen port from 5433 to 5432
* Enable AutoScalingGroups metrics collection #56
* Move aem_password_reset_version, aem_orchestrator_version, oak_run_version stack facts to stack-provisioner-hieradata config #11
* Modify cloud-init's extra local.yaml config to be appended to base local.yaml
* Added Repo aem-stack-manager-cloud to aem-aws-stack-builder repo #63
* Added feature for Publish Dispatcher to scale up/down if CPU is above/under configured threshold #26
* Introduce AuthorPublishDispatcherSubnetList and AuthorDispatcherELBSubnetList to network-exports #64
* Introduce Consolidated architecture stacks
* Add alarm for queue size of ASG events in Full Set architecture #70
* Fix bug JVM Memory option not configurable for Author standby instance #72
* Add variable declaration to configure jmxremote port for Author and Publish
* Add aem.version configuration
* Add CW Alarm to monitor auto scaling messaging queue
* Add Collectd proxy configuration support
* Add library build target for downloading open source artifacts #101
* Add new command mapping for AEM Stack Manager
* Introduce permission types to support various resource restrictions
* Add Simian Army artifact to library #75
* Set Ansible config hash behaviour to merge #108
* Add support for adding extra security groups to ELBs #107
* Add aem.enable_reverse_replication configuration #117
* Add AEM package deployment wait and retry configurations #122
* Add aem.enable_content_healthcheck configuration #116
* Add ec2 delete volume permission to Publish role
* Fix permission error for Lambda function SnapshotPurge

### 2.0.0
* Add Stack Provisioner custom hiera configuration support
* Introduce parent CloudFormation stacks to Full Set architecture
* Replace configuration file with stack output values for environment parameters
* Add Puppet exit code translation in stack-init script
* Add shortcode support to CloudFormation template global tagging

### 1.1.2
* Disable generated system user credentials logging #34

### 1.1.1
* Update aem-aws-stack-provisioner version to 1.1.1

### 1.1.0
* Load Balancers and Auto Scaling Groups can now be created for a variety of network setups. i.e. 1-n Availability Zones, 1-n Subnets
* Change the Publish Auto Scaling Group to use EC2 Health Check Type
* Change the Publish Dispatcher Auto Scaling Group Health Check Grace Period from 15 minutes to 20 minutes
* Enhance the s3_copy_object script to not copy files that do not exist
* Copy content-healthcheck-descriptor from source bucket
* Update aem-orchestrator version to 1.0.0
* Update aem-aws-stack-provisioner version to 1.1.0

### 1.0.0
* Initial version

### 2.1.0
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
* Added feature for Publish Dispatcher to scale up/down if CPU is above/under configured threshold #26 
* Introduce AuthorPublishDispatcherSubnetList and AuthorDispatcherELBSubnetList to network-exports #64

### 2.0.0
* Add Stack Provisioner custom hiera configuration support
* Introduce parent CloudFormation stacks to Full Set architecture
* Replace configuration file with stack output values for environment parameters
* Add Puppet exit code translation in stack-init script

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

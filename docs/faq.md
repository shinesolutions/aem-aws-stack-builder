Frequently Asked Questions
--------------------------

* __Q:__ Why doesn't Stack Builder create and manage each S3 bucket required for storing stack state?<br/>
  __A:__ This is a due to [S3 bucket names being globally unique](https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html). Stack Builder doesn't attempt to create the S3 bucket dynamically due to the risk of the bucket name being unavailable because it's already used by another AWS account. You could argue that the probability is very low, but this is not something that needs to be risked, specially for a more conservative environment where an unintentional failure can trigger a lot of red tape processes.

* __Q:__ How to solve timeout error when deploying a large AEM package?<br/>
  __A:__ You need to increase the value of `aem.deployment_delay_in_seconds`, `aem.deployment_check_retries`, and `aem.deployment_check_delay_in_seconds` [configuration properties](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md).

* __Q:__ How to set up custom AWS tags?<br/>
  __A:__ This can be [configured](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md#aws-configuration-properties) in `aws.tags` property. For example:
  ```
  aws:
    tags:
    - Key: Project
      Value: Open Source AEM Platform
    - Key: Owner
      Value: Shine Solutions AEM Team
    - Key: Cost Centre
      Value: 12345
  ```

* __Q:__ How to check if the component provisioning has been completed successfully?<br/>
  __A:__ You can filter `aem-aws-stack-builder` keyword in `/var/log/messages` where you'll find output like the one below. The existence of `Completed <component> component initialisation` message indicates that the component provisioning has been completed successfully.
  ```
  cloud-init: [aem-aws-stack-builder] Initialising AEM Stack Builder provisioning...
  cloud-init: [aem-aws-stack-builder] AWS CLI version: <version>
  cloud-init: [aem-aws-stack-builder] Facter version: <version>
  cloud-init: [aem-aws-stack-builder] Hiera version: <version>
  cloud-init: [aem-aws-stack-builder] Puppet version: <version>
  cloud-init: [aem-aws-stack-builder] Python version: <version>
  cloud-init: [aem-aws-stack-builder] Ruby version: <version>
  cloud-init: [aem-aws-stack-builder] No Custom Stack Provisioner provided...
  cloud-init: [aem-aws-stack-builder] Downloading AEM Stack Provisioner...
  cloud-init: [aem-aws-stack-builder] Checking orchestration tags for <component> component...
  cloud-init: [aem-aws-stack-builder] Setting AWS resources as Facter facts...
  cloud-init: [aem-aws-stack-builder] Applying Puppet manifest for <component> component...
  cloud-init: [aem-aws-stack-builder] Applying post-common scheduled jobs action Puppet manifest for all components...
  cloud-init: [aem-aws-stack-builder] post-common script of Custom Stack Provisioner is either not provided or not executable
  cloud-init: [aem-aws-stack-builder] Testing <component> component using InSpec...
  cloud-init: [aem-aws-stack-builder] Cleaning up provisioner temp directory...
  cloud-init: [aem-aws-stack-builder] Completed <component> component initialisation
  ```

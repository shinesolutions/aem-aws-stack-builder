Frequently Asked Questions
--------------------------

* __Q:__ Why doesn't Stack Builder create and manage each S3 bucket required for storing stack state?<br/>
  __A:__ This is a due to [S3 bucket names being globally unique](https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html). Stack Builder doesn't attempt to create the S3 bucket dynamically due to the risk of the bucket name being unavailable because it's already used by another AWS account. You could argue that the probability is very low, but this is not something that needs to be risked, specially for a more conservative environment where an unintentional failure can trigger a lot of red tape processes.

* __Q:__ How to solve timeout error when deploying a large AEM package?<br/>
  __A:__ You need to increase the value of `aem.deployment_post_install_wait_in_seconds`, `aem.deployment_check_retries`, and `aem.deployment_check_delay_in_seconds` [configuration properties](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md).

Frequently Asked Questions
--------------------------

* __Q:__ Why doesn't Stack Builder create and manage each S3 bucket required for storing stack state?<br/>
  __A:__ This is due to [S3 bucket names being globally unique](https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html). Stack Builder doesn't attempt to create the S3 bucket dynamically due to the risk of the bucket name being unavailable because it's already used by another AWS account. You could argue that the probability is very low, but this is not something that needs to be risked, specially for a more conservative environment where an unintentional failure can trigger a lot of red tape processes.

* __Q:__ How to solve timeout error when deploying a large AEM package?<br/>
  __A:__ You need to increase the value of `aem.deployment_delay_in_seconds`, `aem.deployment_check_retries`, and `aem.deployment_check_delay_in_seconds` [configuration properties](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md). Depending on the content of the AEM package, you might also need to increase the instance type via `<component>.instance_type` .

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
  __A:__ Please follow this [AEM Environment Provisioning Troubleshooting Guide](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/troubleshooting-guide.md#aem-environment-provisioning).

* __Q:__ Why is the stack provisioning failing with the error message `unexpected response code` ?<br/>
  __A:__ This may happen as some bundles e.g. `Adobe Granite CRX Package Manager` are starting some `Declarative Service Components`. Since it may take a while until all `Declarative Service Components` are started. Though the AEM Healthcheck is showing all bundles are up and running. To give AEM more time after starting the service set the option `aem.enable_post_start_sleep` to true and modify the wait time `aem.post_start_sleep_seconds`to your own needs. AEM AWS Stack Builder will always attempt to code the readiness check that might come up in the future, however, if you have some custom scenario that's not handled by this library, you have to resort to enabling the post start sleep.

 * __Q:__ Why does create CloudFormation stack build fail with error `Export with name <stack_prefix>-InstanceProfilesStackName is already exported by stack <stack_prefix>-<stack_nanme>-stack` ?<br/>
  __A:__ This happens when we use a stack prefix which has been used by another CloudFormation stack, regardless whether they are of the same environment type (whether it be AEM Stack Manager, AEM Full-Set, or AEM Consolidated) or not.

* __Q:__ What values should I put in the deployment descriptor's package `group`, `name`, and `version`?<br/>
  __A:__ Have a look at `META-INF/vault/properties.xml` in the AEM package zip file, you can find the entry keys `group`, `name`, and `version`, which values you should supply in the deployment descriptor. Please also note that the file name must be formatted as `<name>-<version>.zip` . This consistency is important to ensure that the physical file to be deployed is actually the one expected as defined in the deployment descriptor.

* __Q:__ Why am I getting the error message `/libs/cq/gui/components/siteadmin/admin/properties/include/include.jsp(18,2) File "../FilteringResourceWrapper.jsp" not found...` when I try to edit page properties after Installing AEM 6.4 SP3 ?<br/>
 __A:__ This happens after installing AEM 6.4 SP3 on top of AEM 6.4 SP2. Following error message appears:
 `Cannot serve request to /mnt/overlay/wcm/core/content/sites/properties.html in /libs/cq/gui/components/siteadmin/admin/properties/include/include.jsp
 Exception:
 org.apache.sling.scripting.jsp.jasper.JasperException: /libs/cq/gui/components/siteadmin/admin/properties/include/include.jsp(18,2) File "../FilteringResourceWrapper.jsp" not found[...]`

  This is a known issue in [AEM 6.4 SP3](https://helpx.adobe.com/experience-manager/6-4/release-notes/sp-release-notes.html#KnownIssues) and happens if you install AEM 6.4 SP3 on top of AEM 6.4 SP2. This is caused as the files `/libs/cq/gui/components/siteadmin/admin/properties/FilteringResourceWrapper.jsp` and `/libs/cq/gui/components/siteadmin/admin/properties/inclduewrapper` don't exists anymore. To solve this issue you have to reinstall the package `cq-ui-wcm-admin-content-1.0.1004.zip`. For reinstallation please add following into your deployment-descriptor file:

  Author:
  ```
  {
     "ensure": "reinstall",
     "source": "",
     "group
     ": "day/cq60/product",
     "name": "cq-ui-wcm-admin-content",
     "version": "1.0.1004",
     "replicate": false,
     "activate": false,
     "force": true,
     "aem_id": "author",
     "sleep_seconds": "120",
  }
  ```
  Publish:
  ```
  {
     "ensure": "reinstall",
     "source": "",
     "group": "day/cq60/product",
     "name": "cq-ui-wcm-admin-content",
     "version": "1.0.1004",
     "replicate": false,
     "activate": false,
     "force": true,
     "aem_id": "publish",
     "sleep_seconds": "120",
  }
  ```

# Frequently Asked Questions

- **Q:** Why doesn't Stack Builder create and manage each S3 bucket required for storing stack state?<br>
  **A:** This is due to [S3 bucket names being globally unique](https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html). Stack Builder doesn't attempt to create the S3 bucket dynamically due to the risk of the bucket name being unavailable because it's already used by another AWS account. You could argue that the probability is very low, but this is not something that needs to be risked, specially for a more conservative environment where an unintentional failure can trigger a lot of red tape processes.

- **Q:** How to solve timeout error when deploying a large AEM package?<br>
  **A:** You need to increase the value of `aem.deployment_delay_in_seconds`, `aem.deployment_check_retries`, and `aem.deployment_check_delay_in_seconds` [configuration properties](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md). Depending on the content of the AEM package, you might also need to increase the instance type via `<component>.instance_type` .

- **Q:** How to set up custom AWS tags?<br>
  **A:** This can be [configured](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md#aws-configuration-properties) in `aws.tags` property. For example:

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

- **Q:** How to check if the component provisioning has been completed successfully?<br>
  **A:** Please follow this [AEM Environment Provisioning Troubleshooting Guide](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/troubleshooting-guide.md#aem-environment-provisioning).

- **Q:** Why is the stack provisioning failing with the error message `unexpected response code` ?<br>
  **A:** This may happen as some bundles e.g. `Adobe Granite CRX Package Manager` are starting some `Declarative Service Components`. Since it may take a while until all `Declarative Service Components` are started. Though the AEM Healthcheck is showing all bundles are up and running. To give AEM more time after starting the service set the option `aem.enable_post_start_sleep` to true and modify the wait time `aem.post_start_sleep_seconds`to your own needs. AEM AWS Stack Builder will always attempt to code the readiness check that might come up in the future, however, if you have some custom scenario that's not handled by this library, you have to resort to enabling the post start sleep.

  - **Q:** Why does create CloudFormation stack build fail with error `Export with name <stack_prefix>-InstanceProfilesStackName is already exported by stack <stack_prefix>-<stack_nanme>-stack` ?<br>
    **A:** This happens when we use a stack prefix which has been used by another CloudFormation stack, regardless whether they are of the same environment type (whether it be AEM Stack Manager, AEM Full-Set, or AEM Consolidated) or not.

- **Q:** What values should I put in the deployment descriptor's package `group`, `name`, and `version`?<br>
  **A:** Have a look at `META-INF/vault/properties.xml` in the AEM package zip file, you can find the entry keys `group`, `name`, and `version`, which values you should supply in the deployment descriptor. Please also note that the file name must be formatted as `<name>-<version>.zip` . This consistency is important to ensure that the physical file to be deployed is actually the one expected as defined in the deployment descriptor.

- **Q:** Why am I getting the error message `/libs/cq/gui/components/siteadmin/admin/properties/include/include.jsp(18,2) File "../FilteringResourceWrapper.jsp" not found...` when I try to edit page properties after Installing AEM 6.4 SP3 ?<br>
  **A:** This happens after installing AEM 6.4 SP3 on top of AEM 6.4 SP2\. Following error message appears: `Cannot serve request to /mnt/overlay/wcm/core/content/sites/properties.html in /libs/cq/gui/components/siteadmin/admin/properties/include/include.jsp Exception: org.apache.sling.scripting.jsp.jasper.JasperException: /libs/cq/gui/components/siteadmin/admin/properties/include/include.jsp(18,2) File "../FilteringResourceWrapper.jsp" not found[...]`

  This is a known issue in [AEM 6.4 SP3](https://helpx.adobe.com/experience-manager/6-4/release-notes/sp-release-notes.html#KnownIssues) and happens if you install AEM 6.4 SP3 on top of AEM 6.4 SP2\. This is caused as the files `/libs/cq/gui/components/siteadmin/admin/properties/FilteringResourceWrapper.jsp` and `/libs/cq/gui/components/siteadmin/admin/properties/inclduewrapper` don't exists anymore. To solve this issue you have to reinstall the package `cq-ui-wcm-admin-content-1.0.1004.zip`. For reinstallation please add following into your deployment-descriptor file:

  Author:

  ```
  {
     "ensure": "reinstalled",
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
     "ensure": "reinstalled",
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

- **Q:** Why does the offline-snapshot/live-snapshot fails after 10 minutes ?<br>
  **A:** If the snapshotting for AEM-OpenCloud takes longer than `10 minutes`, the snapshotting will fail. Unfortunately this is a known limitation at the moment and already documented here <https://github.com/shinesolutions/aem-aws-stack-provisioner/issues/121>.

- **Q:** Why did the Stack Provisioning failed with error code `500` at the step `Stop webdav bundle` ?<br>
  **A:** Please check the `error.log` for following messages `org.apache.sling.auth.core.impl.SlingAuthenticator handleLoginFailure: Unable to authenticate admin: UserId/Password mismatch`. This means the aem-password-reset bundle was not able to reset the passwords of the system-users. Most likely it's because the whitelisting for the bundle hasn't been done before the start of the bundle. In the `error.log` you will find messages similar like this

  ```
  *ERROR* [OsgiInstallerImpl] com.adobe.granite.repository.impl.SlingRepositoryImpl Bundle com.shinesolutions.aem.passwordreset is NOT whitelisted to use SlingRepository.loginAdministrative
  ```

  Whitelisting messages are looking like these

  ```
   25.02.2019 11:50:16.748 *INFO* [CM Event Dispatcher (Fire ConfigurationEvent: pid=org.apache.sling.jcr.base.internal.LoginAdminWhitelist.fragment.191f7c8a-eb98-4edf-a062-c4bd790bc610)] org.apache.sling.jcr.base Service [org.apache.sling.jcr.base.internal.LoginAdminWhitelist.fragment.191f7c8a-eb98-4edf-a062-c4bd790bc610,7337, [org.apache.sling.jcr.base.internal.WhitelistFragment]] ServiceEvent REGISTERED
  25.02.2019 11:50:16.749 *INFO* [CM Event Dispatcher (Fire ConfigurationEvent: pid=org.apache.sling.jcr.base.internal.LoginAdminWhitelist.fragment.191f7c8a-eb98-4edf-a062-c4bd790bc610)] org.apache.sling.jcr.base.internal.LoginAdminWhitelist WhitelistFragment added 'passwordreset: [com.shinesolutions.aem.passwordreset]'
  ```

  To solve this issue you have to place the whitelist configuration in the `/install` dir of the AEM instance e.g. `/opt/aem/author/crx-quickstart/install`.

  Filename:

  ```
  org.apache.sling.jcr.base.internal.LoginAdminWhitelist.fragment-passwordreset.config
  ```

  Filecontent:

  ```
  whitelist.name="passwordreset"
  whitelist.bundles=["com.shinesolutions.aem.passwordreset"]
  ```

- **Q:** Why did the filesystem structure changed with Packer-AEM 3.8.0 & aem-aws-stack-provisioner 3.12.0 ?<br>
  **A:** AEM 6.4 requires that the repository and AEM Installation are living together, as you may run into some unexplaining AEM Startup problems. This required us to change the filesystem structure in AEM OpenCloud. From Packer-AEM 3.8.0 & aem-aws-stack-provisioner 3.12.0 on, the AEM installation and the AEM repository are no longer separated from each other. This might change your backup/recovery scenarios and makes the AEM-OpenCloud v2 snapshots incompatible to AEM-OpenCloud v3 and therefor they need to be migrated.

Old FS structure | New Author FS structure           | New Publish FS structure
:--------------- | :-------------------------------- | :---------------------------------
/blobids         | /author                           | /publish
/datastore       | /author/crx-quickstart            | /publish/crx-quickstart
/index           | /author/crx-quickstart/repository | /publish/crx-quickstart/repository
/segmentstore    | /author/crx-quickstart/install    | /publish/crx-quickstart/install
/...             | /author/crx-quickstart/logs       | /publish/crx-quickstart/logs
.                | /author/crx-quickstart/...        | /publish/crx-quickstart/...

This table shows the compatibility of the FS structure and each AEM OpenCloud component versions:

Compatibility    | Packer-AEM | AEM-AWS-Stack-Builder | AEM-AWS-Stack-Provisioner
:--------------- | :--------- | :-------------------- | :------------------------
Old FS structure | <= 3.7.0   | <= 3.6.0              | <= 3.11.0
New FS structure | >= 3.8.0   | >= 3.7.0              | >= 3.12.0

To create a stack with the old FS structure you need AMIs created with Packer-AEM 3.7.0 or below and AEM-AWS-Stack-Builder 3.6.0 or below together with AEM-AWS-Stack-provisioner 3.11.0 or below.

- **Q:** When do I need to use the `reconfiguration` feature ?<br>
  **A:** The purpose of the `reconfiguration` feature is to reset the AEM installation. You need to enable the reconfiguration when you want to...

  * migrate non AEM-OpenCloud installations to AEM-OpenCloud
  * migrate older AEM-OpenCloud installations to the latest version
  * reset AEM-OpenCloud installations to make them useable for different environments

  More informations of how to use the reconfiguration can be found in the FAQ topic `How do I use the reconfiguration ?` & `How does the reconfiguration works ?`.

- **Q:** How do I use the reconfiguration ? <br>
  **A:** The recommended way of using the reconfiguration is as follows...

  * make sure the snapshots are containing the correct FS structure(old or new)
  * Create configuration profile for reconfiguration
  * Create AEM Stack with the configuration profile
  * Run `offline-snapshot` or `offline-compaction-snapshot`

  **Correct FS Structure:**

  Make sure that your snapshots contain the correct FS structure as described in the FAQ topic ```Why did the filesystem structure changed with Packer-AEM 3.8.0 & aem-aws-stack-provisioner 3.12.0 ?```

  **Create configuration profile:**

  Create a configuration profile where the reconfiguration is enabled. It may look similar like this example
  ```
  aem:
    enable_reconfiguration: true

  reconfiguration:
    enable_truststore_removal: true
    enable_truststore_migration: false
    certificate_arn: s3://aem-opencloud/artifacts/ssl/aem.certs
    certificate_key_arn: s3://aem-opencloud/artifacts/ssl/aem.key
    ssl_keystore_password: changeit
    author:
      run_modes: []
    publish:
      run_modes: []

  system_users:
    author:
      admin:
        name: admin
        path: overwrite-me
      deployer:
        name: deployer
        path: /home/users/q
      exporter:
        name: exporter
        path: /home/users/e
      importer:
        name: importer
        path: /home/users/i
      orchestrator:
        name: orchestrator
        path: /home/users/o
      replicator:
        name: replicator
        path: /home/users/r
    publish:
      admin:
        name: admin
        path: overwrite-me
      deployer:
        name: deployer
        path: /home/users/q
      exporter:
        name: exporter
        path: /home/users/e
      importer:
        name: importer
        path: /home/users/i
      orchestrator:
        name: orchestrator
        path: /home/users/o
      replicator:
        name: replicator
        path: /home/users/r

  ```

  This configuration profile will...
  * Remove the AEM Global Truststore
  * Configure SSL by using the public certificate & the private key as described in the configuration parameters `reconfiguration.certificate_arn` & `reconfiguration.certificate_key_arn`
  * configure the system users `admin, deployer, exporter, importer, orchestrator & replicator`

  All configuration parameters for the reconfiguration can be found in the  [configuration documentation](configuration.md).

  **Create AEM Stack:**

  We highly recommend to create a consolidated AEM Stack, as it saves money and there is no need to create a Full-Set Stack for the reconfiguration.

  **Run offline-snapshot or offline-compaction-snapshot:**

  Trigger the `offline-snapshot` or `offline-compaction-snapshot` jobs, so the reconfigured AEM installation is available as snapshots which can than be used to create new AEM Stacks.

  After the snapshots were taken there is no need to run the reconfiguration again unless you want to use snapshots from different environments.

  An example could be to provide developers with the latest production content, the reconfiguration can run each night in the dev environment and provides the developers in the morning with the latest production content in their environment.


- **Q:** How does the reconfiguration works ? <br>
  **A:** The process of the reconfiguration is as follows:

    The first step is the execution of the pre-reconfiguration. The pre-reconfiguration does all the required activities while AEM needs to be in the stopped state.
    * Checking the FS structure
    * If old FS structure detected, run FS migration
    * resetting `crx-quickstart/bin/start` & `crx-quickstart/bin/start-env` with the parameters defined in the configuration profile
    * Downloading SSL certificates for AEM

    The second step is the reconfiguration. This step is done while AEM is up and running.
    * Remove configurations from `/app/system/config`, `/app/system/config.author)` & `/app/system/config.publish`
    * Remove AEM Global Truststore (Only if removing enabled & migration disabled)
    * Cleanup `crx-quickstart/install`
    * Install AEM Healthcheck
    * Configure AEM
    * Migrate AEM Global Truststore (Only if migration enabled and removing disabled)

    This process makes sure that all configuration done with AEM OpenCloud are getting reseted and the new AEM Stack will have all it's own environment specific parameters.

- **Q:** Why does the configuration parameters `system_users` are now configurable per component ? <br>
  **A:** The configuration parameter `system_users` changed as the user path of the AEM System Users can be different on each component. E.g. the admin user is controlled by AEM [Link](https://helpx.adobe.com/experience-manager/6-3/sites/administering/using/security.html#UsersandGroupsinAEM), therefore the user path of the admin user is different on each AEM environment.


- **Q:** Why does provisioning fail while changing the admin user password in AEM ? <br>
  **A:** The provisioning process ```"[author|publish]: Set admin password for current stack"``` ([Link](https://github.com/shinesolutions/puppet-aem-curator/blob/master/manifests/config_aem_system_users.pp#L48)) can fail, when the user path of the `admin` user is not correct in the configuration profile([Author](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/conf/ansible/inventory/group_vars/apps.yaml#L180)|[Publish](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/conf/ansible/inventory/group_vars/apps.yaml#L207)).

  To check the path you need to configure you can either look in the repository at `/home/users` or search for the `admin` user in [useradmin](http://localhost:4502/useradmin).


- **Q:** What JDK version does AEM OpenCloud support ?<br>
  **A:** AEM OpenCloud supports Oracle Java JDK 8 from update 171 onwards.

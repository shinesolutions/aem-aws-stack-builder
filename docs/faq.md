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

- **Q:** How can I migrate my non-AEM-OpenCloud snapshots to AEM-OpenCloud ?<br>
  **A:** If your snapshots are already containing the new or old FS structure you are lucky and just need to create a AEM Stack with enabled reconfiguration in the configuration profile.

  If your FS has a different structure you need to manually restructure your FS before you can create a AEM Stack with AEM-OpenCloud. If you are migrating from AEM64 we recommend you to follow the new FS structure.

  In both cases you need to enable the reconfiguration in the configuration profile of your AEM environment before creating a AEM stack.

  ```
  aem:
    enable_reconfiguration: true

  reconfiguration:
    enable_create_system_users: true
    enable_truststore_removal: true
    enable_truststore_migration: false
    certs_base: s3://aem-opencloud/artifacts/ssl
    ssl_keystore_password: changeit

  system_users:
    admin:
      name: admin
      path: /home/users/d
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

  During the reconfiguration AEM OpenCloud will check if the FS contains the new structure. If not it will assume that the FS contains only the repository and therefore it tries to

  - Backup the current FS
  - Copy the AEM Installation following the new FS structure
  - Copy the backup to the new location `crx-quickstart/repository`

  Snapshots which are already AEM-OpenCloud compatible do not need to reconfigure again, unless you want to make them available for other stages. Further informations can be found at the section `How can I make my AEM-OpenCloud snapshots compatible for other stages ?`

- **Q:** How can I migrate my AEM-OpenCloud v2 snapshot to the latest AEM-OpenCloud v3 version ?<br>
  **A:**

  - Enable reconfiguration in configuration profile

    ```
    aem:
    enable_reconfiguration: true
    ```

  - Create AEM Stack with attached snapshots on AMIs created with Packer-AEM prior version 3.7.2.

  - Check Readiness of the AEM Stack

  - Run Offline-Snapshot or Offline-Compaction-Snapshot

  - Use new snapshots to create new environments with latest AEM-AWS-Stack-Builder and Packer-AEM.

  To save your money and time we recommend to run the reconfiguration on a consolidated AEM stack on a nightly base in your favourite CI/CD tool.

- **Q:** How can I make my AEM-OpenCloud snapshots compatible for other stages ?<br>
  **A:** Your snapshots may has some configuration which are specific to a stage. To make these snapshots usable for other stages you can enable the reconfiguration during stack creation. The reconfiguration will remove all configuration stored at `/apps/system/config`. The reconfiguration can be enabled in the configuration profile.

  ```
  aem:
    enable_reconfiguration: true
  ```

  To save your money and time we recommend you to run the reconfiguration on a consolidated AEM stack on a nightly base in your favourite CI/CD tool. A pipeline in your CI/CD tool can contain the following processes:

  - Create AEM Stack
  - Check Readiness of the AEM Stack
  - Run Offline-Snapshot or Offline-Compaction-Snapshot
  - Delete AEM Stack

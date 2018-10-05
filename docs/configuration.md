Configuration
-------------

The following configurations are available for users to customise the creation process and the resulting machine images.

Check out the [example configuration files](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/examples/user-config/) as reference.

### Global configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| main.stack_name | The stack name (to be appended to stack prefix) of the main parent stack of the corresponding architecture | Mandatory | |
| prerequisites.stack_name | The stack name (to be appended to stack prefix) of the prerequisites parent stack of the corresponding architecture | Mandatory for AEM Consolidated and AEM Full-Set architectures, not needed for AEM Stack Manager | |
| proxy.enabled | If true, then web proxy will be used during provisioning steps. Note: this web proxy setting is not used for cron jobs | Optional | `false` |
| proxy.protocol | Web proxy server protocol used during provisioning steps | Optional | None |
| proxy.host | Web proxy server host used during provisioning steps | Optional | None |
| proxy.port | Web proxy server port number used during provisioning steps | Optional | None |
| cron.env_path | Executable path used when running cron jobs. | Optional | `/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin` |
| cron.http_proxy | Web proxy server for http URLs, e.g. `http://someproxy:3128`, leave empty if the cron job needs to directly connect to the Internet. | Optional | None |
| cron.https_proxy | Web proxy server for https URLs, e.g. `http://someproxy:3128`, leave empty if the cron job needs to directly connect to the Internet. | Optional | None |
| cron.no_proxy | A comma separated value of domain suffixes that you don't want to use with the web proxy, e.g. `localhost,127.0.0.1` | Optional | None |

### AEM configuration properties:

| Name | Description | Required? | Default |
|------|-------------| -----------|---------|
| aem.enable_reverse_replication | If true, reverse replication from AEM Publish to AEM Author will be enabled (Full-Set only) | Optional | true |
| aem.deployment_delay_in_seconds | The number of seconds delay after AEM package deployment upload/installation, before resuming to perform health checks | Optional | 60 |
| aem.deployment_check_retries | The maximum number of times AEM package deployment upload/installation/health status will be checked | Optional | 120 |
| aem.deployment_check_delay_in_seconds | The number of seconds delay before retrying the deployment status check | Optional | 15 |
| aem.login_ready_max_tries | The number of times AEM login page will be checked | Optional | 60 |
| aem.login_ready_base_sleep_seconds | The number of seconds to wait at least before retrying the login page ready check | Optional | 5 |
| aem.login_ready_max_sleep_seconds | The number of seconds to wait maximum before retrying the login page ready check | Optional | 10 |
| library.oak_run_version | The version number of [Oak Run](https://github.com/apache/jackrabbit-oak/blob/trunk/oak-run/README.md) library. This version number must be compatible with the AEM version that you're using. Oak Run version numbers are available from [Maven repository](https://mvnrepository.com/artifact/org.apache.jackrabbit/oak-run) | Mandatory | |
| library.aem_healthcheck_version | The version number of [AEM Health Check](https://github.com/shinesolutions/aem-healthcheck) library. This version number will be used during Stack Manager event for reconfiguring AEM, which will provision AEM Health Check. | Optional | |

### AEM Full-Set specific configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| aem.enable_content_healthcheck | If true, content health check will be performed from each AEM Publish-Dispatcher instance, checking the content on its AEM Publish instance pair | Optional | true |
| aem.revert_snapshot_type | Sets the Publisher launch configuration's default snapshot ID. Valid values are `offline` or `live`. If no value is set, it default to `offline`. | Optional | `offline` |
| scheduled_jobs.aem_orchestrator.stack_manager_pair.stack_prefix | The stack prefix of the Stack Manager pair which will be used by the AEM environment to execute offline snapshot and offline compaction snapshot events. Failing to configure this, those events will not be executed | Mandatory | |
| scheduled_jobs.aem_orchestrator.stack_manager_pair.stack_name | The main stack name of the Stack Manager pair which will be used by the AEM environment to execute offline snapshot and offline compaction snapshot events | Optional | aem-stack-manager-main-stack |

### AEM Stack Manager configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| stack_manager.purge.live_snapshots.schedule | [Lambda cron expression](https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html) | Optional | 10 20 1/3 * ? * |
| stack_manager.purge.live_snapshots.max_age_in_hours | The number of hours to keep a live snapshot before it expires and will be removed | Optional | 24 |
| stack_manager.purge.offline_snapshots.schedule | [Lambda cron expression](https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html) | Optional | 15 19 ? * SUN * |
| stack_manager.purge.offline_snapshots.max_age_in_hours | The number of hours to keep an offline snapshot before it expires and will be removed  | Optional | 61320 |
| stack_manager.purge.orchestration_snapshots.schedule | [Lambda cron expression](https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html) | Optional | 5 0/4 * * ? * |
| stack_manager.purge.orchestration_snapshots.max_age_in_hours | The number of hours to keep an orchestration snapshot before it expires and will be removed  | Optional | 4 |

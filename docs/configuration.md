Configuration
-------------

The following configurations are available for users to customise the creation process and the resulting machine images.

Check out the [example configuration files](https://github.com/shinesolutions/packer-aem/blob/master/examples/user-config/) as reference.

### Global configuration properties:

| Name | Description |
|------|-------------|
| todo | TODO |

### AEM configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| aem.enable_reverse_replication | If true, reverse replication from AEM Publish to AEM Author will be enabled (Full-Set only) | Optional | true |
| aem.deployment_post_install_wait_in_seconds | The number of seconds after AEM package installation, before resuming to perform health checks | Optional | 10 |
| aem.deployment_check_retries | The maximum number of times AEM package deployment upload/installation/health status will be checked | Optional | 60 |
| aem.deployment_check_delay_in_seconds | The number of seconds delay before retrying the deployment status check | Optional | 5 |

### AEM Full-Set specific configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| aem.enable_content_healthcheck | If true, content health check will be performed from each AEM Publish-Dispatcher instance, checking the content on its AEM Publish instance pair | Optional | true |
| scheduled_jobs.aem_orchestrator.stack_manager_pair.stack_prefix | The stack prefix of the Stack Manager pair which will be used by the AEM environment to execute offline snapshot and offline compaction snapshot events. Failing to configure this, those events will not be executed | Mandatory | |

### AEM Stack Manager configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| stack_manager.purge.live_snapshots.schedule | [Lambda cron expression](https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html) | Optional | `10 20 1/3 * ? *` |
| stack_manager.purge.live_snapshots.max_age_in_hours | The number of hours to keep a live snapshot before it expires and will be removed | Optional | `24` |
| stack_manager.purge.offline_snapshots.schedule | [Lambda cron expression](https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html) | Optional | `15 19 ? * SUN *` |
| stack_manager.purge.offline_snapshots.max_age_in_hours | The number of hours to keep an offline snapshot before it expires and will be removed  | Optional | `61320` |
| stack_manager.purge.orchestration_snapshots.schedule | [Lambda cron expression](https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html) | Optional | `5 0/4 * * ? *` |
| stack_manager.purge.orchestration_snapshots.max_age_in_hours | The number of hours to keep an orchestration snapshot before it expires and will be removed  | Optional | `4` |

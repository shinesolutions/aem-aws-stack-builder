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

### AEM Stack Manager configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| snapshots_purge.live_snapshots.schedule | | Optional | `10 20 1/3 * ? *` |
| snapshots_purge.offline_snapshots.schedule | | Optional | `15 19 ? * SUN *` |
| snapshots_purge.orchestration_snapshots.schedule | | Optional | `5 0/4 * * ? *` |
| snapshots_purge.live_snapshots.expiry | | Optional | `1d` |
| snapshots_purge.offline_snapshots.expiry | | Optional | `364w` |
| snapshots_purge.o| | Optional | `4h` |

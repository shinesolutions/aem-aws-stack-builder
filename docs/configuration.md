Configuration
-------------

The following configurations are available for users to customise the creation process and the resulting machine images.

Check out the [example configuration files](https://github.com/shinesolutions/packer-aem/blob/master/examples/user-config/) as reference.

**Global configuration properties:**

| Name | Description |
|------|-------------|
| todo | TODO |

**AEM configuration properties:**

| Name | Description | Default |
|------|-------------|---------|
| aem.enable_reverse_replication | If true, reverse replication from AEM Publish to AEM Author will be enabled (Full-Set only) | true |
| aem.deployment_post_install_wait_in_seconds | The number of seconds after AEM package installation, before resuming to perform health checks | 10 |
| aem.deployment_check_retries | The maximum number of times AEM package deployment upload/installation/health status will be checked | 60 |
| aem.deployment_check_delay_in_seconds | The number of seconds delay before retrying the deployment status check | 5 |

**AEM Full-Set specific configuration properties:**

| aem.enable_content_healthcheck | If true, content health check will be performed from each AEM Publish-Dispatcher instance, checking the content on its AEM Publish instance pair | true |

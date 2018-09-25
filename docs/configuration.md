Configuration
-------------

The following configurations are available for users to customise the creation process and the resulting machine images.

Check out the [example configuration files](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/examples/user-config/) as reference.

### Global configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| aws.region | [AWS region name](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) | Optional | `ap-southeast-2` |
| aws.availability_zone_list | Comma separated list of [AWS availability zones](https://howto.lintel.in/list-of-aws-regions-and-availability-zones/) within the region defined in `aws.region` . | Optional | `ap-southeast-2a, ap-southeast-2b` |
| proxy.enabled | If true, then web proxy will be used during provisioning steps. Note: this web proxy setting is not used for cron jobs | Optional | `false` |
| proxy.protocol | Web proxy server protocol used during provisioning steps | Optional | None |
| proxy.host | Web proxy server host used during provisioning steps | Optional | None |
| proxy.port | Web proxy server port number used during provisioning steps | Optional | None |
| cron.env_path | Executable path used when running cron jobs. | Optional | `/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin` |
| cron.http_proxy | Web proxy server for http URLs, e.g. `http://someproxy:3128`, leave empty if the cron job needs to directly connect to the Internet. | Optional | None |
| cron.https_proxy | Web proxy server for https URLs, e.g. `http://someproxy:3128`, leave empty if the cron job needs to directly connect to the Internet. | Optional | None |
| cron.no_proxy | A comma separated value of domain suffixes that you don't want to use with the web proxy, e.g. `localhost,127.0.0.1` | Optional | None |

### Network configuration properties

| Name | Description | Required? | Default |
|------|-------------| ----------|---------|
| network.stack_name | The stack name (to be appended to stack prefix) of the network stack where the VPC will reside. | Optional | `aem-network-stack` |
| network.internet_gateway.tag_name | Internet gateway's name, to be appended to stack prefix. Set as `Name` tag. | Optional | `AEM VPC Internet Gateway` |
| network.publish_dispatcher_elb.<availability_zone>.cidr_block | [CIDR block](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html#vpc-subnet-basics) for the subnet where the ELB sitting in front of `publish-dispatcher` component will run on. | Mandatory | |
network.publish_dispatcher_elb.<availability_zone>.tag_name | Name of the subnet where the ELB sitting in front of `publish-dispatcher` component will run on, to be appended to stack prefix. Set as `Name` tag. | Optional | `AEM Publish Dispatcher ELB Subnet [A-Z]` |
network.publish_dispatcher.<availability_zone>.cidr_block | CIDR block for the subnet where the `publish-dispatcher` component will run on. | Mandatory | |
network.publish_dispatcher.<availability_zone>.tag_name | Name of the subnet where the `publish-dispatcher` component will run on, to be appended to stack prefix. Set as `Name` tag. | Optional | `AEM Publish Dispatcher Subnet [A-Z]` |
network.publish.<availability_zone>.cidr_block | CIDR block for the subnet where the `publish` component will run on. | Mandatory | |
network.publish.<availability_zone>.tag_name | Name of the subnet where the `publish` component will run on, to be appended to stack prefix. Set as `Name` tag. | Optional | `AEM Publish Subnet [A-Z]` |
network.author.<availability_zone>.cidr_block | CIDR block for the subnet where the `author-primary` and `author-standby` components will run on. | Mandatory | |
network.author.<availability_zone>.tag_name | Name of the subnet where the `author-primary` and `author-standby` components will run on, to be appended to stack prefix. Set as `Name` tag. | Optional | `AEM Author Subnet [A-Z]` |
network.author_dispatcher.<availability_zone>.cidr_block | CIDR block for the subnet where the `author-dispatcher` component will run on. | Mandatory | |
network.author_dispatcher.<availability_zone>.tag_name | Name of the subnet where the `author-dispatcher` component will run on, to be appended to stack prefix. Set as `Name` tag. | Optional | `AEM Author Dispatcher Subnet [A-Z]` |
network.tool.<availability_zone>.cidr_block | CIDR block for the subnet where the `orchestrator` and `chaos-monkey` components will run on. | Mandatory | |
network.tool.<availability_zone>.tag_name | Name of the subnet where the `orchestrator` and `chaos-monkey` components will run on, to be appended to stack prefix. Set as `Name` tag. | Optional | `AEM Tool Subnet [A-Z]` |
network.public_route_table.tag_name | Public route table's name, to be appended to stack prefix. Set as `Name` tag. | Optional | `AEM VPC Public Route Table` |
network.private_route_table.tag_name | Private route table's name, to be appended to stack prefix. Set as `Name` tag. | Optional | `AEM VPC Private Route Table` |
network.hosted_zone | | Optional | `aem.` |

### Network exports configuration properties

| Name | Description | Required? | Default |
|------|-------------| ----------|---------|
| network_exports.stack_name | The stack name (to be appended to stack prefix) of the network exports stack where the network configuration will reside. | Optional | `aem-network-exports-stack` |
| network_exports.VPCId | ID of the [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html#vpc-subnet-basics) where AEM environments will run on. | Mandatory | |
| network_exports.AuthorPublishDispatcherSubnet | The [subnet](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html) ID where `author-publish-dispatcher` component will run on. | Mandatory | |
| network_exports.PublishDispatcherELBSubnetList | Comma separated list of  subnet IDs where the ELB sitting in front of `publish-dispatcher` component will run on. | Mandatory | |
| network_exports.PublishDispatcherSubnetList | Comma separated list of  subnet IDs where `publish-dispatcher` component will run on. | Mandatory | |
| network_exports.PublishSubnetList | Comma separated list of  subnet IDs where `publish` component will run on. | Mandatory | |
| network_exports.AuthorPrimarySubnet | The subnet ID where `author-primary` component will run on. | Mandatory | |
| network_exports.AuthorStandbySubnet | The subnet ID where `author-standby` component will run on. | Mandatory | |
| network_exports.AuthorELBSubnetList | Comma separated list of  subnet IDs where the ELB sitting in front of `author-primary` and `author-standby` components will run on. | Mandatory | |
| network_exports.AuthorDispatcherELBSubnetList | Comma separated list of  subnet IDs where the ELB sitting in front of `author-dispatcher` component will run on. | Mandatory | |
| network_exports.AuthorDispatcherSubnetList | Comma separated list of  subnet IDs where `author-dispatcher` component will run on. | Mandatory | |
| network_exports.ToolSubnetList | Comma separated list of  subnet IDs where `orchestrator` and `chaos-monkey` components will run on. | Mandatory | |
| network_exports.PublicRouteTable | Public [route table](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html) used by the public subnets. | Mandatory | |
| network_exports.PrivateRouteTable | Private [route table](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html) used by the public subnets. | Mandatory | |

### AEM environment configuration properties

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| main.stack_name | The stack name (to be appended to stack prefix) of the main parent stack of the corresponding architecture | Mandatory | |
| prerequisites.stack_name | The stack name (to be appended to stack prefix) of the prerequisites parent stack of the corresponding architecture | Mandatory for AEM Consolidated and AEM Full-Set architectures, not needed for AEM Stack Manager | Mandatory | |
| permission_type | AEM AWS Stack Builder [permission type](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/permission-types.md). | Optional | `b` |
| network_stack_prefix | The stack prefix of the network stack where the AEM environment will be running on. If you're using the VPC which was created by AEM AWS Stack Builder, then the value of `network.stack_name` configuration should be the value of this `network_stack_prefix` configuration property. If you're using a non-AEM AWS Stack Builder VPC and you have to rely on network exports, then the value of `network_exports.stack_name` configuration should be the value of this `network_stack_prefix` configuration property. | Mandatory | |
| ami_ids.[author|publish|author_dispatcher|publish_dispatcher|author_publish_dispatcher|orchestrator|chaos_monkey] | AMI ID of the machine images created by [Packer AEM](https://github.com/shinesolutions/packer-aem). | Mandatory | |
| snapshots.[author|publish].use_data_vol_snapshot | If set to true, the volume of the snapshot which ID is  specified in `snapshots.[author|publish].data_vol_snapshot_id` will then be attached to the data volume. | Optional | `false` |
| snapshots.[author|publish].data_vol_snapshot_id | The snapshot ID which volume will be attached to the corresponding `author` or `publish` component's data volume. | Mandatory if `snapshots.[author|publish].use_data_vol_snapshot` is set to `true`, otherwise optional | |

### Library dependencies configuration properties:

It's recommended to not overwrite the library version configuration properties below, and let AEM AWS Stack Builder determines the versions to be used.

However, there could be circumstances where you can't upgrade AEM AWS Stack Builder yet, but at the same time you might need (for example) a newer version of Oak Run library. In that case, you can set the corresponding configuration property with the newer Oak Run version number.

| Name | Description | Required? | Default |
|------|-------------| ----------|---------|
| library.aem_aws_stack_provisioner_version | The version number of [AEM AWS Stack Provisioner](https://github.com/shinesolutions/aem-aws-stack-provisioner) library. This library is used for provisioning the components during AEM environment creation. | Optional | |
| library.aem_orchestrator_version | The version number of [AEM Orchestrator](https://github.com/shinesolutions/aem-orchestrator/) library. (Full-Set only) | Optional | |
| library.aem_password_reset_version | The version number of [AEM Password Reset](https://github.com/shinesolutions/aem-password-reset/) library. | Optional | |
| library.aem_healthcheck_version | The version number of [AEM Health Check](https://github.com/shinesolutions/aem-healthcheck) library. This version number will be used during Stack Manager event for reconfiguring AEM, which will provision AEM Health Check. | Optional | |
| library.aem_stack_manager_version | The version number of [AEM Stack Manager](https://github.com/shinesolutions/aem-stack-manager-cloud) library. | Optional | |
| library.oak_run_version | The version number of [Oak Run](https://github.com/apache/jackrabbit-oak/blob/trunk/oak-run/README.md) library. This version number must be compatible with the AEM version that you're using. Oak Run version numbers are available from [Maven repository](https://mvnrepository.com/artifact/org.apache.jackrabbit/oak-run) | Mandatory | |
| library.simian_army_version | The version number of [Simian Army](https://github.com/Netflix/SimianArmy) library. Simian Army runs on `chaos-monkey` component. (Full-Set only) | Optional | |

### AEM generic configuration properties:

| Name | Description | Required? | Default |
|------|-------------| ----------|---------|
| aem.version | AEM version number, used for version-specific feature implementations. Valid values are `6.2`, `6.3`, or `6.4` | Mandatory | |
| aem.enable_crxde | If true, then [CRXDE](https://helpx.adobe.com/experience-manager/6-3/sites/developing/using/developing-with-crxde-lite.html) will be enabled. Set to false by default for security reason. | Optional | `false` |
| aem.enable_default_passwords | If true, admin and other system users will be provisioned with default password, which is the same as their username. E.g. `admin` user will have password `admin`. If false, their passwords will be randomly generated, unique for each single AEM environment. Set to false by default for security reason. | Optional | `false` |
| aem.enable_reconfiguration | If true, the initial repository attached to the volume will be reconfigured for the current AEM OpenCloud version. | Optional | `false` |
| aem.deployment_delay_in_seconds | The number of seconds delay after AEM package deployment upload/installation, before resuming to perform health checks | Optional | `60` |
| aem.deployment_check_retries | The maximum number of times AEM package deployment upload/installation/health status will be checked | Optional | `120` |
| aem.deployment_check_delay_in_seconds | The number of seconds delay before retrying the deployment status check | Optional | `15` |
| aem.client_timeout | The number of seconds before [AEM API client](https://github.com/shinesolutions/ruby_aem) HTTP request times out. | Optional | `1200` |
| aem.[author|publish].jvm_mem_opts | AEM Author/Publish's memory-specific [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) | Optional | `-Xss4m -Xms4096m -Xmx8192m` |
| aem.[author|publish].jvm_opts | AEM Author/Publish's [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) | Optional | None |
| aem.author.jmxremote.port | AEM Author's [JMX](https://docs.oracle.com/javase/8/docs/technotes/guides/management/agent.html) remote port. | Optional | 59182 |
| aem.publish.jmxremote.port | AEM Publish's [JMX](https://docs.oracle.com/javase/8/docs/technotes/guides/management/agent.html) remote port. | Optional | 59182 |

### AEM Full-Set specific configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| aem.enable_reverse_replication | If true, reverse replication from AEM Publish to AEM Author will be enabled. | Optional | `true` |
| aem.enable_content_healthcheck | If true, content health check will be scheduled (Full-Set only). Content health check will be performed from each AEM Publish-Dispatcher instance, checking the content on its AEM Publish instance pair. | Optional | `true` |
| aem.enable_content_healthcheck_terminate_instance | If true, content health check failure will cause the `publish` and `publish-dispatcher` pair to be terminated. | Optional | `false` |
| aem.revert_snapshot_type | Sets the Publisher launch configuration's default snapshot ID. Valid values are `offline`, `live`, or none. If no value is set, in the event of catastrophic failure where all publish instances are terminated, then the newly recovered AEM Publish instance will use the original snapshot from when the environment was first created. | Optional | |
| scheduled_jobs.aem_orchestrator.stack_manager_pair.stack_prefix | The stack prefix of the Stack Manager pair which will be used by the AEM environment to execute offline snapshot and offline compaction snapshot events. Failing to configure this, those events will not be executed | Mandatory | |
| scheduled_jobs.aem_orchestrator.stack_manager_pair.stack_name | The main stack name of the Stack Manager pair which will be used by the AEM environment to execute offline snapshot and offline compaction snapshot events | Optional | aem-stack-manager-main-stack |

### AEM Consolidated specific configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| aem.enable_deploy_on_init | If true and if deployment descriptor is provided, the deployment process will be executed during cloud init as part of AEM environment creation. | Optional | `false` |

### AEM reconfiguration configuration properties

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| reconfiguration.enable_create_system_users | If set to true, any existing system users on the repository to be reconfigured will be deleted and then recreated with AEM OpenCloud system users. This is only needed when the source repository to be reconfigured contains non-AEM OpenCloud system users. | Optional | `false` |
| reconfiguration.certs_base | Source URL path of TLS certificate, it could be s3://..., http://..., https://..., or file://.... In [AWS Resources](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/aws-resources.md) case, it could be an S3 Bucket path, e.g. s3://somebucket/certs/  | Mandatory | |
| reconfiguration.keystore_password | [Java Keystore](https://www.digitalocean.com/community/tutorials/java-keytool-essentials-working-with-java-keystores) password used in AEM Author and Publish.  | Optional | `changeit` |
| system_users.[admin|deployer|exporter|importer|orchestrator|replicator].name | AEM system user username. Don't overwrite this unless you want to use non-AEM OpenCloud system users. | Optional | |
| system_users.[admin|deployer|exporter|importer|orchestrator|replicator].name | AEM system user path in the repository. Don't overwrite this unless you want to use non-AEM OpenCloud system users. | Optional | |

### AEM Stack Manager configuration properties:

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| stack_manager.stack_name | The stack name (to be appended to stack prefix) of the stack manager stack. This is where the AEM Stack Manager application itself runs. | Optional | `aem-stack-manager` |
| stack_manager.utilities_stack_name | The stack name (to be appended to stack prefix) of the stack manager's utilities stack. This is where the utility AWS Lambda functions run. | Optional | `utilities` |
| stack_manager.s3_prefix | The S3 prefix path specifying the location where Stack Manager objects (e.g. SSM logs) will be stored. This prefix will be appended to the S3 data bucket location for the given stack prefix, e.g. `s3://<data_bucket_name>/<stack_prefix>/<stack_manager_s3_prefix>` . | Optional | `stack-manager` |
| stack_manager.purge.live_snapshots.schedule | [Lambda cron expression](https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html) | Optional | 10 20 1/3 * ? * |
| stack_manager.purge.live_snapshots.max_age_in_hours | The number of hours to keep a live snapshot before it expires and will be removed | Optional | 24 |
| stack_manager.purge.offline_snapshots.schedule | [Lambda cron expression](https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html) | Optional | 15 19 ? * SUN * |
| stack_manager.purge.offline_snapshots.max_age_in_hours | The number of hours to keep an offline snapshot before it expires and will be removed  | Optional | 61320 |
| stack_manager.purge.orchestration_snapshots.schedule | [Lambda cron expression](https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html) | Optional | 5 0/4 * * ? * |
| stack_manager.purge.orchestration_snapshots.max_age_in_hours | The number of hours to keep an orchestration snapshot before it expires and will be removed  | Optional | 4 |

### Log rotation configuration properties

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| logrotation.default_config.rotate | The default log rotation configuration for how many rotated log files to be kept on disk. | Optional | `4` |
| logrotation.default_config.rotate_every | The default log rotation configuration for how often the log files should be rotated. | Optional | `daily` |
| logrotation.default_config.compress | The default log rotation configuration for determining whether the rotated log files should be compressed. | Optional | `true` |
| logrotation.default_config.create | The default log rotation configuration for determining whether a new log file should be created immediately after rotation. | Optional | `true` |
| logrotation.default_config.dateext | The default log rotation configuration for determining whether the rotated log file should be archived by adding date extension. If false, then it will simply use a number. | Optional | `true` |
| logrotation.default_config.ifempty | The default log rotation configuration for determining whether the log file needs to be rotated if it's empty. | Optional | `false` |
| logrotation.default_config.olddir | The default log rotation configuration for the directory where the rotated log files would be kept. If set to false, then it will use the same directory where the original log file is located. | Optional | `false` |
| logrotation.default_config.size | The default log rotation configuration for the log file size (in bytes, add K for Kb, add M for Mb) limit that should be reached before the file will be rotated. | Optional | `10M` |
| logrotation.config./etc/logrotate.conf.<param> | The global log rotation config file path (`/etc/logrotate.conf`) and the initial parameter `<param>` to be set. | Optional, at minimum specify one parameter for Puppet create_resources compatibility | |
| logrotation.rules.<rule_name>.path | The log files path to be rotated for this specific rule. | Optional | |
| logrotation.rules.<rule_name>.olddir | The directory where the rotated log files to be kept for this specific rule. | Optional | |
| logrotation.rules.<rule_name>.postrotate | The command to be executed after the rotation of the log files for this specific rule. | Optional | |
| logrotation.<component>.config | Component specific configuration, which overwrites the default defined in `logrotation.config` . | Optional, at minimum specify one parameter for Puppet create_resources compatibility | |
| logrotation.<component>.rules | Component specific log rotation rules. | Optional | |

### Scheduled jobs configuration properties

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| scheduled_jobs.author_primary.offline_compaction.enable | If true, then offline compaction will be scheduled on `author-primary` component. | Optional | `false` |
| scheduled_jobs.author_primary.offline_compaction.weekday | The day of the week when the offline compaction job is scheduled to run. This uses [Puppet cron type weekday](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-weekday) | Optional | `2` |
| scheduled_jobs.author_primary.offline_compaction.hour | The hour of the day when the offline compaction job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-hour) | Optional | `3` |
| scheduled_jobs.author_primary.offline_compaction.minute | The minute of the hour when the offline compaction job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-minute) | Optional | `0` |
| scheduled_jobs.author_primary.export.enable | If true, then export backup will be scheduled on `author-primary` component. | Optional | `true` |
| scheduled_jobs.author_primary.export.weekday | The day of the week when the export backup job is scheduled to run. This uses [Puppet cron type weekday](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-weekday) | Optional | `0-7` |
| scheduled_jobs.author_primary.export.hour | The hour of the day when the export backup job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-hour) | Optional | `2` |
| scheduled_jobs.author_primary.export.minute | The minute of the hour when the export backup job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-minute) | Optional | `0` |
| scheduled_jobs.author_primary.live_snapshot.enable | If true, then live snapshot backup backup will be scheduled on `author-primary` component. | Optional | `true` |
| scheduled_jobs.author_primary.live_snapshot.weekday | The day of the week when the live snapshot backup backup job is scheduled to run. This uses [Puppet cron type weekday](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-weekday) | Optional | `0-7` |
| scheduled_jobs.author_primary.live_snapshot.hour | The hour of the day when the live snapshot backup backup job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-hour) | Optional | `*` |
| scheduled_jobs.author_primary.live_snapshot.minute | The minute of the hour when the live snapshot backup backup job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-minute) | Optional | `0` |
| scheduled_jobs.author_standby.live_snapshot.enable | If true, then live snapshot backup backup will be scheduled on `author-standby` component. | Optional | `true` |
| scheduled_jobs.author_standby.live_snapshot.weekday | The day of the week when the live snapshot backup backup job is scheduled to run. This uses [Puppet cron type weekday](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-weekday) | Optional | `0-7` |
| scheduled_jobs.author_standby.live_snapshot.hour | The hour of the day when the live snapshot backup backup job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-hour) | Optional | `*` |
| scheduled_jobs.author_standby.live_snapshot.minute | The minute of the hour when the live snapshot backup backup job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-minute) | Optional | `0` |
| scheduled_jobs.publish.offline_compaction.enable | If true, then offline compaction will be scheduled on `publish` component. | Optional | `false` |
| scheduled_jobs.publish.offline_compaction.weekday | The day of the week when the offline compaction job is scheduled to run. This uses [Puppet cron type weekday](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-weekday) | Optional | `2` |
| scheduled_jobs.publish.offline_compaction.hour | The hour of the day when the offline compaction job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-hour) | Optional | `3` |
| scheduled_jobs.publish.offline_compaction.minute | The minute of the hour when the offline compaction job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-minute) | Optional | `0` |
| scheduled_jobs.publish.export.enable | If true, then export backup will be scheduled on `publish` component. | Optional | `true` |
| scheduled_jobs.publish.export.weekday | The day of the week when the export backup job is scheduled to run. This uses [Puppet cron type weekday](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-weekday) | Optional | `0-7` |
| scheduled_jobs.publish.export.hour | The hour of the day when the export backup job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-hour) | Optional | `2` |
| scheduled_jobs.publish.export.minute | The minute of the hour when the export backup job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-minute) | Optional | `0` |
| scheduled_jobs.publish.live_snapshot.enable | If true, then live snapshot backup backup will be scheduled on `publish` component. | Optional | `true` |
| scheduled_jobs.publish.live_snapshot.weekday | The day of the week when the live snapshot backup backup job is scheduled to run. This uses [Puppet cron type weekday](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-weekday) | Optional | `0-7` |
| scheduled_jobs.publish.live_snapshot.hour | The hour of the day when the live snapshot backup backup job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-hour) | Optional | `*` |
| scheduled_jobs.publish.live_snapshot.minute | The minute of the hour when the live snapshot backup backup job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-minute) | Optional | `0` |
| scheduled_jobs.publish_dispatcher.content_health_check.enable | If true, then content health check backup will be scheduled on `publish-dispatcher` component. | Optional | `true` |
| scheduled_jobs.publish_dispatcher.content_health_check.weekday | The day of the week when the content health check backup job is scheduled to run. This uses [Puppet cron type weekday](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-weekday) | Optional | `0-7` |
| scheduled_jobs.publish_dispatcher.content_health_check.hour | The hour of the day when the content health check backup job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-hour) | Optional | `*` |
| scheduled_jobs.publish_dispatcher.content_health_check.minute | The minute of the hour when the content health check backup job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-minute) | Optional | `0` |
| scheduled_jobs.aem_orchestrator.stack_manager_pair.stack_prefix | The stack prefix of the Stack Manager stack, which will be paired to the `orchestrator` component. | Optional | None |
| scheduled_jobs.aem_orchestrator.stack_manager_pair.stack_name | The name of the Stack Manager stack, which will be paired to the `orchestrator` component. | Optional | `aem-stack-manager-main-stack` |
| scheduled_jobs.aem_orchestrator.offline_compaction_snapshot.enable | If true, then offline compaction snapshot will be scheduled on `orchestrator` component. | Optional | `true` |
| scheduled_jobs.aem_orchestrator.offline_compaction_snapshot.weekday | The day of the week when the offline compaction snapshot job is scheduled to run. This uses [Puppet cron type weekday](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-weekday) | Optional | `1` |
| scheduled_jobs.aem_orchestrator.offline_compaction_snapshot.hour | The hour of the day when the offline compaction snapshot job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-hour) | Optional | `1` |
| scheduled_jobs.aem_orchestrator.offline_compaction_snapshot.minute | The minute of the hour when the offline compaction snapshot job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-minute) | Optional | `15` |
| scheduled_jobs.aem_orchestrator.offline_snapshot.enable | If true, then offline snapshot will be scheduled on `orchestrator` component. | Optional | `true` |
| scheduled_jobs.aem_orchestrator.offline_snapshot.weekday | The day of the week when the offline snapshot job is scheduled to run. This uses [Puppet cron type weekday](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-weekday) | Optional | `2-7` |
| scheduled_jobs.aem_orchestrator.offline_snapshot.hour | The hour of the day when the offline snapshot job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-hour) | Optional | `1` |
| scheduled_jobs.aem_orchestrator.offline_snapshot.minute | The minute of the hour when the offline snapshot job is scheduled to run. This uses [Puppet cron type hour](https://puppet.com/docs/puppet/5.3/types/cron.html#cron-attribute-minute) | Optional | `15` |

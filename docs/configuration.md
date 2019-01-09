Configuration
-------------

The following configurations are available for users to customise the creation process and the resulting machine images.

Check out the [example configuration files](https://github.com/shinesolutions/aem-helloworld-config/tree/master/aem-aws-stack-builder/) as reference.

### Global configuration properties:

These configurations are applicable to both network and AEM application infrastructure.

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| os_type | Operating System type, can be `rhel7`, `amazon-linux2`, or `centos7` | Optional | `rhel7` |
| aws.region | [AWS region name](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) | Optional | `ap-southeast-2` |
| aws.availability_zone_list | Comma separated list of [AWS availability zones](https://howto.lintel.in/list-of-aws-regions-and-availability-zones/) within the region defined in `aws.region` . | Optional | `ap-southeast-2a, ap-southeast-2b` |
| proxy.enabled | If true, then web proxy will be used during provisioning steps. Note: this web proxy setting is not used for cron jobs | Optional | `false` |
| proxy.protocol | Web proxy server protocol used during provisioning steps | Optional | None |
| proxy.host | Web proxy server host used during provisioning steps | Optional | None |
| proxy.port | Web proxy server port number used during provisioning steps | Optional | None |
| proxy.user | Web proxy user to authenticate against the configured proxy host in `proxy.host` | Optional | None |
| proxy.password | Web proxy user password for the proxy user defined in `proxy.user` | Optional | None |
| proxy.noproxy | A list of hosts to be excluded from proxy  | Optional | localhost, 127.0.0.1 |
| cron.env_path | Executable path used when running cron jobs. | Optional | `/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin` |
| cron.http_proxy | Web proxy server for http URLs, e.g. `http://someproxy:3128`, leave empty if the cron job needs to directly connect to the Internet. | Optional | None |
| cron.https_proxy | Web proxy server for https URLs, e.g. `http://someproxy:3128`, leave empty if the cron job needs to directly connect to the Internet. | Optional | None |
| cron.no_proxy | A comma separated value of domain suffixes that you don't want to use with the web proxy, e.g. `localhost,127.0.0.1` | Optional | None |

### Network configuration properties

These configurations are applicable only to network infrastructure when you can create VPC using AEM AWS Stack Builder.

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

These configurations are applicable only to network infrastructure when you can't create VPC using AEM AWS Stack Builder, so you have to rely on existing VPC, and you have to utilise network exports configurations to specify the resources (VPC ID, subnet IDs) on the existing VPC.

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

These configurations are applicable to AEM environment infrastructure.

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| main.stack_name | The stack name (to be appended to stack prefix) of the main parent stack of the corresponding architecture | Mandatory | |
| prerequisites.stack_name | The stack name (to be appended to stack prefix) of the prerequisites parent stack of the corresponding architecture | Mandatory for AEM Consolidated and AEM Full-Set architectures, not needed for AEM Stack Manager | Mandatory | |
| permission_type | AEM AWS Stack Builder [permission type](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/permission-types.md). | Optional | `b` |
| network_stack_prefix | The stack prefix of the network stack where the AEM environment will be running on. If you're using the VPC which was created by AEM AWS Stack Builder, then the value of `network.stack_name` configuration should be the value of this `network_stack_prefix` configuration property. If you're using a non-AEM AWS Stack Builder VPC and you have to rely on network exports, then the value of `network_exports.stack_name` configuration should be the value of this `network_stack_prefix` configuration property. | Mandatory | |

### AWS resources configuration properties

These configurations are applicable to AWS resources used by the AEM environment.

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| ami_ids.[author\|publish|author_dispatcher|publish_dispatcher|author_publish_dispatcher|orchestrator|chaos_monkey] | AMI ID of the machine images created by [Packer AEM](https://github.com/shinesolutions/packer-aem). | Mandatory | |
| os_type | The os type of the ami. rhel7 or amazon-linux2 | Mandatory |  |
| snapshots.[author\|publish].use_data_vol_snapshot | If set to true, the volume of the snapshot which ID is  specified in `snapshots.[author\|publish].data_vol_snapshot_id` will then be attached to the data volume. | Optional | `false` |
| snapshots.[author\|publish].data_vol_snapshot_id | The snapshot ID which volume will be attached to the corresponding `author` or `publish` component's data volume. | Mandatory if `snapshots.[author\|publish].use_data_vol_snapshot` is set to `true`, otherwise optional | |
| security_groups.secure_shell.inbound_cidr_ip | | Mandatory | |
| security_groups.private_subnet_internet_outbound_cidr_ip | CIDR block of the outbound access from private subnets. For example, if you want to lock down outbound access to an outbound proxy, then put the CIDR block of the outbound proxy here. If you want to allow access to everywhere, use `0.0.0.0/0` . | Mandatory | |
| security_groups.publish_dispatcher_elb.inbound_cidr_ip | CIDR block of the inbound access to the ELB sitting in front of `publish-dispatcher` component. For example, if you want to lock down inbound access from a CDN service, then put the CIDR block of the CDN service here. If you want to allow access from everywhere, use `0.0.0.0/0` . | Mandatory | |
| security_groups.publish_dispatcher_elb.extra_groups | Additional security groups to be attached to the ELB sitting in front of `publish-dispatcher` component. This is handy when you have some pre-existing security groups with custom rules that you'd like to add to the ELB. | Optional | |
| security_groups.author_dispatcher_elb.inbound_cidr_ip | CIDR block of the inbound access to the ELB sitting in front of `author-dispatcher` component. For example, if you want to lock down inbound access from a reverse proxy, then put the CIDR block of the reverse proxy here. If you want to allow access from everywhere, use `0.0.0.0/0` . | Mandatory | |
| security_groups.author_dispatcher_elb.extra_groups | Additional security groups to be attached to the ELB sitting in front of `author-dispatcher` component. This is handy when you have some pre-existing security groups with custom rules that you'd like to add to the ELB. | Mandatory | |
| security_groups.author_publish_dispatcher.inbound_cidr_ip | | Mandatory | |
| messaging.asg_event_sqs_queue_name | Scaling event SQS queue name to be appended to the stack prefix. | Optional | `aem-asg-event-queue` |
| messaging.asg_event_sns_topic_name | Scaling event SNS topic resource name to be appended to the stack prefix. | Optional | `aem-asg-event-topic` |
| messaging.asg_event_sns_topic_display_name | Scaling event SNS topic display name. | Optional | `AEM ASG Event Topic` |
| messaging.alarm_notification.contact_email | Recipient email address where alarm notification will be sent to.  | Mandatory | |
| compute.key_pair_name | [EC2 key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) to be provisioned on all EC2 instances within the AEM environment. | Mandatory | |
| compute.inbound_from_bastion_host_security_group | Security group to allow inbound access from a bastion host. | Mandatory | |
| s3.data_bucket_name | S3 data bucket which stores all AEM environment's object files such as descriptors and credentials. | Mandatory | |
| dns_records.route53_hosted_zone_name | A Route 53 hosted zone which the AEM environment DNS records will be created on. | Mandatory | |
| dns_records.author.record_set_name | This name will be appended to the stack prefix, and used as the subdomain on the specified host zone, pointing to the ELB sitting in front of `author-primary` and `author-standby` components. E.g. `<stack_prefix>-<record_set_name>.<hosted_zone>` . | Optional | `author` |
| dns_records.author_dispatcher.record_set_name | This name will be appended to the stack prefix, and used as the subdomain on the specified host zone, pointing to the ELB sitting in front of the `author-dispatcher` component. E.g. `<stack_prefix>-<record_set_name>.<hosted_zone>` . | Optional | `author-dispatcher` |
| dns_records.publish_dispatcher.record_set_name | This name will be appended to the stack prefix, and used as the subdomain on the specified host zone, pointing to the ELB sitting in front of the `publish-dispatcher` component. E.g. `<stack_prefix>-<record_set_name>.<hosted_zone>` . | Optional | `publish-dispatcher` |
| dns_records.author_publish_dispatcher.record_set_name | This name will be appended to the stack prefix, and used as the subdomain on the specified host zone, pointing directly to the `author-publish-dispatcher` component. E.g. `<stack_prefix>-<record_set_name>.<hosted_zone>` . | Optional | `author-publish-dispatcher` |
| dns_records.author_publish_dispatcher.ttl | Time to live of the Author Publish Dispatcher DNS record. | Optional | `300` |

### Component configuration properties

These configurations are applicable to the components used within AEM Full-Set and Consolidated architectures.

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| publish_dispatcher.instance_profile | ARN of the IAM instance profile to be used on `publish-dispatcher` component. | Mandatory for instance profile exports stack, ignore this for other stacks. | |
| publish_dispatcher.instance_type | The [EC2 instance type](https://aws.amazon.com/ec2/instance-types/) of `publish-dispatcher` component instances. | Optional | `t2.micro` |
| publish_dispatcher.root_vol_size | The root volume size in Gb of `publish-dispatcher` component instances. | Optional | `20` |
| publish_dispatcher.data_vol_size | The data volume size in Gb of `publish-dispatcher` component instances. | Optional | `20` |
| publish_dispatcher.desired_capacity | The desired number of `publish-dispatcher` component instances. | Optional | `2` |
| publish_dispatcher.min_size | The minimum number of `publish-dispatcher` component instances. | Optional | `2` |
| publish_dispatcher.max_size | The maximum number of `publish-dispatcher` component instances. | Optional | `2` |
| publish_dispatcher.elb_health_check | The health check to be performed on the ELB sitting in front of `publish-dispatcher` component. | Optional | `HTTPS:443/system/health?tags=shallow` |
| publish_dispatcher.elb_scheme | The [scheme](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-elb.html#cfn-ec2-elb-scheme) for the ELB sitting in front of `publish-dispatcher` component. | Optional | `internet-facing` |
| publish_dispatcher.allowed_client | The allowed source IP address where AEM Dispatcher running on `publish-dispatcher` component. Default to everything because users tend to have different network design, some might restrict inbound access from AEM Publish, some might allow external resource such as a CDN service to flush the cache. | Optional | `*.*.*.*` |
| publish_dispatcher.enable_random_termination | If true, Chaos Monkey will attempt to randomly terminate an EC2 instance within this component's AutoScalingGroup. | Optional | `true` |
| publish.instance_profile | ARN of the IAM instance profile to be used on `publish` component. | Mandatory for instance profile exports stack, ignore this for other stacks. | |
| publish.instance_type | The [EC2 instance type](https://aws.amazon.com/ec2/instance-types/) of `publish` component instances. | Optional | `m3.large` |
| publish.root_vol_size | The root volume size in Gb of `publish` component instances. | Optional | `20` |
| publish.data_vol_size | The data volume size in Gb of `publish` component instances. | Optional | `75` |
| publish.desired_capacity | The desired number of `publish` component instances. | Optional | `2` |
| publish.min_size | The minimum number of `publish` component instances. | Optional | `2` |
| publish.max_size | The maximum number of `publish` component instances. | Optional | `2` |
| publish.enable_random_termination | If true, Chaos Monkey will attempt to randomly terminate an EC2 instance within this component's AutoScalingGroup. | Optional | `true` |
| author.instance_profile | ARN of the IAM instance profile to be used on `author` component. | Mandatory for instance profile exports stack, ignore this for other stacks. | |
| author.instance_type | The [EC2 instance type](https://aws.amazon.com/ec2/instance-types/) of `author` component instances. | Optional | `m3.large` |
| author.root_vol_size | The root volume size in Gb of `author` component instances. | Optional | `20` |
| author.data_vol_size | The data volume size in Gb of `author` component instances. | Optional | `75` |
| author_dispatcher.elb_health_check | The health check to be performed on the ELB sitting in front of `author-dispatcher` component. | Optional | `HTTPS:5432/system/health?tags=shallow` |
| author_dispatcher.instance_profile | ARN of the IAM instance profile to be used on `author_dispatcher` component. | Mandatory for instance profile exports stack, ignore this for other stacks. | |
| author_dispatcher.instance_type | The [EC2 instance type](https://aws.amazon.com/ec2/instance-types/) of `author_dispatcher` component instances. | Optional | `t2.micro` |
| author_dispatcher.root_vol_size | The root volume size in Gb of `author_dispatcher` component instances. | Optional | `20` |
| author_dispatcher.data_vol_size | The data volume size in Gb of `author_dispatcher` component instances. | Optional | `20` |
| author_dispatcher.desired_capacity | The desired number of `author_dispatcher` component instances. | Optional | `2` |
| author_dispatcher.min_size | The minimum number of `author_dispatcher` component instances. | Optional | `2` |
| author_dispatcher.max_size | The maximum number of `author_dispatcher` component instances. | Optional | `2` |
| author_dispatcher.elb_health_check | The health check to be performed on the ELB sitting in front of `author-dispatcher` component. | Optional | `HTTPS:443/system/health?tags=shallow` |
| author_dispatcher.enable_random_termination | If true, Chaos Monkey will attempt to randomly terminate an EC2 instance within this component's AutoScalingGroup. | Optional | `true` |
| author_publish_dispatcher.instance_profile | ARN of the IAM instance profile to be used on `author_publish_dispatcher` component. | Mandatory for instance profile exports stack, ignore this for other stacks. | |
| author_publish_dispatcher.instance_type | The [EC2 instance type](https://aws.amazon.com/ec2/instance-types/) of `author_publish_dispatcher` component instances. | Optional | `m4.xlarge` |
| author_publish_dispatcher.root_vol_size | The root volume size in Gb of `author_publish_dispatcher` component instances. | Optional | `20` |
| author_publish_dispatcher.data_vol_size | The data volume size in Gb of `author_publish_dispatcher` component instances. | Optional | `20` |
| author_publish_dispatcher.associate_public_ip_address | If true, then a public IP address will be associated to the `author-publish-dispatcher` instance. | Optional | `true` |
| orchestrator.instance_profile | ARN of the IAM instance profile to be used on `orchestrator` component. | Mandatory for instance profile exports stack, ignore this for other stacks. | |
| orchestrator.instance_type | The [EC2 instance type](https://aws.amazon.com/ec2/instance-types/) of `orchestrator` component instances. | Optional | `t2.small` |
| orchestrator.root_vol_size | The root volume size in Gb of `orchestrator` component instances. | Optional | `20` |
| orchestrator.data_vol_size | The data volume size in Gb of `orchestrator` component instances. | Optional | `20` |
| orchestrator.enable_random_termination | If true, Chaos Monkey will attempt to randomly terminate an EC2 instance within this component's AutoScalingGroup. | Optional | `true` |
| chaos_monkey.instance_profile | ARN of the IAM instance profile to be used on `chaos_monkey` component. | Mandatory for instance profile exports stack, ignore this for other stacks. | |
| chaos_monkey.instance_type | The [EC2 instance type](https://aws.amazon.com/ec2/instance-types/) of `chaos_monkey` component instances. | Optional | `t2.micro` |
| chaos_monkey.root_vol_size | The root volume size in Gb of `chaos_monkey` component instances. | Optional | `20` |
| chaos_monkey.include_stack | If true, `chaos-monkey` component will be included in the created AEM environment. If false, then the environment won't have `chaos-monkey` component. | Optional | `true` |
| chaos_monkey.termination_settings.calendar_open_hour | Chaos Monkey [setting](https://github.com/Netflix/SimianArmy/wiki/Global-Settings#simianarmycalendaropenhour) specifying the starting hour of the day when Chaos Monkey starts operating. | Optional | `9` |
| chaos_monkey.termination_settings.calendar_close_hour | Chaos Monkey [setting](https://github.com/Netflix/SimianArmy/wiki/Global-Settings#simianarmycalendarclosehour) specifying the ending hour of the day when Chaos Monkey starts operating. | Optional | `15` |
| chaos_monkey.termination_settings.calendar_timezone | Chaos Monkey [setting](https://github.com/Netflix/SimianArmy/wiki/Global-Settings#simianarmycalendartimezone) specifying the timezone for the operating hours. | Optional | `Australia/Sydney` |
| chaos_monkey.termination_settings.scheduler_frequency_in_minutes | Chaos Monkey [setting](https://github.com/Netflix/SimianArmy/wiki/Global-Settings#simianarmyschedulerfrequency) specifying how often (in minutes) Chaos Monkey should attempt to terminate a random instance. Default is set to 5, which means Chaos Monkey will attempt to terminate a random instance every 5 minutes, until max termination is reached. | Optional | `5` |
| chaos_monkey.termination_settings.asg_probability | Chaos Monkey [setting](https://github.com/Netflix/SimianArmy/wiki/Global-Settings#simianarmycalendartimezone) specifying the timezone for the operating hours. | Optional | `1.0` |
| chaos_monkey.termination_settings.asg_max_terminations_per_day | Chaos Monkey [setting](https://github.com/Netflix/SimianArmy/wiki/Chaos-Settings#simianarmychaosasgprobability) specifying the probability of termination per day. Note that this number will be divided by the hours between `chaos_monkey.termination_settings.calendar_open_hour` and `chaos_monkey.termination_settings.calendar_close_hour` . | Optional | `1.0` |
| chaos_monkey.enable_random_termination | If true, Chaos Monkey will attempt to randomly terminate an EC2 instance within this component's AutoScalingGroup. | Optional | `true` |


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

These configurations are applicable for both AEM Full-Set and Consolidated architectures.

| Name | Description | Required? | Default |
|------|-------------| ----------|---------|
| aem.version | AEM version number, used for version-specific feature implementations. Valid values are `6.2`, `6.3`, or `6.4` | Mandatory | |
| aem.enable_crxde | If true, then [CRXDE](https://helpx.adobe.com/experience-manager/6-3/sites/developing/using/developing-with-crxde-lite.html) will be enabled. Set to false by default for security reason. | Optional | `false` |
| aem.enable_default_passwords | If true, admin and other system users will be provisioned with default password, which is the same as their username. E.g. `admin` user will have password `admin`. If false, their passwords will be randomly generated, unique for each single AEM environment. Set to false by default for security reason. | Optional | `false` |
| aem.enable_bak_files_cleanup | If true, .bak files older than `aem.bak_files_cleanup_max_age_in_days` will be deleted during repository compaction. | Optional | `false` |
| aem.bak_files_cleanup_max_age_in_days | The number of maximum age in days for repository .bak files to be kept. Files older than this will be deleted during compaction. | Optional | `30` |
| aem.enable_reconfiguration | If true, the initial repository attached to the volume will be reconfigured for the current AEM OpenCloud version. | Optional | `false` |
| aem.enable_upgrade_tools | If true, the AEM upgrade tools will be installed on AEM Author & AEM Publish. | Optional | `false` |
| aem.deployment_delay_in_seconds | The number of seconds delay after AEM package deployment upload/installation, before resuming to perform health checks | Optional | `60` |
| aem.deployment_check_retries | The maximum number of times AEM package deployment upload/installation/health status will be checked | Optional | `120` |
| aem.deployment_check_delay_in_seconds | The number of seconds delay before retrying the deployment status check | Optional | `15` |
| aem.login_ready_max_tries | The number of times AEM login page will be checked | Optional | 60 |
| aem.login_ready_base_sleep_seconds | The number of seconds to wait at least before retrying the login page ready check | Optional | 5 |
| aem.login_ready_max_sleep_seconds | The number of seconds to wait maximum before retrying the login page ready check | Optional | 10 |
| aem.client_timeout | The number of seconds before [AEM API client](https://github.com/shinesolutions/ruby_aem) HTTP request times out. | Optional | `1200` |
| aem.[author\|publish].jvm_mem_opts | AEM Author/Publish's memory-specific [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) | Optional | `-Xss4m -Xms4096m -Xmx8192m` |
| aem.[author\|publish].jvm_opts | AEM Author/Publish's [JVM arguments](https://docs.oracle.com/cd/E22289_01/html/821-1274/configuring-the-default-jvm-and-java-arguments.html) | Optional | None |
| aem.author.jmxremote.port | AEM Author's [JMX](https://docs.oracle.com/javase/8/docs/technotes/guides/management/agent.html) remote port. | Optional | 59182 |
| aem.publish.jmxremote.port | AEM Publish's [JMX](https://docs.oracle.com/javase/8/docs/technotes/guides/management/agent.html) remote port. | Optional | 59182 |
| aem.truststore.enable_creation | If set to true, AEM Global Truststore will be created for AEM Author | Optional | false |
| aem.truststore.password | AEM Global Truststore password | Optional | false |

### AEM Full-Set specific configuration properties:

These configurations are applicable specific to Full-Set AEM architecture.

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| aem.enable_reverse_replication | If true, reverse replication from AEM Publish to AEM Author will be enabled. | Optional | `true` |
| aem.enable_content_healthcheck | If true, content health check will be scheduled (Full-Set only). Content health check will be performed from each AEM Publish-Dispatcher instance, checking the content on its AEM Publish instance pair. | Optional | `true` |
| aem.enable_content_healthcheck_terminate_instance | If true, content health check failure will cause the `publish` and `publish-dispatcher` pair to be terminated. | Optional | `false` |
| aem.revert_snapshot_type | Sets the Publisher launch configuration's default snapshot ID. Valid values are `offline`, `live`, or none. If no value is set, in the event of catastrophic failure where all publish instances are terminated, then the newly recovered AEM Publish instance will use the original snapshot from when the environment was first created. | Optional | |
| scheduled_jobs.aem_orchestrator.stack_manager_pair.stack_prefix | The stack prefix of the Stack Manager pair which will be used by the AEM environment to execute offline snapshot and offline compaction snapshot events. Failing to configure this, those events will not be executed | Mandatory | |
| scheduled_jobs.aem_orchestrator.stack_manager_pair.stack_name | The main stack name of the Stack Manager pair which will be used by the AEM environment to execute offline snapshot and offline compaction snapshot events | Optional | aem-stack-manager-main-stack |

### AEM Consolidated specific configuration properties:

These configurations are applicable specific to Consolidated AEM architecture.

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| aem.enable_deploy_on_init | If true and if deployment descriptor is provided, the deployment process will be executed during cloud init as part of AEM environment creation. | Optional | `false` |

### AEM reconfiguration configuration properties

These configurations are applicable only when you run repository reconfiguration on AEM Full-Set or Consolidated.

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| reconfiguration.enable_create_system_users | If set to true, any existing system users on the repository to be reconfigured will be deleted and then recreated with AEM OpenCloud system users. This is only needed when the source repository to be reconfigured contains non-AEM OpenCloud system users. | Optional | `false` |
| reconfiguration.enable_truststore_migration | If set to true, The existing AEM Global Truststore gets downloaded, remove the Truststore from AEM, create new empty one, upload downloaded Truststore. This option needs to be set true when reconfiguring an upgraded AEM Repository and the Truststore needs to be readable on the upgraded AEM instance. The parameter `aem.truststore.password` needs to be set with the same password of the existing AEM Global Truststore | Optional | `false` |
| reconfiguration.certs_base | Source URL path of TLS certificate, it could be s3://..., http://..., https://..., or file://.... In [AWS Resources](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/aws-resources.md) case, it could be an S3 Bucket path, e.g. s3://somebucket/certs/  | Mandatory | |
| reconfiguration.ssl_keystore_password | [Java Keystore](https://www.digitalocean.com/community/tutorials/java-keytool-essentials-working-with-java-keystores) password used in AEM Author and Publish.  | Optional | `changeit` |
| system_users.[admin|deployer|exporter|importer|orchestrator|replicator].name | AEM system user username. Don't overwrite this unless you want to use non-AEM OpenCloud system users. | Optional | |
| system_users.[admin|deployer|exporter|importer|orchestrator|replicator].name | AEM system user path in the repository. Don't overwrite this unless you want to use non-AEM OpenCloud system users. | Optional | |

### AEM SAML configuration properties:

These configuration are applicable only when you want to enable SAML authentication during Stack creation.

| Name | Description | Required? | Default |
|------|-------------|-----------|---------|
| aem.enable_saml | If set to true, SAML authentication configuration will be created. Following option need to be set `saml.*` | Optional | false |
| aem.truststore.enable_saml_certificate_upload | If set to true, the SAML Certificate defined at `saml.file` get's uploaded to the AEM Global Truststore. The options `saml.file` & `aem.enable_saml` needs to be defined. | Optional | false |
| saml.* | Paramteres to configure SAML authentication | Mandatory only when `aem.enable_saml` is `true` | |
| saml.path | Repository path for which this authentication handler should be used by Sling. | Mandatory only when `aem.enable_saml` is `true` | / |
| saml.service_ranking | OSGi Framework Service Ranking value to indicate the order in which to call this service. This is an int value where higher values designate higher precedence.| Optional | 5002 |
| saml.idp_url | URL of the IDP where the SAML Authentication Request should be sent to. | Mandatory only when `aem.enable_saml` is `true` | |
| saml.idp_http_redirect | Use an HTTP Redirect to the IDP URL instead of sending an AuthnRequest-message to request credentials. Use this for IDP initiated authentication. | Optional | False |
| saml.service_provider_entity_id | ID which uniquely identifies this service provider with the identity provider. | Mandatory only when `aem.enable_saml` is `true` | |
| saml.sp_private_key_alias | The alias of the SP's private key in the key-store of the 'authentication-service' system user. If this property is empty the handler will not be able to sign or decrypt messages. | Optional | |
| saml.key_store_password | The password of the key-store of the 'authentication-service' system user. | Optional | |
| saml.default_redirect_url | The default location to redirect to after successful authentication. | Mandatory only when `aem.enable_saml` is `true` | / |
| saml.user_id_attribute | The name of the attribute containing the user ID used to authenticate and create the user in the CRX repository. Leave empty to use the Subject:NameId. | Optional | uid |
| saml.use_encryption | Whether or not this authentication handler expects encrypted SAML assertions. If this is enabled the SP's private key must be provided in the key-store of the 'authentication-service' system user (see SP Private Key Alias above). | Mandatory only when `aem.enable_saml` is `true` | True |
| saml.create_user | Whether or not to autocreate nonexisting users in the repository. | Optional | True |
| saml.add_group_memberships | Whether or not a user should be automatically added to CRX groups after successful authentication. | Optional | True |
| saml.group_membership_attribute | The name of the attribute containing a list of CRX groups this user should be added to. | Optional | groupMembership |
| saml.default_groups | A list of default CRX groups users are added to after successful authentication. | Optional | |
| saml.name_id_format | The value of the NameIDPolicy format parameter to send in the AuthnRequest message. | Optional | urn:oasis:names:tc:SAML:2.0:nameid-format:transient |
| saml.synchronize_attributes | A list of attribute mappings (in the format "attributename=path/relative/to/user/node") which should be stored in the repository on user-synchronization. | Optional | |
| saml.handle_logout | Whether or not logout (dropCredentials) requests will be processed by this handler. (handleLogout). | Optional | False |
| saml.logout_url | URL of the IDP where the SAML Logout Request should be sent to. If this property is empty the authentication handler won't handle logouts. | Optional | |
| saml.clock_tolerance | Time tolerance in seconds to compensate clock skew between IDP and SP when validating Assertions. | Optional | 60 |
| aem.authorizable_keystore.enable_creation | If set to true, the Authorizable Keystore for user authentication-service will be created. Options `aem.enable_saml` `aem.authorizable_keystore.enable_certificate_chain_upload` needs to be set true as preconditions. | Optional | false |
| saml.idp_cert_alias | The alias of the IdP's certificate in the global truststore. If this property is empty property `saml.file` or `saml.serial` has to be set. | Optional | |
| saml.file | Source URL path of SAML certificate, it could be s3://..., http://..., https://..., or file://.... In [AWS Resources](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/aws-resources.md) case, it could be an S3 Bucket path, e.g. s3://somebucket/certs/saml.crt. If this property is empty property `saml.idp_cert_alias` or `saml.serial` has to be set. | Optional | |
| saml.serial | The Serial number of the IdP's certificate in the global truststore. If this property is empty property `saml.idp_cert_alias` or `saml.file` has to be set. | Optional | |
| aem.authorizable_keystore.enable_certificate_chain_upload | If set to true, the certificates defined at `system_users.authentication-service.authorizable_keystore.certificate_chain` & `system_users.authentication-service.authorizable_keystore.private_key` for user authentication-service will be uploaded to the Authorizable Keystore. Option `aem.enable_saml` need to be set to true and options `system_users.authentication-service.authorizable_keystore.password`, `system_users.authentication-service.authorizable_keystore.certificate_chain`, `system_users.authentication-service.authorizable_keystore.private_key` & `system_users.authentication-service.authorizable_keystore.private_key_alias` needs to be defined. | Optional | false |
| system_users.authentication-service.authorizable_keystore.password | Password for the authorizable Keystore | Optional | |
| system_users.authentication-service.authorizable_keystore.certificate_chain | Source URL path of Certificate-Chain, it could be s3://..., http://..., https://..., or file://.... In [AWS Resources](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/aws-resources.md) case, it could be an S3 Bucket path, e.g. s3://somebucket/certs/cert-chain.crt | Optional | |
| system_users.authentication-service.authorizable_keystore.private_key | Source URL path of Private Key, it could be s3://..., http://..., https://..., or file://.... In [AWS Resources](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/aws-resources.md) case, it could be an S3 Bucket path, e.g. s3://somebucket/certs/cert-chain.crt | Optional | |
| system_users.authentication-service.authorizable_keystore.private_key_alias | Human readable name for storing `system_users.authentication-service.authorizable_keystore.private_key` + `system_users.authentication-service.authorizable_keystore.certificate_chain` in the Authorizable Keystore  | Optional | |


### AEM Stack Manager configuration properties:

These configurations are applicable specific to AEM Stack Manager.

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

These are log rotation configurations applicable to AEM Full-Set and Consolidated architectures depending on the `<component>` value in the configuration property.

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

The scheduled jobs configurations are applicable to AEM Full-Set and Consolidated architectures depending on the component.

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

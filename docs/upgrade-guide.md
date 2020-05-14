# Upgrade Guide

This upgrade guide covers the changes required when you already use AEM AWS Stack Builder and you need to upgrade it to a higher version.

### To 4.40.0
- If you want to set additional AEM runmodes, set configuration properties `aem.author.run_modes` and `aem.publish.run_modes`

### To 4.34.0

- If you want to add a HTTPS endpoint for SNS topic subscription, set configuration properties `stack_manager.alarm_notification.https_endpoint` and `messaging.alarm_notification.https_endpoint`
- Migrate `inbound_from_bastion_host_security_group` configuration property value for secgroup for allowing Jumphost inbound rule to `<component>.extra_grroups`

### To 4.30.0

- rhel7 default data volumes are now `/dev/xvdb` and `/dev/xvdc`, if you used to rely on the previous defaults of `/dev/sdb` and `/dev/sdc`, then you have to explicitly define those configurations

### To 4.24.0
- Rename `system_users.[admin|deployer|exporter|importer|orchestrator|replicator][.name|path]` configuration property to `system_users.[author|publish].[admin|deployer|exporter|importer|orchestrator|replicator].[name|path]`

### To 3.7.0

**Update configuration properties for configuring Publish-Dispatcher AutoScalingGroup:**

- Rename `publish_dispatcher.min_size` configuration property to`publish_dispatcher.asg_min_size`
- Rename `publish_dispatcher.max_size` configuration property to `publish_dispatcher.asg_max_size`
- Rename `publish_dispatcher.desired_capacity` configuration property to `publish_dispatcher.asg_desired_capacity`
- Add `publish_dispatcher.asg_health_check_grace_period` configuration property to `publish_dispatcher.asg_health_check_grace_period`
- Add `publish_dispatcher.asg_cooldown` configuration property to `publish_dispatcher.asg_cooldown`

**Update configuration properties for configuring Publish AutoScalingGroup:**

- Rename `publish.min_size` configuration property to `publish.asg_min_size`
- Rename `publish.max_size` configuration property to `publish.asg_max_size`
- Rename `publish.desired_capacity` configuration property to `publish.asg_desired_capacity`
- Add `publish.asg_health_check_grace_period` configuration property to `publish.asg_health_check_grace_period`
- Add `publish.asg_cooldown` configuration property to `publish.asg_cooldown`

**Update configuration properties for configuring Author-Dispatcher AutoScalingGroup:**

- Rename `author_dispatcher.min_size` configuration property to `author_dispatcher.asg_min_size`
- Rename `author_dispatcher.max_size` configuration property to `author_dispatcher.asg_max_size`
- Rename `author_dispatcher.desired_capacity` configuration property to `author_dispatcher.asg_desired_capacity`
- Add `author_dispatcher.asg_health_check_grace_period` configuration property to `author_dispatcher.asg_health_check_grace_period`
- Add `author_dispatcher.asg_cooldown` configuration property to `author_dispatcher.asg_cooldown`

## To 3.7.0

- Add `stack_manager.alarm_notification.contact_email` configuration property for Stack Manager

## To 3.3.0

- Rename `reconfiguration.keystore_password` configuration property to `reconfiguration.ssl_keystore_password`

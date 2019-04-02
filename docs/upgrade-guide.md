# Upgrade Guide

This upgrade guide covers the changes required when you already use AEM AWS Stack Builder and you need to upgrade it to a higher version.

# [Unreleased]

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

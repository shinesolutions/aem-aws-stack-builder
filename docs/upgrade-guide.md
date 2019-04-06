Upgrade Guide
-------------

This upgrade guide covers the changes required when you already use AEM AWS Stack Builder and you need to upgrade it to a higher version.

### To unreleased

* rhel7 default data volumes are now `/dev/xvdb` and `/dev/xvdc`, if you used to rely on the previous defaults of `/dev/sdb` and `/dev/sdc`, then you have to explicitly define those configurations

### To 3.7.0

* Add `stack_manager.alarm_notification.contact_email` configuration property for Stack Manager


### To 3.3.0

* Rename `reconfiguration.keystore_password` configuration property to `reconfiguration.ssl_keystore_password`

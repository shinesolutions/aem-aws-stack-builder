## Troubleshooting Guide

When a newly created AEM environment does not end up in a ready state, please follow the step by step troubleshooting guide below in order to identify the cause of the error.
Please note that if the error occurred before CloudWatch provisioning, then you'll need to SSH into the EC2 instances.

### Check EC2 instance provisioning progress

Run `grep aem-aws-stack-builder /var/log/messages` command, it will display where it's up to in the provisioning stages.

Here's an example output of a successful provisioning:

```
[picard@ip-10-0-10-58 ~]# grep aem-aws-stack-builder /var/log/messages
Aug  6 09:38:01 ip-10-0-10-58 cloud-init: + mkdir -p /opt/shinesolutions/aem-aws-stack-builder/
Aug  6 09:38:01 ip-10-0-10-58 cloud-init: + aws s3 cp s3://aem-opencloud/cliffs62-consolidated/stack-init.sh /opt/shinesolutions/aem-aws-stack-builder/stack-init.sh
Aug  6 09:38:06 ip-10-0-10-58 cloud-init: Completed 5.9 KiB/5.9 KiB (92.0 KiB/s) with 1 file(s) remaining#015download: s3://aem-opencloud/cliffs62-consolidated/stack-init.sh to opt/shinesolutions/aem-aws-stack-builder/stack-init.sh
Aug  6 09:38:06 ip-10-0-10-58 cloud-init: + chmod 755 /opt/shinesolutions/aem-aws-stack-builder/stack-init.sh
Aug  6 09:38:06 ip-10-0-10-58 cloud-init: + /opt/shinesolutions/aem-aws-stack-builder/stack-init.sh aem-opencloud cliffs62-consolidated author-publish-dispatcher 2.7.0
Aug  6 09:38:06 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] Initialising AEM Stack Builder provisioning...
Aug  6 09:38:06 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] AWS CLI version:
Aug  6 09:38:08 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] Facter version: 3.11.3 (commit 1854ababc68ec12ca40bdc143e46c3d5434b92ba)
Aug  6 09:38:14 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] Hiera version: 3.4.3
Aug  6 09:38:19 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] Puppet version: 5.5.3
Aug  6 09:38:19 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] Python version:
Aug  6 09:38:19 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] Ruby version: ruby 2.4.4p296 (2018-03-28 revision 63013) [x86_64-linux]
Aug  6 09:38:20 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] No Custom Stack Provisioner provided...
Aug  6 09:38:20 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] Downloading AEM Stack Provisioner...
Aug  6 09:38:35 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] Checking orchestration tags for author-publish-dispatcher component...
Aug  6 09:38:35 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] Setting AWS resources as Facter facts...
Aug  6 09:38:37 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] pre-common script of Custom Stack Provisioner is either not provided or not executable
Aug  6 09:38:37 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] Applying Puppet manifest for author-publish-dispatcher component...
Aug  6 09:43:42 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] Applying post-common scheduled jobs action Puppet manifest for all components...
Aug  6 09:43:46 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] post-common script of Custom Stack Provisioner is either not provided or not executable
Aug  6 09:43:46 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] Testing author-publish-dispatcher component using InSpec...
Aug  6 09:43:52 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] Cleaning up provisioner temp directory...
Aug  6 09:43:52 ip-10-0-10-58 cloud-init: [aem-aws-stack-builder] Completed author-publish-dispatcher component initialisation
```

That final message `Completed <component> component initialisation` indicates a successful provisioning.

If you don't see the completion message, then you have to rely on the last stage where it's up to. Open up `/var/log/messages`, find the stage message, and you'll likely find the error right after the stage message.

### Check Puppet provisioning failure

If the last stage message is `Applying Puppet manifest for <component> component...`, that indicates that an error has occurred on common AEM provisoining step using Puppet.

Run `grep "has failure" /var/log/shinesolutions/puppet-stack-init.log` command and you'll find the failing steps.

Open up `/var/log/shinesolutions/puppet-stack-init.log`, find the first occurrence of `has failure`, the lines above it are likely to be the cause of the error.

### Check AEM startup error

When provisioning fails due to an AEM error, you need to check AEM log by running `grep -i error /opt/aem/<author|publish>/crx-quickstart/logs/error.log` command and you'll find the error messages.

Please note that there could be errors that are not unrelated to the provisioning steps.

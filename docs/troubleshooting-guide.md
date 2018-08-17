Troubleshooting Guide
---------------------

### AEM Environment Provisioning

When a newly created AEM environment does not end up in a ready state, please follow the step by step troubleshooting guide below in order to identify the cause of the error.
Please note that if the error occurred before CloudWatch provisioning, then you'll need to SSH into the EC2 instances.

#### Check EC2 instance provisioning progress

Run `grep aem-aws-stack-builder /var/log/messages` command, it will display where it's up to in the provisioning stages.

Here's an example output of a successful provisioning:

```[picard@ip-10-0-10-58 ~]# grep aem-aws-stack-builder /var/log/messages
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

#### Check Puppet provisioning failure

If the last stage message is `Applying Puppet manifest for <component> component...`, that indicates that an error has occurred on common AEM provisioning stage using Puppet.

Run `grep "has failure" /var/log/shinesolutions/puppet-stack-init.log` command and you'll find the failing steps. For example:

```2018-07-10 15:32:36 +1000 /Stage[main]/Aem_curator::Config_publish/Aem_bundle[publish: Stop webdav bundle] (notice): Dependency Aem_aem[publish: Wait until login page is ready] has failures: true
2018-07-10 15:32:36 +1000 /Stage[main]/Aem_curator::Config_publish/Aem_bundle[publish: Stop davex bundle] (notice): Dependency Aem_aem[publish: Wait until login page is ready] has failures: true
2018-07-10 15:32:36 +1000 /Stage[main]/Aem_curator::Config_publish/Aem_aem[publish: Remove all agents] (notice): Dependency Aem_aem[publish: Wait until login page is ready] has failures: true
2018-07-10 15:32:36 +1000 /Stage[main]/Aem_curator::Config_publish/Aem_package[publish: Remove password reset package] (notice): Dependency Aem_aem[publish: Wait until login page is ready] has failures: true
...
```

The above example shows that the provisioning actions starting from `publish: Stop webdav bundle` failed because `publish: Wait until login page is ready` failed.

Open up `/var/log/shinesolutions/puppet-stack-init.log`, find the first occurrence of `has failure`, the lines above it are likely to be the cause of the error. For example:

```
(file: /opt/shinesolutions/aem-aws-stack-provisioner/modules/aem_curator/manifests/config_publish.pp, line: 109)
2018-07-10 15:31:13 +1000 Puppet (err): Could not set 'login_page_is_ready' on ensure: Unexpected response
status code: 503
headers: {"Date"=>"Tue, 10 Jul 2018 05:31:13 GMT", "Cache-Control"=>"must-revalidate,no-cache,no-store", "Content-Type"=>"text/html;charset=iso-8859-1", "Content-Length"=>"331"}
body: <html>
<head>
<meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1"/>
<title>Error 503 </title>
</head>
<body>
<h2>HTTP ERROR: 503</h2>
<p>Problem accessing /libs/granite/core/content/login.html. Reason:
<pre>    AuthenticationSupport service missing. Cannot authenticate request.</pre></p>
<hr />
</body>
</html>
 (file: /opt/shinesolutions/aem-aws-stack-provisioner/modules/aem_curator/manifests/config_publish.pp, line: 109)
Wrapped exception:
Unexpected response
status code: 503
headers: {"Date"=>"Tue, 10 Jul 2018 05:31:13 GMT", "Cache-Control"=>"must-revalidate,no-cache,no-store", "Content-Type"=>"text/html;charset=iso-8859-1", "Content-Length"=>"331"}
body: <html>
<head>
<meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1"/>
<title>Error 503 </title>
</head>
<body>
<h2>HTTP ERROR: 503</h2>
<p>Problem accessing /libs/granite/core/content/login.html. Reason:
<pre>    AuthenticationSupport service missing. Cannot authenticate request.</pre></p>
<hr />
</body>
</html>
2018-07-10 15:31:13 +1000 /Stage[main]/Aem_curator::Config_publish/Aem_aem[publish: Wait until login page is ready]/ensure (err): change from 'present' to 'login_page_is_ready' failed: Could not set 'login_page_is_ready' on ensure: Unexpected response
```

In the above example, AEM Publish instance keeps responding with HTTP status code `503` until the timeout is reached, so AEM login page ready check failed and subsequently caused the provisioning to fail.

#### Check whether application is running

Check out [Services](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/services.md) list to find out the applications' service names, the port numbers they're listening on (if any), the example processes, and which components should those applications run on.

Here are some useful commands to assist with checking the applications.

Check whether AEM Author is running on an `author-primary` component:

```
> service aem-author status
Redirecting to /bin/systemctl status aem-author.service
● aem-author.service - Adobe Experience Manager (author)
   Loaded: loaded (/usr/lib/systemd/system/aem-author.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2018-08-17 13:56:45 AEST; 24min ago
 Main PID: 9996 (java)
   CGroup: /system.slice/aem-author.service
           └─9996 java -Xss4m -Xms2048m -Xmx8192m -server -Djava.awt.headless=true -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -XX:+PrintGCApplica...

Aug 17 13:56:30 ip-10-0-13-52.ap-southeast-2.compute.internal systemd[1]: Starting Adobe Experience Manager (author)...
Aug 17 13:56:45 ip-10-0-13-52.ap-southeast-2.compute.internal systemd[1]: Started Adobe Experience Manager (author).
```

Check whether AEM Author and AEM Publish are listening on an `author-publish-dispatcher` component:

```
> netstat -an | grep 450
tcp6       0      0 :::4502                 :::*                    LISTEN
tcp6       0      0 :::4503                 :::*                    LISTEN
```

Check AEM Orchestrator process on `orchestrator` component:

```
> ps -ef | grep orchestrator
aem-orc+  9842     1  0 13:58 ?        00:00:00 /bin/bash /opt/shinesolutions/aem-orchestrator/aem-orchestrator.jar
aem-orc+  9889  9842  1 13:58 ?        00:00:20 /usr/bin/java -Dsun.misc.URLClassPath.disableJarChecking=true -jar /opt/shinesolutions/aem-orchestrator/aem-orchestrator.jar
```

#### Check application logs

When provisioning fails due to an AEM error, you need to check the errors on AEM log file by running `grep -i error /opt/aem/<author|publish>/crx-quickstart/logs/error.log` command. Please note that there could be application errors that are unrelated to the platform provisioning steps.

Check out [Logs](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/logs.md) for the full list of log files generated by the applications as part of AEM OpenCloud.

Here's an example of filtering errors from AEM Orchestrator log:

```
> grep -i error /opt/shinesolutions/aem-orchestrator/orchestrator.log
2018-08-17 14:05:24 [SessionCallBackSchedulerThread-1] ERROR c.s.a.a.AlarmContentHealthCheckAction - Publish instance i-0872b3a0bde108cf5 is in an unhealthy state
2018-08-17 14:05:50 [SessionCallBackSchedulerThread-1] ERROR c.s.a.a.AlarmContentHealthCheckAction - Publish instance i-03f349e042be811ad is in an unhealthy state
```

#### Reproducing provisioning error

If there's a provisioning error and you would like to reproduce the error, run the command `/var/lib/cloud/instance/scripts/part-001` to re-run exactly the same steps during cloud-init.

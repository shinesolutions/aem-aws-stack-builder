Logs
----

### Provisioning logs

| Log Path | Description | Components |
|----------|-------------|------------|
| `/var/log/shinesolutions/puppet-stack-init.log` | Puppet log of AEM provisioning steps executed during cloud-init. | All |
| `/var/log/shinesolutions/puppet-deploy-artifacts-init.log` | Puppet log of Dispatcher Config artifacts deployment. | `author-dispatcher`, `publish-dispatcher`, `author-publish-dispatcher` |

### Cron logs

| Log Path | Description | Components |
|----------|-------------|------------|
| `/var/log/shinesolutions/cron-content-health-check.log` | Log file of scheduled content health check task. | `publish-dispatcher`, `author-publish-dispatcher` |
| `/var/log/shinesolutions/cron-export-backups.log` | Log file of scheduled AEM Package export backup task. | `author-primary`, `publish` |
| `/var/log/shinesolutions/cron-live-snapshot-backup.log` | Log file of scheduled live snapshot backup task. | `author-primary`, `publish` |
| `/var/log/shinesolutions/cron-stack-offline-snapshot.log` | Log file of scheduled offline snapshot task. | `orchestrator` |
| `/var/log/shinesolutions/cron-stack-offline-compaction-snapshot.log` | Log file of scheduled offline compaction and snapshot task. | `orchestrator` |

### Application logs

#### AEM Author

| Log Path | Description | Components |
|----------|-------------|------------|
| `/opt/aem/author/crx-quickstart/logs/error.log` |  | `author-primary`, `author-standby`, `author-publish-dispatcher` |

#### AEM Dispatcher (Apache httpd)

#### AEM Orchestrator

| Log Path | Description | Components |
|----------|-------------|------------|
| `/opt/shinesolutions/aem-orchestrator/orchestrator.log` | [AEM Orchestrator](https://github.com/shinesolutions/aem-orchestrator) log. | `orchestrator` |

#### Chaos Monkey

| Log Path | Description | Components |
|----------|-------------|------------|
| `/var/log/tomcat/simianarmy.log` | [Simian Army](https://medium.com/netflix-techblog/the-netflix-simian-army-16e57fbab116) log. | `chaos-monkey` |



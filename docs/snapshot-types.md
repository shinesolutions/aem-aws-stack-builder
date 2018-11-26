Snapshot Types
--------------

In order to identify the EBS snapshots created during the lifetime of an AEM environment, each snapshot contains a `SnapshotType` tag with the following values:

| Snapshot Type | Description |
|---------------|-------------|
| live | Live snapshot is taken while AEM is up and running. There is a known risk of corrupted repository for live-snapshotted AEM Author, but AEM Publish does not have the same risk. Another value of creating regular live snapshots (by default hourly) is to speed up the time taken for taking the next snapshot. |
| offline | Offline snapshot is taken while AEM is not running, it is more reliable than live snapshot because an offline snapshot does not get corrupted. Due to the disruptive nature of offline snapshot (stopping AEM), by default offline snapshot is taken close to midnight. |
| orchestration | Orchestration snapshot is taken by [AEM Orchestrator](https://github.com/shinesolutions/aem-orchestrator) during AEM environment initialisation (for any AEM Publish instance after the first one) and during a recovery event (when a new AEM Publish instance is created). |

If you want to customise the schedule for taking each of the above snapshot types, please check out the [configuration page](configuration.md).

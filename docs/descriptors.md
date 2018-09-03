Descriptors
-----------

Traditionally, a number of operational activities (such as deploying AEM packages, creating AEM package backups, and performing content checks across a number of tenants within an AEM environment) have been tedious and error prone.

A production release might involve someone deploying a multiple AEM packages one by one, where the person triggering the deployment process needs to be careful about the order of the packages being deployed, and often the person needs to manually check whether each package deployment has really been completed or not.

In order to solve the above problem, AEM AWS Stack Builder supports descriptor-based AEM activities. For example, instead of deploying AEM packages one by one, those packages can be listed in a descriptor file, and the descriptor-based deployment process will upload and install those packages in sequence, and it will also perform a number of status checks for each package.

There are three types of descriptors:

* Deployment Descriptor
* Package Backup Descriptor
* Content Health Check Descriptor

### Deployment Descriptor

Deployment descriptor defines a list AEM packages and Dispatcher artifacts that should be deployed to a given component within an AEM environment.

Have a look at [Deployment Descriptor Definition](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/descriptors-definition-deployment.md) as a guide for creating your deployment descriptor.

Also check out the following examples:

* [Deployment descriptor for AEM Consolidated architecture](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/examples/descriptors/consolidated/deploy-artifacts-descriptor.json)
* [Deployment descriptor for AEM Full-Set architecture](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/examples/descriptors/full-set/deploy-artifacts-descriptor.json)

#### Usage:

1. Create the Deployment Descriptor following the above guide and examples
2. Place the descriptor at `stage/deploy-artifacts-descriptor.json`
3. Use [Stack Manager Messenger](https://github.com/shinesolutions/aem-stack-manager-messenger) with `deploy-artifacts-full-set` or `deploy-artifacts-full-set` target in order to trigger the deployment on demand
4. Alternatively, you can set configuration property `aem.enable_deploy_on_init` to `true` and the AEM packages and Dispatcher artifacts will be deployed during AEM environment creation. Note that this feature is currently only available for AEM Consolidated architecture.

### Package Backup Descriptor

Package Backup descriptor defines a list of AEM package backups along with the content filters for each of the package.

Have a look at [Package Backup Descriptor Definition](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/descriptors-definition-package-backup.md) as a guide for creating your package backup descriptor.

Also check out the following examples:

* [Package Backup descriptor for AEM Consolidated architecture](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/examples/descriptors/consolidated/export-backup-descriptor.json)
* [Package Backup descriptor for AEM Full-Set architecture](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/examples/descriptors/full-set/export-backup-descriptor.json)

#### Usage:

1. Create the Package Backup Descriptor following the above guide and examples
2. Place the descriptor at `stage/export-backup-descriptor.json`
3. Use [Stack Manager Messenger](https://github.com/shinesolutions/aem-stack-manager-messenger) with `export-packages-full-set` or `export-packages-consolidated` target to export backup AEM packages on demand
4. For scheduled export backup, you can set the [configuration](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md#aem-full-set-specific-configuration-properties) properties `scheduled_jobs.author_primary.export.*` and `scheduled_jobs.publish.export.*` to enable/disable it and to set the schedule when the export backup should run.

### Content Health Check Descriptor

Content Health Check descriptor defines a list of content paths to be checked as an indicator for content healthiness.

Have a look at [Content Health Check Descriptor Definition](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/descriptors-definition-content-health-check.md) as a guide for creating your content health check descriptor.

Also check out the following examples:

* [Content Health Check descriptor for AEM Consolidated architecture](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/examples/descriptors/consolidated/deploy-artifacts-descriptor.json)
* [Content Health Check descriptor for AEM Full-Set architecture](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/examples/descriptors/full-set/deploy-artifacts-descriptor.json)

#### Usage:

1. Create the Content Health Check Descriptor following the above guide and examples
2. Place the descriptor at `stage/content-healthcheck-descriptor.json`
3. For scheduled content health check, you can set the [configuration](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md#aem-full-set-specific-configuration-properties) properties `scheduled_jobs.publish_dispatcher.content_health_check.*`to enable/disable it and to set the schedule when the check should run.

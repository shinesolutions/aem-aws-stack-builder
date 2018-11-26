Package Backup Descriptor Definition
------------------------------------

[Package Backup Descriptor](descriptors.md#package-backup-descriptor) file is a JSON file that defines the list of AEM packages to be exported as a backup and then uploaded to S3.

Please find below the properties that you can define within the descriptor file:

| Property Name | Description | Value Type |
|---------------|-------------|------------|
| \<component> | [AEM AWS Stack Builder component name](https://github.com/shinesolutions/aem-aws-stack-builder#aem-aws-stack-builder). AEM packages are applicable for `author`, `publish`, and `author-publish-dispatcher` components. | Object |
| \<component>.packages | A list of AEM packages to be exported and then uploaded to S3. | Array |
| \<component>.packages.group | AEM package group, will be included in AEM package's metadata. | String |
| \<component>.packages.name | AEM package name, will be included in AEM package's metadata. | String |
| \<component>.packages.filter | An array of filter definitions. The content that matches the filter will then be included in the exported AEM package. | Array |
| \<component>.packages.filter.root | The filter's root path. All content underneath the root will then be matched against the filter rules. | String |
| \<component>.packages.filter.rules | A list of filter rules. | Array |
| \<component>.packages.filter.rules.modifier | Either `include` or `exclude`. More information at [AEM Package Filters doc](https://helpx.adobe.com/experience-manager/6-3/sites/administering/using/package-manager.html#PackageFilters). | String |
| \<component>.packages.filter.rules.pattern | Regular expression defining the the filter rule's pattern, applied on top of the filter root. | String |

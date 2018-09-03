Content Health Check Definition
-------------------------------

[Content Health Check Descriptor](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/descriptors.md#content-health-check-descriptor) file is a JSON file that defines the list of content URLs running on AEM Publish to be checked from its AEM Publish-Dispatcher pair.

Please find below the properties that you can define within the descriptor file:

| Property Name | Description | Value Type |
|---------------|-------------|------------|
| <component> | [AEM AWS Stack Builder component name](https://github.com/shinesolutions/aem-aws-stack-builder#aem-aws-stack-builder). AEM packages are applicable for `author`, `publish`, and `author-publish-dispatcher` components. | Object |
| <component>.packages | A list of AEM packages where each package defines a list of content URLs that are contained within the corresponding package. Please note that the concept of AEM package is used here because a piece of content is part of a package, so the package group and name are used to identify which package the content is part of, which is handy when your AEM environment consists of multiple tenants. | Array |
| <component>.packages.group | AEM package group. Even though it's not mandated, it's recommended to use the package group defined in the metadata of the AEM package which contains the content to be checked against. | String |
| <component>.packages.name | AEM package name. Even though it's not mandated, it's recommended to use the package name defined in the metadata of the AEM package which contains the content to be checked against. | String |
| <component>.packages.content | A list of content URL paths to be checked. Please note that this should not include the URL's protocol, host, and port. It should only contain the path. | Array |

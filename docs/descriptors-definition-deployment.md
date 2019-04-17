Deployment Descriptor Definition
--------------------------------

[Deployment Descriptor](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/descriptors.md#deployment-descriptor) file is a JSON file that defines the list of AEM Packages and Dispatcher artifacts to be deployed on to the corresponding components of an AEM environment.

Please find below the properties that you can define within the descriptor file:

| Property Name | Description | Value Type |
|---------------|-------------|------------|
| \<component> | [AEM AWS Stack Builder component name](https://github.com/shinesolutions/aem-aws-stack-builder#aem-aws-stack-builder). AEM packages are applicable for `author`, `publish`, and `author-publish-dispatcher` components. Dispatcher artifacts are applicable for `author-dispatcher`, `publish-dispatcher`, and `author-publish-dispatcher`.  | Object |
| \<component>.packages | A list of AEM packages to be deployed on the corresponding components. | Array |
| \<component>.packages.source | AEM package source URL, with support for s3, http, https, ftp, and file. Example for S3: `s3://some-bucket/path/to/file`. Not required when deleting or reinstalling a package. | String |
| \<component>.packages.group | AEM package group, must be consistent with the group defined in the AEM package's metadata. | String |
| \<component>.packages.name | AEM package name, must be consistent with the package name defined in the AEM package's metadata. | String |
| \<component>.packages.version | AEM package version number. Please ensure that the value is a string and is enclosed with double quotes in order to avoid a common problem where the version number is taken as a decimal number which omits trailing zeroes. This version must be consistent with the package version defined in the AEM package's metadata. | String |
| \<component>.packages.replicate | If set to `true`, the AEM package will be replicated after it has been installed. | Boolean |
| \<component>.packages.activate | If set to `true`, the content within the AEM package will be tree activated after the package has been installed. | Boolean |
| \<component>.packages.forces | If set to `true`, the AEM package will always be intalled regardless whether the package already exists or not. Otherwise, the package won't be installed if it already exists. | Boolean |
| \<component>.packages.aem_id | AEM ID is used to identify a particular AEM instance within a component. This is needed when you want to deploy to an AEM Publish instance within an `author-publish-dispatcher` component. Valid values: `author`, `publish`. Check out [AEM ID table](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/descriptors-definition-deployment.md#component-aem-id) further below to find out the AEM IDs applicable to the corresponding components. | String |
| \<component>.packages.sleep_seconds | The number of seconds to wait after installing the AEM package before proceeding with readiness check | Numeric string |
| \<component>.packages.ensure | If set to present, then the defined package gets installed. If set to absent, then the  defined package gets uninstalled. If set to reinstalled, then the defined package gets reinstalled. | Ensure/Present |
| \<component>.artifacts | A list of Dispatcher artifacts to be deployed on the corresponding components. Example artifacts: [AEM Hello World Author Dispatcher](https://github.com/shinesolutions/aem-helloworld-author-dispatcher), [AEM Hello World Publish Dispatcher](https://github.com/shinesolutions/aem-helloworld-publish-dispatcher) | Array |
| \<component>.artifacts.name | Dispatcher artifact name. This can be any name, but it's recommended to keep this name consistent with the artifact you're downloading. | String |
| \<component>.artifacts.source | Dispatcher artifact source URL, with support for s3, http, https, ftp, and file. Example for S3: `s3://some-bucket/path/to/file` . | String |

#### Component AEM ID

Use the table below to identify the value of `<component>.packages.aem_id` property you have to provide. If you don't specify this property within the Deployment Descriptor file, it will then be assumed to use the default, i.e. on an AEM Author, the package will be deployed to the default `author` AEM ID.

Please note that you *must* provide the AEM ID if the AEM package is to be deployed to the AEM Publish instance within an `author-publish-dispatcher` component.

| Component | Default AEM ID | Valid AEM ID(s) |
|-----------|----------------|-----------------|
| author | author | author |
| publish | publish | publish |
| author-publish-dispatcher | author | author, publish |

Customisation Points
--------------------

Since every user has a unique standard operating environment and security requirements, AEM AWS Stack Builder provides two customisation points where user can provision any specific setup.

### Configuration

You can set up a number of [configuration properties](configuration.md) to suit your requirements.
Have a look at the [user config examples](https://github.com/shinesolutions/aem-aws-stack-builder/tree/master/examples/user-config) for reference on what configuration values you need to set for various architectures and permission types.

This allows you to create a number of configuration profiles. For example, you might have the following configuration profiles like these:

* A config profile for developers' ad-hoc use in non-prod
* A config profile for testers' ad-hoc use in non-prod
* A config profile for automated tests running on CI tools triggered by a pull-request merge
* A config profile for UAT purpose with production-like setting but in non-prod
* A config profile for the actual production system

The above list is just a simple example. You can build more profiles to cover the combination of various architectures, various AEM versions, various library versions, and perhaps down to various resource optimisations.

### Custom Stack Provisioner

For component-specific software and settings, they can be provisioned using Custom Stack Provisioner, which provides a pre step to be executed before provisioning the component itself, and a post step to be executed after.

For example, if you need to set up component-specific configuration for additional software such as [New Relic Agents](https://docs.newrelic.com/docs/agents), then these configurations need to be bundled within the Custom Stack Provisioner artifact and the set up steps could be executed in either the pre or post step.

In order to use Custom Stack Provisioner you only need to place the artifact at `stage/custom/aem-custom-stack-provisioner.tar.gz` . It will then be uploaded to S3, and then downloaded to EC2 instances during cloud-init.

To get an idea how this artifact should be structured, please have a look at the example repository [AEM Hello World Custom Stack Provisioner](https://github.com/shinesolutions/aem-helloworld-custom-stack-provisioner).

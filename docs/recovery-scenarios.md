Recovery Scenarios
------------------

### Individual instance failure

For an individual instance failure on `author-dispatcher`, `publish`, `publish-dispatcher`, `orchestrator`, and `chaos-monkey` components will auto-recover.

Whereas `author-primary` and `author-standby` instance failure will require the creation of a new AEM Full-Set environment.

Please check out [recovery steps](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/recovery-steps.md) documentation for detailed recovery steps of each corresponding component.

### Availability zone failure

Assuming two or more availability zones are used.

When an availability zone fails, `author-dispatcher`, `publish`, `publish-dispatcher`, `orchestrator`, and `chaos-monkey` components instances which run on the failing availability zone would be terminated, and their corresponding Auto Scaling Groups will launch replacement instances on one of the remaining availability zones.

When an `author-primary` instance runs on the failing availability zone and it gets terminated, you need to promote the Author-Standby to become an Author-Primary in order to allow content authoring activity to continue. You will then need to create a new AEM Full-Set environment which is configured to not include the failing availability zone.

When an `author-standby` instance runs on the failing availability zone and it gets terminated, content authoring activity can continue because the Author-Primary is still up and running. In order to get a complete environment, you will then need to create a new AEM Full-Set environment which is configured to not include the failing availability zone.

Please check out [recovery steps](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/recovery-steps.md) documentation for detailed recovery steps of each corresponding component.

### Region failure

In the event where the whole region fails, a new AEM environment can be created in another region by configuring `aws.region` value.

However, this also requires all the corresponding [AWS resources](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/aws-resources.md) to also be available in the new region.

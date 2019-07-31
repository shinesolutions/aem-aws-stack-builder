Recovery
--------

AEM Full-Set environment includes auto-recovery feature where most of the components are able to automatically recover from failure.

There are three types of recovery process:

* [Basic Auto Scaling Group auto-recovery](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/recovery.md#basic-auto-scaling-group-auto-recovery) - used by `orchestrator`, and `chaos-monkey` components
* [AEM Orchestrator-assisted auto-recovery](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/recovery.md#aem-orchestrator-assisted-auto-recovery) - used by `author-dispatcher`, `publish`, and `publish-dispatcher` components
* [AEM Author promotion recovery](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/recovery.md#aem-author-promotion-recovery) - used by `author-primary` and `author-standby`

### Basic Auto Scaling Group auto-recovery

The `orchestrator` and `chaos-monkey` components are implemented with basic [Auto Scaling Groups](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroup.html) where desired capacity, minimum size, and maximum size are defined in [configuration file](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md).

When an instance of `orchestrator` or `chaos-monkey` component gets terminated (e.g. due to health check failure), then AEM Full-Set will auto-recover by launching a new instance to replace the terminated one, ensuring a complete state is satisfied.

Learn more about the detailed recovery steps:

* [orchestrator recovery steps](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/recovery-steps#orchestrator-recovery-steps.md)
* [chaos-monkey recovery steps](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/recovery-steps#chaos-monkey-recovery-steps.md)

### AEM Orchestrator-assisted auto-recovery

The `author-dispatcher`, `publish` and `publish-dispatcher` components are paired, and hence recovery requires an orchestration which is handled by [AEM Orchestrator](https://github.com/shinesolutions/aem-orchestrator).

When a `author-dispatcher`, `publish`, or `publish-dispatcher` component instance gets terminated, then the termination event will be sent to an SNS topic, which is then subscribed by an SQS queue, which in turn is consumed by AEM Orchestrator. The AEM Orchestrator then updates the corresponding AEM component and AutoScalingGroup setting.

Learn more about the detailed recovery steps:

* [author-dispatcher recovery steps](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/recovery-steps#author-dispatcher-recovery-steps.md)
* [publish recovery steps](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/recovery-steps#publish-recovery-steps.md)
* [publish-dispatcher recovery steps](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/recovery-steps#publish-dispatcher-recovery-steps.md)

### AEM Author promotion recovery

The `author-primary` and `author-standby` components are currently not in any Auto Scaling Group.

When `author-primary` component gets terminated, then `author-standby` component needs to be promoted to become an `author-primary` in order to allow content authoring to resume. However, at this point the environment is not at a complete state, so when either `author-primary` or `author-standby` component is missing, then blue/green deployment needs to be triggered.

We have a backlog task to place the Author components in AutoScalingGroups in order to automate the recovery process, but until then, for now we have to rely on human-triggered recovery (in AEM OpenCloud Manager, it is implemented as an operational task to promote Author-Standby into Author-Primary).

Learn more about the detailed recovery steps:

* [author-primary recovery steps](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/recovery-steps#author-primary-recovery-steps.md)
* [author-standby recovery steps](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/recovery-steps#author-standby-recovery-steps.md)

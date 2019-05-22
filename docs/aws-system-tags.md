AWS System Tags
---------------

In order to identify the AWS resources (e.g. EC2 instance, snapshot, ELB, ASG) that are used as part of an AEM environment, the following system tags are set up following [AWS Tagging Strategies](https://aws.amazon.com/answers/account-management/aws-tagging-strategies/):

| Name | Description |
|------|-------------|
| StackPrefix | The stack prefix value specified during AEM environment creation process. |
| Name | The name of the resource. |
| Component | Value is either one of `author-primary`, `author-standby`, `publish`, `author-dispatcher`, `publish-dispatcher`, `orchestrator`, `chaos-monkey`, `author-publish-dispatcher` |
| AemId | Value is either `author` or `publish`. |
| ComponentInitStatus | Values can be `Success`, `InProgress` or failed. |
| SnapshotType | Please check out the [snapshot types](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/snapshot-types.md). |

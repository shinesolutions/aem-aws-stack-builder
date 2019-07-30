AWS Services
------------

The following AWS services are used by AEM environments created by AEM AWS Stack Builder.

| AWS Service | Descriptions |
|-------------|--------------|
| EC2 | EC2 AMIs are used for storing application components installation. Instances are used for running application components. Auto Scaling Groups and Launch Configurations are used for auto-scaling and auto-recovery of the application components. Load Balancers are used for distribute traffic going to AEM Author-Dispatcher, Author, and Publish-Dispatcher components. Elastic Block Storage volumes and snapshots are used for backup, recovery, and deployment features. Security Groups are used to define inbound and outbound rules for each component. Key Pairs are used to define SSH keys pairs which will be associated to the component instances. |
| S3 | S3 buckets are used for storing application artifacts for provisioning the component instances, for storing AEM packages to be deployed onto AEM instances, and for storing AEM packages created as package backup export. |
| IAM | IAM roles and policies are used to define the permissions allowed for each instance to execute. |
| CloudFormation | CloudFormation Stacks are used to define the AWS resources of AEM Stack Manager, AEM Consolidated, and AEM Full-Set infrastructure. |
| CloudWatch | CloudWatch Metrics are used to store various metrics of both AEM application and environments. Logs are used for storing all application logs running on the instances. Alarms are used for sending notification when AEM metrics reach certain threshold. Dashboards are used for visualising important metrics from the AEM environments. |
| Simple Queue Service | SQS is used to queue Auto Scaling Group events, which is sent to an SNS topic, which AEM Orchestrator then handles accordingly for auto-recovery and auto-scaling features. |
| Simple Notification Service | SNS Topics are used for sending event notification on AEM Stack Manager, AEM Consolidated, and AEM Full-Set environments. |
| Certificate Manager | Certificate Manager is used for storing TLS certificate provisioned on Author-Dispatcher, Author, and Publish-Dispatcher ELBs. |
| Systems Manager | Systems Manager Run Command is used for executing operational tasks on components instances. Parameter Store is used for storing secrets, such as AEM license, to be provisioned on AEM environments. Session Manager is used for managing the instances via AWS console. |
| Secrets Manager | Secrets Manager is used for storing secrets which can't fit in Parameter Store, for example: a private key. |
| CloudFront | CloudFront distributions are used for multi-region caching of AEM content served via AEM Publish-Dispatcher ELB. |
| SimpleDB | SimpleDB is used by Chaos Monkey. |

AWS Resources
-------------

For creating AEM environments using AEM AWS Stack Builder, the following resources must be available:

- Create [EC2 key pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html), this key pair name needs to be set in `compute.key_pair_name` [configuration](configuration.md) property.
- Provision an SSL/TLS certificate either on [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/getting-started/) or [IAM](https://docs.aws.amazon.com/cli/latest/reference/iam/upload-server-certificate.html)
- Create an S3 Data Bucket for storing AEM environment states, this bucket path needs to be set in `s3.data_bucket_name` property
- Create the AMIs using [Packer AEM](https://github.com/shinesolutions/packer-aem/) and configure the IDs in `ami_ids.<component>` properties
- Create a [Route53 private hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zone-private-creating.html), the hosted zone name needs to be set in `dns_records.route53_hosted_zone_name` property, and don't forget to include the trailing dot as part of the name
- If your bastion host doesn't have any security group yet then you need to create one for it, and configure that security group in `compute.inbound_from_bastion_host_security_group` property

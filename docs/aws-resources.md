AWS Resources
-------------

For creating AEM environments using AEM AWS Stack Builder, a number of AWS resources must be available as prerequisites.

### User-managed provisioning

Due to the fact that majority of user's organisation policies requiring private key, SSL/TLS certificate, and bastion host to be managed by the users and not by any external automation process, the following resources must be provisioned by the users:

- Create [EC2 key pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html), this key pair name needs to be set in `compute.key_pair_name` [configuration](https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md) property.
- Provision an SSL/TLS certificate either on [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/getting-started/) or [IAM](https://docs.aws.amazon.com/cli/latest/reference/iam/upload-server-certificate.html)
- If your bastion host doesn't have any security group yet then you need to create one for it, and configure that security group in `compute.inbound_from_bastion_host_security_group` property

Ensure that you have the AEM OpenCloud AMIs and configure them on AEM AWS Stack Builder's user configuration:

- Create the AMIs using [Packer AEM](https://github.com/shinesolutions/packer-aem/) and configure the IDs in `ami_ids.<component>` properties

### CloudFormation stack

If you have the permission to provision the AWS resources using a CloudFormation stack, run the this command to create or update the resources:

    make create-aws-resources stack_prefix=<stack_prefix> config_path=stage/user-config/

The aws-resources stack will contain:

- An S3 Data Bucket for storing AEM environment states, which needs to be set in `s3.data_bucket_name` property
- A [Route53 private hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zone-private-creating.html), the hosted zone name needs to be set in `dns_records.route53_hosted_zone_name` property, and don't forget to include the trailing dot as part of the name

And to delete the resources within the CloudFormation stack:

    make delete-aws-resources stack_prefix=<stack_prefix> config_path=stage/user-config/

### Manual provisioning

Alternatively, if you don't have the permission, or you have to integrate them into your pre-existing provisioning mechanism, you can follow the steps below as reference:

- Create an S3 Data Bucket for storing AEM environment states, this bucket path needs to be set in `s3.data_bucket_name` property
- Add the following policy to the bucket to allow AWS ELB's to write logs to the bucket:
```
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::AWS-ELB-AccountID:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::BUCKETNAME/*"
        }
    ]
}
```
More information about the AWS ELB Account ID can be found here: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
- Create a [Route53 private hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zone-private-creating.html), the hosted zone name needs to be set in `dns_records.route53_hosted_zone_name` property, and don't forget to include the trailing dot as part of the name

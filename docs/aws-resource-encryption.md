AWS Resource encryption
-------------

## Permissions
A list of permission which is required for the CMK in order AEM OpenCloud can work properly.

Managed policies are used to replace grants to the CMK.
### Permission-Type B Full-Set
Permissions required for Permission-Type B Full-Set
#### CMK Permissions
Permissions which needs to be applied to the CMK
##### EBS CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| `arn:aws:iam::AWS_ACCOUNT_ID:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling` | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | None | |
| `arn:aws:iam::AWS_ACCOUNT_ID:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling` | CreateGrant, ListGrants, RevokeGrant | GrantIsForAWSResource |

##### SNS CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| `arn:aws:iam::AWS_ACCOUNT_ID:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling` | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | None | |
| `arn:aws:iam::AWS_ACCOUNT_ID:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling` | CreateGrant, ListGrants, RevokeGrant | GrantIsForAWSResource |
| `cloudwatch.amazonaws.com` | GenerateDataKey, Decrypt | Service permission | |
| `sns.amazonaws.com` | GenerateDataKey, Decrypt | Service permission | |

##### DynamoDB CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| None | None | |

##### Lambda CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| None| None | |

##### S3 CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| None| None | |

#### managed-policy permissions
Only needed if managed-policies are used rather than permission grants. Make sure that the general permissions as described in **CMK Permissions** are defined to the CMK as described.
##### EBS encryption
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| EBS CMK managed-policy | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo, RetireGrant, CreateGrant | |

##### SNS CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| SNS CMK managed-policy | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo, RetireGrant, CreateGrant | |

##### DynamoDB CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| None | None | |

##### Lambda CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| Lambda CMK managed-policy | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo, RetireGrant, CreateGrant |

##### S3 CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| S3 CMK managed-policy | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo, RetireGrant, CreateGrant | |

### Permission-Type B Consolidated
Permissions required for Permission-Type B Consolidated
#### CMK Permissions
Permissions which needs to be applied to the CMK
#### EBS CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| None | None | |

#### SNS CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| None | None | |

#### DynamoDB CMK
| Permission | Required Permissions | Notes |
|------|-------------|------|
| None | None | |

#### Lambda CMK
| Permission | Required Permissions | Notes |
|------|-------------|------|
| None| None | |

##### S3 CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| None| None | |

#### managed-policy permissions
Only needed if managed-policies are used rather than permission grants. Make sure that the general permissions as described in **CMK Permissions** are defined to the CMK as described.
##### EBS encryption
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| EBS CMK managed-policy | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo, RetireGrant, CreateGrant | |

#### SNS CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| None | None | | |

##### DynamoDB CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| None | None | |

##### Lambda CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| None | None | |

##### S3 CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| S3 CMK managed-policy | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo, RetireGrant, CreateGrant | |

### Permission-Type B AEM Stack Manager
Permissions required for Permission-Type B AEM Stack Manager.
#### CMK Permissions
Permissions which needs to be applied to the CMK.
##### EBS CMK
| Permission | Required Permissions | Notes |
|------|-------------|------|
| None | None | |

##### SNS CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| `sns.amazonaws.com` | GenerateDataKey, Decrypt | Service permission |

##### DynamoDB CMK
| Permission | Required Permissions | Notes |
|------|-------------|------|
| None | None | |

##### Lambda CMK
| Permission | Required Permissions | Notes |
|------|-------------|------|
| None| None | |

##### S3 CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| None| None | |

#### managed-policy permissions
Only needed if managed-policies are used rather than permission grants. Make sure that the general permissions as described in **CMK Permissions** are defined to the CMK as described.
##### EBS encryption
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| None | None | |

#### SNS CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| SNS CMK managed-policy | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo, RetireGrant, CreateGrant | |

##### DynamoDB CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| DynamoDB CMK managed-policy | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo, RetireGrant, CreateGrant | |

##### Lambda CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| Lambda CMK managed-policy | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo, RetireGrant, CreateGrant | |

##### S3 CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| S3 CMK managed-policy | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo, RetireGrant, CreateGrant | |

### Permission-Type C Full-Set
Permissions required for Permission-Type C Full-Set
#### CMK Permissions
Permissions which needs to be applied to the CMK

##### EBS CMK
| Permission | Required Permissions | Notes |
|------|-------------|------|
| publish_dispatcher.instance_profile | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | |
| publish.instance_profile | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | |
| author.instance_profile | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | |
| author_dispatcher.instance_profile | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | |
| orchestrator.instance_profile | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | |
| chaos_monkey.instance_profile | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | |
| `arn:aws:iam::AWS_ACCOUNT_ID:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling` | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | None | |
| `arn:aws:iam::AWS_ACCOUNT_ID:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling` | CreateGrant, ListGrants, RevokeGrant | GrantIsForAWSResource |

##### SNS CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| `arn:aws:iam::AWS_ACCOUNT_ID:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling` | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey |  |
| `arn:aws:iam::AWS_ACCOUNT_ID:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling` | CreateGrant, ListGrants, RevokeGrant | GrantIsForAWSResource |
| `cloudwatch.amazonaws.com` | GenerateDataKey, Decrypt | Service permission | |
| `sns.amazonaws.com` | GenerateDataKey, Decrypt | Service permission | |
| orchestrator.instance_profile | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo |  |
| stack_manager.lambda_service_role_arn | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo |  |

##### DynamoDB CMK
| Permission | Required Permissions | Notes |
|------|-------------|------|
| None | None | |

##### Lambda CMK
| Permission | Required Permissions | Notes |
|------|-------------|------|
| stack_manager.lambda_service_role_arn | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo |  |

##### S3 CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| publish_dispatcher.instance_profile | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | |
| publish.instance_profile | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | |
| author.instance_profile | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | |
| author_dispatcher.instance_profile | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | |
| orchestrator.instance_profile | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | |
| chaos_monkey.instance_profile | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | |

### Permission-Type C Consolidated
Permissions required for Permission-Type C Consolidated
#### CMK Permissions
Permissions which needs to be applied to the CMK
##### EBS CMK
| Permission | Required Permissions | Notes |
|------|-------------|------|
| author_publish_dispatcher.instance_profile | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | |

##### SNS CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| None | None | |

##### DynamoDB CMK
| Permission | Required Permissions | Notes |
|------|-------------|------|
| None | None | |

##### Lambda CMK
| Permission | Required Permissions | Notes |
|------|-------------|------|
| None | None | |

##### S3 CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| author_publish_dispatcher.instance_profile | Encrypt, Decrypt, ReEncrypt*, GenerateDataKey*, DescribeKey | |

### Permission-Type C AEM Stack Manager
Permissions required for Permission-Type C AEM Stack Manager
#### CMK Permissions
Permissions which needs to be applied to the CMK
##### EBS CMK
| Permission | Required Permissions | Notes |
|------|-------------|------|
| None | None | |

##### SNS CMK
| Permission | Required Permissions | Notes |
|------|-------------|------|
| `sns.amazonaws.com` | GenerateDataKey, Decrypt | Service permission |
| Config parameter: `stack_manager.lambda_service_role_arn` | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo |  |
| Config parameter: `stack_manager.ssm_service_role_arn` | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo |  |

##### DynamoDB CMK
| Permission | Required Permissions | Notes |
|------|-------------|------|
| Config parameter: `stack_manager.lambda_service_role_arn` | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo |  |

##### Lambda CMK
| Permission | Required Permissions | Notes |
|------|-------------|------|
| Config parameter: `stack_manager.lambda_service_role_arn` | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo |  |

##### S3 CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| Config parameter: `stack_manager.lambda_service_role_arn` | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo |  |
| Config parameter: `stack_manager.ssm_service_role_arn` | Encrypt, Decrypt, DescribeKey, GenerateDataKey, ReEncryptFrom, ReEncryptTo |  |

### CloudFront permissions
Permissions required for CloudFront
#### CMK Permissions
Permissions which needs to be applied to the CMK
##### S3 CMK
| Role/Service | Required Permissions | Notes |
|------|-------------|------|
| delivery.logs.amazonaws.com | kms:GenerateDataKey | Service permission |

### AEM Stack manager Cloudwatch S3 Stream permissions
The AEM Stack manager Cloudwatch S3 Stream currently only supports encryption, if the configuration parameter `stack_name.cloudwatch_stream.s3_bucket` refers to the same bucket as the configuration parameter `s3.data_bucket_name`.

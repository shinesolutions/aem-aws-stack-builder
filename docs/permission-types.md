## Permission Types

In order to support multiple resource restrictions across the various types of users/organisations, AEM AWS Stack Builder provides the following permission types:

| Permission Type | Restrictions |
|-----------------|--------------|
| a | No restriction, allowed to create everything |
| b | Not allowed to create SSL certificate and private key |
| c | Not allowed to create SSL certificate and private key, IAM and Route53 AWS resources |

For example, if your organisation doesn't allow you to create any instance profile, perhaps because IAM access is controlled by an external group. You should use `permission_type: c` so that those existing resources can be configured for the created AEM environment to consume.

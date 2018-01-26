## Configuration

| Name                                         | Description |
|----------------------------------------------|-------------|
| publish_dispatcher.stack_name                | TODO        |
| publish_dispatcher.instance_profile          | TODO        |
| publish_dispatcher.instance_type             | TODO        |
| publish_dispatcher.min_size                  | TODO        |
| publish_dispatcher.max_size                  | TODO        |
| publish_dispatcher.load_balancer.tag_name    | TODO        |
| publish_dispatcher.tag_name                  | TODO        |
| publish_dispatcher.elb_health_check          | TODO        |
| publish_dispatcher.route53_record_set_name   | TODO        |
| chaos_monkey.stack_name                      | TODO        |
| chaos_monkey.ami_id                          | TODO        |
| chaos_monkey.instance_profile                | TODO        |
| chaos_monkey.instance_type                   | TODO        |
| chaos_monkey.tag_name                        | TODO        |

## Development

Requirements:

* Install [ShellCheck](https://github.com/koalaman/shellcheck#user-content-installing)

Check shell scripts, validate CloudFormation templates, check Ansible playbooks syntax:
```
make lint
```

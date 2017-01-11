# aem-aws-stack-builder
Cloudformation templates (yaml) for creating an AEM Stack

Network (shared) Stacks:
* vpc
* network

AEM Application (specific) Stacks:
* roles (can be shared across stacks)
* security-groups
* messaging
* publish-dispatcher
* publish
* author
* author-dispatcher
* orchestrator
* chaos-monkey

Prerequisites:
* ec2 key pair
* ssl server certificate
* ami images for publish-dispatcher, publish, author, author-dispatcher, orchestrator, chaos-monkey (with component and version tags)
* dns hosted zone
* provisioning init script accessible via s3 bucket
* inbound_from_bastion_host_security_group
* nat gateway / internet proxy


## Installation

Requirements:

* Install [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) and [configure](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-quick-configuration) it
* Install [Ansible](http://docs.ansible.com/ansible/intro_installation.html) v2.2.x or newer
* Install [GNU Make](https://www.gnu.org/software/make/) (optional, see Makefile to use commands directly)

## Usage

Requirements:

* Set up certificate in [AWS IAM](https://aws.amazon.com/iam), check out `create-cert`, `upload-cert`, and `delete-cert` targets in the Makefile

### Shared Stack

Create VPC Stack:
```
make create-shared-stack stack=vpc
```


Create Network Stack:
```
make create-shared-stack stack=network
```


Delete VPC Stack:

```
make delete-shared-stack stack=vpc
```


Delete Network Stack:
```
make delete-shared-stack stack=network
```


### Nat-Gateway Stack

Nat Gateway can be optional, as you may already have an existing Nat or Internet Proxy you would like to use instead


Create Nat-Gateway Stack:
```
make create-shared-stack stack=nat-gateway
```


Delete Nat-Gateway Stack:

```
make delete-shared-stack stack=nat-gateway
```


### Roles Stack

Roles can be shared or specific to an individual stack.

```
make create-shared-roles-stack
```


```
make delete-shared-roles-stack
```

### Specific Stack


Create Security Groups Stack:
```
make create-stack prefix=default stack=security-groups
```


Delete Security Groups Stack:
```
make delete-stack prefix=default stack=security-groups
```


Create Messaging Stack:
```
make create-stack prefix=default stack=messaging
```

Delete Messaging Stack:
```
make delete-stack prefix=default stack=messaging
```


Create Publish Dispatcher Stack:
```
make create-stack prefix=default stack=publish-dispatcher
```

Delete Publish Dispatcher Stack:
```
make delete-stack prefix=default stack=publish-dispatcher
```


Create Publish Stack:
```
make create-stack prefix=default stack=publish
```

Delete Publish Stack:
```
make delete-stack prefix=default stack=publish
```


Create Author Stack:
```
make create-stack prefix=default stack=author
```

Delete Author Stack:
```
make delete-stack prefix=default stack=author
```


Create Author Dispatcher Stack:
```
make create-stack prefix=default stack=author-dispatcher
```

Delete Author Dispatcher Stack:
```
make delete-stack prefix=default stack=author-dispatcher
```

Create Orchestrator Stack:
```
make create-stack prefix=default stack=orchestrator
```

Delete Orchestrator Stack:
```
make delete-stack prefix=default stack=orchestrator
```

Create Chaos Monkey Stack:
```
make create-stack prefix=default stack=chaos-monkey
```

Delete Chaos Monkey Stack:
```
make delete-stack prefix=default stack=chaos-monkey
```


### Shared Stack

Create VPC Stack:
```
make ansible-create-stack stack=vpc inventory=default
```

Delete VPC Stack:
```
make ansible-delete-stack stack=vpc inventory=default
```

Create Network Stack:
```
make ansible-create-stack stack=network inventory=default
```

Delete Network Stack:
```
make ansible-delete-stack stack=network inventory=default
```


### Roles Stack

Create Roles Stack:
```
make ansible-create-stack stack=roles inventory=default
```

Delete Roles Stack:
```
make ansible-delete-stack stack=roles inventory=default
```



### Specific Stack

Create Security Groups Stack:
```
make ansible-create-stack stack=security-groups inventory=default
```

Delete Security Groups Stack:
```
make ansible-delete-stack stack=security-groups inventory=default
```

Create Messaging Stack:
```
make ansible-create-stack stack=messaging inventory=default
```

Delete Messaging Stack:
```
make ansible-delete-stack stack=messaging inventory=default
```



Create Publish Dispatcher Stack:
```
make ansible-create-stack stack=publish-dispatcher inventory=default
```

Delete Publish Dispatcher Stack:
```
make ansible-delete-stack stack=publish-dispatcher inventory=default
```

Create Publish Stack:
```
make ansible-create-stack stack=publish inventory=default
```

Delete Publish Stack:
```
make ansible-delete-stack stack=publish inventory=default
```

Create Author Stack:
```
make ansible-create-stack stack=author inventory=default
```

Delete Author Stack:
```
make ansible-delete-stack stack=author inventory=default
```

Create Author Dispatcher Stack:
```
make ansible-create-stack stack=author-dispatcher inventory=default
```

Delete Author Dispatcher Stack:
```
make ansible-delete-stack stack=author-dispatcher inventory=default
```

Create Orchestrator Stack:
```
make ansible-create-stack stack=orchestrator inventory=default
```

Delete Orchestrator Stack:
```
make ansible-delete-stack stack=orchestrator inventory=default
```


Create Chaos Monkey Stack:
```
make ansible-create-stack stack=chaos-monkey inventory=default
```

Delete Chaos Monkey Stack:
```
make ansible-delete-stack stack=chaos-monkey inventory=default
```

### Full AEM Application Stack

Create AEM Stack:
```
make create-aem-stack inventory=default
```

Delete AEM Stack:
```
make delete-aem-stack inventory=default
```


## Configuration

Work in Progress


## Development

Requirements:

* Install [ShellCheck](https://github.com/koalaman/shellcheck#user-content-installing)

Check shell scripts, validate CloudFormation templates, check Ansible playbooks syntax:
```
make lint
```

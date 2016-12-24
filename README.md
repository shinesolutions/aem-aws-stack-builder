# aem-aws-stack-builder
Cloudformation templates (yaml) for creating an AEM Stack

## Installation

Requirements
* [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* [GNU Make](https://www.gnu.org/software/make/) (optional, see Makefile to use commands instead)




## Usage

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

### Roles Stack

Roles can be shared or specific to an individual stack.

```
make create-roles-stack
```


```
make delete-roles-stack
```

### Specific Stack


Create Security Groups Stack:
```
make create-stack moniker=default stack=security-groups
```


Create Security Groups Stack:
```
make create-stack moniker=default stack=security-groups
```



Create Publish Dispatcher Stack:
```
make create-stack moniker=default stack=publish-dispatcher
```

Delete Publish Dispatcher Stack:
```
make delete-stack moniker=default stack=publish-dispatcher
```


## Ansible

Requirements:

* [Ansible](http://docs.ansible.com/ansible/intro_installation.html)
* [Boto](https://github.com/boto/boto)


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

Create Publish Dispatcher Stack:
```
make ansible-create-stack stack=publish-dispatcher inventory=default
```

Delete Publish Dispatcher Stack:
```
make ansible-delete-stack stack=publish-dispatcher inventory=default
```



## Configuration

Work in Progress


## Development

Requirements:
* [ShellCheck](https://github.com/koalaman/shellcheck)

Validate Cloudformation templates:
```
make validate
```

Check Shell Scripts
```
make shellcheck
```


https://github.com/k1LoW/awspec



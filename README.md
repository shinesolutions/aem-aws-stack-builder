# aem-aws-stack-builder
Cloudformation templates (yaml) for creating an AEM Stack

## Installation

Requirements
* [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* [GNU Make](https://www.gnu.org/software/make/) (optional, see Makefile to use commands instead)




## Usage


Create VPC Stack:
```
make create-vpc-stack
```


Create Network Stack:
```
make create-network-stack
```


Delete VPC Stack:

```
make delete-vpc-stack
```


Delete Network Stack:
```
make delete-network-stack
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



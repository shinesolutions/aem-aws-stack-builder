Stacks Structure
----------------

AEM AWS Stack Builder heavily utilises [CloudFormation stacks](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacks.html) to provide structure to the AWS resources defined within the supported AEM architectures.

The diagrams further below describe the relationship between the stacks, which differ between architectures and permission types. Please take note of the following keys:

* Light yellow box represents a [nested stack](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-nested-stacks.html)
* Light orange box represents a parent/root stack
* Arrow represents association between the two stacks, indicating that the stack on the left exports some values which are consumed by the stack on the right

### Prerequisites and main stacks

Each AEM architecture has a prerequisites stack and a main stack. The prerequisites stacks contain AWS resources that are slow(er) to provision. The main stacks contain AWS resources that are fast(er) to provision. The associations between these stacks depend on the AEM architecture:

* AEM Consolidated architecture allows one prerequisite stack to be associated to one or more main stacks
* AEM Full-Set architecture requires one prerequisites stack to be associated to one main stack

### Exports stacks

For a stack that contains AWS resources which the user doesn't have permission to provision, the stack would be referred to as an exports stack (`*-exports`). You should provision the AWS resources separate from AEM AWS Stack Builder, and then [https://github.com/shinesolutions/aem-aws-stack-builder/blob/master/docs/configuration.md](configure) those resources to be referenced by the exports.

### Stack structure diagram for permission type b

<img width="800" alt="AEM Full-Set Stacks Structure Diagram For Permission Type b" src="https://raw.githubusercontent.com/shinesolutions/aem-aws-stack-builder/master/docs/stacks-structure-permission-type-b.png"/>

### Stack structure diagram for permission type c

<img width="800" alt="AEM Full-Set Stacks Structure Diagram For Permission Type c" src="https://raw.githubusercontent.com/shinesolutions/aem-aws-stack-builder/master/docs/stacks-structure-permission-type-c.png"/>

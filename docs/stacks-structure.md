Stacks Structure
----------------

AEM AWS Stack Builder heavily utilises [CloudFormation stacks](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacks.html) to provide structure to the AWS resources defined within the supported AEM architectures.

The diagrams below describe the relationship between the stacks, which differ between architectures and permission types.

* Light yellow box represents a [nested stack](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-nested-stacks.html)
* Light orange box represents a parent/root stack
* Arrow represents association between the two stacks, indicating that the stack on the left exports some values which are consumed by the stack on the right

Each AEM architecture has a prerequisite stack and a main stack. The prerequisites stacks are designed to contain AWS resources that are slow(er) to provision. The main stacks are designed to contain AWS resources that are fast(er) to provision.

* AEM Consolidated architecture allows one prerequisite stack to be associated to one or more main stacks
* AEM Full-Set architecture requires one prerequisites stack to be associated to one main stack

For a stack that contains AWS resources which the user doesn't have permission to provision, the stack would be an exports stack (`*-exports`). You should provision those resources separate to AEM AWS Stack Builder, and then configure those resources to be referenced by the exports stack.

### Permission Type b

<img width="800" alt="AEM Full-Set Stacks Structure For Permission Type b Diagram" src="https://raw.githubusercontent.com/shinesolutions/aem-aws-stack-builder/master/docs/stacks-structure-permission-type-b.png"/>

### Permission Type c

<img width="800" alt="AEM Full-Set Stacks Structure For Permission Type c Diagram" src="https://raw.githubusercontent.com/shinesolutions/aem-aws-stack-builder/master/docs/stacks-structure-permission-type-c.png"/>

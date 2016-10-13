While Qubole is a SaaS offering that runs in the cloud. Since Qubole runs a Hadoop cluster within the customers own environment the customer must provision their cloud account before they can begin. In the case of AWS the customer must have the following in place.

* IAM Policy to allow a Qubole instance to access the customer's data in S3. 
* IAM Policy to allow Qubole to orchestrate the creation of of EC2 resources in the customer's account.
* A IAM User or Role attached to the above policies.
* A VPC ( EC2 Classic is no longer an option for new AWS Accounts)
* At least one public subnet and preferably at least one private subnet.
* Routing Rules
* Internet Gateway for inbound internet access
* NAT Gateway for outbound internet access
* Bastion Host to allow ssh tunnel access from the Qubole SaaS platform to any instances in the private subnet.
* RDS if customer desires an in account meta store.


## Terraform 
As thre requirements for creating cloud resrources have become more complex tools for managing these resoruces as code have emerged. [Terrraform](https://www.terraform.io/) is one such tool.  Terraform allows infrastructure to be created, managed and deployed in a repeatable manner.

### Terraform for AWS

The Qubole Customer Success team has now provided sample scripts to create your AWS environment. The [scripts](https://github.com/qubole/customer-success/tree/master/terraform/aws) can be used to setup a completely new VPC for Qubole complete with all
required components.  They assume that the customer has nothing but can be modified based on a particular need.

The following components are included in the scripts.

* IAM Policy for S3 Access 
* IAM Policy for Compute Access
* IAM Role for Cross Account Access 
* IAM Users for Qubole Access **
* VPC
* Subnets
* Routing Rules
* Internet Gateway
* NAT Gateway
* Bastion Host
* RDS **

** By default an these resources are not created by default but can be enabled by modifying ```modules.tf``` to include the desired modules.

### Usage
The terraform utility can be downloaded from Hasicorp [here](https://www.terraform.io/downloads.html) 

#### Get External Modules
This command needs to be run in order to cache the remote modules into the .terraform directory and needs to be run only once unless the modules in the subdirectories are updated.

```
terraform get -update=true
```

#### Create Environment
```
terraform apply
```
#### Destroy Environment
```
terraform destroy
```
#### Plan Environment changes
```
terraform plan
```
#### Show Environment details
```
terraform show
```

### Credentials
By default the Terraform AWS provider will use the credentials located in 
```~/.aws/credentials```   If you have the AWS cli installed these can  easily be set using the ```aws configure``` command. In order to create the AWS VPC the initial account used will require a much higher level of access but the users or role created for Qubole will have the minimum required access as described in the Qubole documentation.  

ENV variables can also be hard coded into the aws.tf file or passed in via the vars file / environment.

```
aws_access_key
aws_secret_key
```

If you need to create resources in another region besides us-east-1 you may modify the variable
```
aws_region
```

### Variables

Variables can be passed in the file ```vars.tfvars``` a sample version is provided.  

```
terraform apply -var-file=vars.tfvars
```
Variables can also be passed via environment or via the command line. The key of the environment variable must be TF_VAR_name and the value is the value of the variable.

```
export TF_VAR_defaultBucket="<bucketname>"
terraform apply
```
further details can be found [here](https://www.terraform.io/docs/configuration/variables.html)

When performing updates make sure to use the same input variables to prevent needlessly destroying and recreating resources that depend on those variables.

### Destroying environment

The entire environment can be destroyed with the following command

```
terraform destroy
```
### Modules
The scripts provided are modularized to an extent.  As of this writing it is possible to run the following commands independenly by execuring Terraform within the appropriate subdirectory.  In addition they may be included in your own terraform directory by referencing them by url.

#### Bastion
```
bastion/bastion.tf
```
|    Inputs    | outputs|
|-------------|:------:|
| bastionInstanceType | bastion_address |
| bastionIncomingCidr | aws_ami |
| qubole-public-a ||
| qubole-vpc |  |
 
#### RDS
```
rds/rds.tf
```
|    Inputs    | outputs|
|-------------|:------:|
| qubole-vpc-id |  |
| qubole-private-a-id |  |
| qubole-private-b-id ||
| password |  |

#### Cross Account Role
```
role/iam.tf
```
|    Inputs    | outputs|
|-------------|:------:|
| accountId | qdsrole |
| computepolicy_arn |  |
| s3policy_arn | |
| externalId ||
| quboleAccountId |  |

#### IAM User
```
user/iam.tf
```
|    Inputs    | outputs|
|-------------|:------:|
| s3policy_arn | compute_iam_access_key |
| computepolicy_arn | compute_iam_secret_key |
| externalId | storage_iam_access_key |
| quboleAccountId | storage_iam_secret_key |

#### S3 Default Location
```
s3defloc/s3.tf
```
|    Inputs    | outputs|
|-------------|:------:|
| s3defloc | s3defloc |


### Module Inport Example
The following example imports the bastion module into an existing Terraform.

```javacript
module "bastion" {
  source  = https://github.com/qubole/customer-success/tree/master/terraform/aws/bastion"
  bastionInstanceType = "${var.bastionInstanceType}"
  bastionIncomingCidr = "${var.bastionIncomingCidr}"
  qubole-public-a = "${var.qubole-public-subnet}"
  qubole-vpc = "${var.qubole-vpc_id}"
}
```


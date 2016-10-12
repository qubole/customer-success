## Terraform for AWS

The scripts in this directory can be used to setup a completely new VPC for Qubole complete with all
required security groups. 

* IAM Policy for S3 Access 
* IAM Policy for Compute Access
* IAM Role for Cross Account Access !
* VPC
* Subnets
* Routing Rules
* Internet Gateway
* NAT Gateway
* Bastion Host
* RDS !

! By default an RDS is not created.  If you need to enbable these uncomment the appropriate section in the modules.tf file.

### Usage
The terraform utility can be downloaded from [here](https://www.terraform.io/downloads.html) 

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

### Modules 
Before running terraform for the first time you will need to get the modules. Modules can be remote and are cached in the .terraform directory
```
terraform get -update=true
```


### Credentials
By default the Terraform AWS provider will use the credentials located in 
```~/.aws/credentials```  This can easily be set using the ```aws configure``` command. In order to create the AWS VPC the initial account used will require a much higher level of access but the users created for Qubole will have the minimum required access as described in the Qubole documentation.  

ENV variables can also be hard coded into the aws.tf file or passed in via the vars file / environment.

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "us-east-1"
}



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

Also, see ```qubole.tf``` for other variables where the default may be overriden either through the tfvars file or the environment.

### Destroying environment

The entire environment can be destroyed with the following command

```
terraform destroy
```



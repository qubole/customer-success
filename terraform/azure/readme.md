While Qubole is a SaaS offering that runs in the cloud. Since Qubole runs a Hadoop cluster within the customers own environment the customer must provision their cloud account before they can begin. In the case of Azure the customer must have the following in place.

* A Resource Group
* A Virtual Network 
* At least one subnet 


## Terraform 
See AWS Readme for primer on terraform usage.


### Credentials
The Terraform Azure provider will use the credentials located in environment variables.

```
  export ARM_SUBSCRIPTION_ID=
  export ARM_CLIENT_ID=
  export ARM_CLIENT_SECRET=
  export ARM_TENANT_ID=

```

If you need to create resources in another region besides US West you may modify the variable
```
TF_VAR_azureRegion
```

### Variables

Variables can be passed in the file ```vars.tfvars``` a sample version is provided.  

```
terraform apply -var-file=vars.tfvars
```
Variables can also be passed via environment or via the command line. The key of the environment variable must be TF_VAR_name and the value is the value of the variable.

```
export TF_VAR_azureRegion="US East"
terraform apply
```
further details can be found [here](https://www.terraform.io/docs/configuration/variables.html)

When performing updates make sure to use the same input variables to prevent needlessly destroying and recreating resources that depend on those variables.



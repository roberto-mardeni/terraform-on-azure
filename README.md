# terraform-on-azure

Demonstrates using Terraform on Azure

## Prerequisites

Use the included setup.sh script to create all the prerequisites for this sample, you can run it in the [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview).

## Usage

Use the service principal details to log into Azure, `az login --service-principal -u <service_principal_name> -p "<service_principal_password>" --tenant "<service_principal_tenant>"`

Replace the **access_key** placeholder in the **main.tf** file with the output from the **setup.sh** script

Let's now run the terraform commands:

```console
terraform init
terraform plan -var-file="local.tfvars" -var 'environment=dev' -out=plan
terraform apply plan
terraform destroy -var-file="local.tfvars" -var 'environment=dev'
```

This sample showcases the following Terraform concepts:

- Azure Blob Storage for [state management](https://www.terraform.io/docs/backends/types/azurerm.html)
- [Input Variables](https://www.terraform.io/docs/configuration/variables.html) via automatic load, file provided and cli provided
- Usage of the [join](https://www.terraform.io/docs/configuration/functions/join.html) built-in function
- Usage of the [Azure Provider](https://www.terraform.io/docs/providers/azurerm/index.html)
- Usage of public module [Terraform Azure RM Module for Network](https://registry.terraform.io/modules/Azure/network/azurerm/3.1.1)
- Custom [database module](https://www.terraform.io/docs/modules/index.html) using existing module [Terraform Azure RM Module for Database](https://registry.terraform.io/modules/Azure/database/azurerm/1.1.0)

## References

This sample was built using the following references:

- https://docs.microsoft.com/en-us/azure/developer/terraform/getting-started-cloud-shell
- https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage
- https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples
- https://www.terraform.io/docs/index.html

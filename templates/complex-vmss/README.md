# Complex Virtual Machine Scale Sets with Terraform

This sample demonstrates how to deploy 2 Linux [VMSS](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview) using Terraform, include is a [cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html) script that will install NGinx with default setup to demonstrate serving HTTP requests

## Prerequisites

- Azure Storage Account to use for Terraform State
- Azure Active Directory Service Principal with Contributor access

## Usage

Add/replace backend properties in the **main.tf** file with the proper values for the desired Azure Storage Account
Add the values for the variables in the **variables.tf** file for the AAD Service Principal

```console
terraform init -reconfigure
terraform plan -out=plan
terraform apply plan
terraform destroy
```

## Testing

The **runtest.sh** shell script will test executing in parallel requests to validate that the VMSS is up and running with nginx, to run it include the random ID generated for the corresponding VMSS like below:

```console
./runtest.sh abcdef
```

## References 

- https://docs.microsoft.com/en-us/azure/developer/terraform/create-vm-cluster-with-infrastructure
- https://docs.microsoft.com/en-us/azure/developer/terraform/create-vm-cluster-module
- https://docs.microsoft.com/en-us/azure/developer/terraform/create-vm-scaleset-network-disks-hcl
- https://www.terraform.io/docs/providers/azurerm/r/linux_virtual_machine_scale_set.html
- https://www.terraform.io/docs/providers/azurerm/r/lb.html
- https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-automate-vm-deployment

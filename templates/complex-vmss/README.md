# Complex Virtual Machine Scale Sets with Terraform

This sample demonstrates how to deploy 2 groups of Linux [VMSS](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview) using Terraform using Availability Zones for maximum resiliency, include is a [cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html) script that will install NGinx with default setup to demonstrate serving HTTP requests.

Each group of VMSS will be deployed in a different availability zone available in the East US region, resulting in 6 VMSS, each with 2 VM instances.

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
- https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-automate-vm-deployment
- https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-standard-availability-zones
- https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview
- https://www.terraform.io/docs/providers/azurerm/r/linux_virtual_machine_scale_set.html
- https://www.terraform.io/docs/providers/azurerm/r/public_ip.html
- https://www.terraform.io/docs/providers/azurerm/r/lb.html
- https://www.terraform.io/docs/providers/azurerm/r/user_assigned_identity.html
- https://www.terraform.io/docs/providers/azurerm/r/virtual_machine_scale_set_extension.html
- https://www.terraform.io/docs/providers/azurerm/r/network_security_group.html
- https://www.terraform.io/docs/providers/azurerm/r/subnet_network_security_group_association.html

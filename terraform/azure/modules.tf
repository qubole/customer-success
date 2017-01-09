#####
#
# Module to create a storage account.  This is where Qubole will read/write data from
#
module "create_storage" {
  source = "./storage"
  storageAccountName = "${var.storageAccountName}"
  resourceGroup = "${azurerm_resource_group.production.name}"
  azureRegion = "${var.azureRegion}"
}

variable "storageAccountName" {

}

#####
#
# Module to create a virtual network where qubole will launch instances from
#
module "create_network" {
	source = "./network"
    resourceGroup = "${azurerm_resource_group.production.name}"
	prefix-tag = "${var.prefix-tag}"
	azureRegion = "${var.azureRegion}"
}
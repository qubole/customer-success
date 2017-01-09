provider "azurerm" {

}

variable "resourceGroupName" {
  description = "Resource Group Name"
}

variable "azureRegion" {
  description = "Azure Region"
  default = "West US"
}

# Create a resource group
resource "azurerm_resource_group" "production" {
    name     = "${var.resourceGroupName}"
    location = "${var.azureRegion}"
}

variable "prefix-tag" {
  description = "Qubole Tag to add to Resources"
}



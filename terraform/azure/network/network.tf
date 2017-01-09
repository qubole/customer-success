variable resourceGroup {
  
}


variable "prefix-tag" {
  
}

variable "azureRegion" {
  
}



# Create a virtual network in the web_servers resource group
resource "azurerm_virtual_network" "network" {
  name                = "quboleNetwork"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.azureRegion}"
  resource_group_name = "${var.resourceGroup}"

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
    security_group = "${azurerm_network_security_group.quboleSecurityGroup.id}"
  }

}

resource "azurerm_network_security_group" "quboleSecurityGroup" {
    name = "quboleSecurityGroup"
    location =  "${var.azureRegion}"
    resource_group_name = "${var.resourceGroup}"

    security_rule {
        name = "qubuleAllowSSH"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "22"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }

    tags {
         Prefix = "${var.prefix-tag}"
    }
}
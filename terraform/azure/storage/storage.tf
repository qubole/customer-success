variable storageAccountName {
	
}

variable resourceGroup {
	
}

variable azureRegion{
	
}

resource "azurerm_storage_account" "testsa" {
    name = "${var.storageAccountName}"
    resource_group_name = "${var.resourceGroup}"
    location = "${var.azureRegion}"
    account_type = "Standard_GRS"

}
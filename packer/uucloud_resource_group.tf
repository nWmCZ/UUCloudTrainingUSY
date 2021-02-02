provider "azurerm" {
  subscription_id = "required_value" // https://portal.azure.com/ -> Subscriptions
  tenant_id       = "required_value" // https://portal.azure.com/ -> Azure Active Directory -> App registrations -> Create Service Principal
  client_id       = "required_value" // https://portal.azure.com/ -> Azure Active Directory -> App registrations -> Created Service Principal
  client_secret   = "required_value"   // // https://portal.azure.com/ -> Azure Active Directory -> App registrations -> Created Service Principal -> Certificates & secrets
  // https://portal.azure.com/ -> Subscriptions -> AIM -> Add -> Contributor -> Service Principal -> Created Service Principal
  features {}
}

resource "azurerm_resource_group" "resourceGroup" {
  name     = "uucloud"
  location = "westeurope"

  tags = {
    environment = "uucloud"
  }
}

provider "azurerm" {
  subscription_id = "required_value" // https://portal.azure.com/ -> Subscriptions
  tenant_id       = "required_value" // https://portal.azure.com/ -> Azure Active Directory -> App registrations -> Create Service Principal
  client_id       = "required_value" // https://portal.azure.com/ -> Azure Active Directory -> App registrations -> Created Service Principal
  client_secret   = "required_value"   // // https://portal.azure.com/ -> Azure Active Directory -> App registrations -> Created Service Principal -> Certificates & secrets
  // https://portal.azure.com/ -> Subscriptions -> AIM -> Add -> Contributor -> Service Principal -> Created Service Principal
  features {}
}

locals {
  imageIdReference = "/subscriptions/syshost/resourceGroups/uucloud/providers/Microsoft.Compute/images/centos7_with_docker"
  sshKey           = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDB+ZJJIfGYpYOy/1fJV4gUbrhxwnUyIawojlSRdquLz4+Evc7B5Yu8zkLgTlVHungaAvSUVnaf8Y4oDDnt0bG3xMALy+wblAbLYhZowhAN0z5Z9pXwlUJNp/p54EAnQjauq7epM4E0ggl71cFhVdJbBAdVavATJuosLoGj9eJPgDGxfECfder8CPT+G/lsF9JuI5AjnyG4Tm61yBw/h2sf4wIAEBZ92W8FK1tft8umEuaVil2JsRKK20O1C9OwOCWJUoBkzVbEH+8dD40kD5wF1CXGw0VSXD4gkCuQ/Vi/AtJyN/g8qZrVnoG8qnRBxy/Kl5ZGT11P49O4Ro7eDi11 root@syshost"
  vm1              = "syshost"
  vm2              = "swarmmanager"
  vm3              = "dockerhost1"
  vm4              = "dockerhost2"
  vm5              = "dockerhost3"
  vm6              = "dockerhost4"
  vm1ip            = "10.0.1.101"
  vm2ip            = "10.0.1.110"
  vm3ip            = "10.0.1.111"
  vm4ip            = "10.0.1.112"
  vm5ip            = "10.0.1.113"
  vm6ip            = "10.0.1.114"

  vmSizeSmall      = "Standard_B1MS"
  vmSizeMedium     = "Standard_B2S"
  vmSizeLarge      = "Standard_B4MS"
  vmSizeExtraLarge = "Standard_B8MS"
}

output "syshost_public_ip" {
  value = azurerm_public_ip.vm1-publicip.ip_address
}

output "syshost_fqdn" {
  value = azurerm_public_ip.vm1-publicip.fqdn
}

//resource "azurerm_resource_group" "resourceGroup" {
//  name     = "uucloud"
//  location = "westeurope"
//
//  tags = {
//    environment = "uucloud"
//  }
//}

resource "azurerm_network_security_group" "networkSecurityGroup" {
  name                = "networkSecurityGroup"
  location            = "westeurope"
  resource_group_name = "uucloud"

  security_rule {
    name               = "allow-ssh"
    priority           = 100
    direction          = "Inbound"
    access             = "Allow"
    protocol           = "TCP"
    source_port_range  = "*"
    source_port_ranges = []
    destination_port_ranges = [
      "22"
    ]
    source_address_prefix        = "*"
    source_address_prefixes      = []
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }

  security_rule {
    name               = "allow-8080"
    priority           = 110
    direction          = "Inbound"
    access             = "Allow"
    protocol           = "TCP"
    source_port_range  = "*"
    source_port_ranges = []
    destination_port_ranges = [
      "8080"
    ]
    source_address_prefix        = "*"
    source_address_prefixes      = []
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }

  security_rule {
    name               = "allow-8081"
    priority           = 120
    direction          = "Inbound"
    access             = "Allow"
    protocol           = "TCP"
    source_port_range  = "*"
    source_port_ranges = []
    destination_port_ranges = [
      "8081"
    ]
    source_address_prefix        = "*"
    source_address_prefixes      = []
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }

  security_rule {
    name               = "allow-5000"
    priority           = 130
    direction          = "Inbound"
    access             = "Allow"
    protocol           = "TCP"
    source_port_range  = "*"
    source_port_ranges = []
    destination_port_ranges = [
      "5000"
    ]
    source_address_prefix        = "*"
    source_address_prefixes      = []
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }

  security_rule {
    name               = "allow-9000"
    priority           = 140
    direction          = "Inbound"
    access             = "Allow"
    protocol           = "TCP"
    source_port_range  = "*"
    source_port_ranges = []
    destination_port_ranges = [
      "9000"
    ]
    source_address_prefix        = "*"
    source_address_prefixes      = []
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }

  security_rule {
    name               = "allow-27017"
    priority           = 150
    direction          = "Inbound"
    access             = "Allow"
    protocol           = "TCP"
    source_port_range  = "*"
    source_port_ranges = []
    destination_port_ranges = [
      "27017"
    ]
    source_address_prefix        = "*"
    source_address_prefixes      = []
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }

  security_rule {
    name               = "allow-80"
    priority           = 160
    direction          = "Inbound"
    access             = "Allow"
    protocol           = "TCP"
    source_port_range  = "*"
    source_port_ranges = []
    destination_port_ranges = [
      "80"
    ]
    source_address_prefix        = "*"
    source_address_prefixes      = []
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }

  security_rule {
    name               = "allow-81"
    priority           = 170
    direction          = "Inbound"
    access             = "Allow"
    protocol           = "TCP"
    source_port_range  = "*"
    source_port_ranges = []
    destination_port_ranges = [
      "81"
    ]
    source_address_prefix        = "*"
    source_address_prefixes      = []
    destination_address_prefix   = "*"
    destination_address_prefixes = []
  }
}

resource "azurerm_virtual_network" "virtualNetwork1" {
  name                = "virtualNetwork1"
  location            = "westeurope"
  resource_group_name = "uucloud"
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = "uucloud"
  virtual_network_name = azurerm_virtual_network.virtualNetwork1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.networkSecurityGroup.id
}

resource "azurerm_public_ip" "vm1-publicip" {
  name                = "${local.vm1}-publicip"
  resource_group_name = "uucloud"
  location            = "westeurope"
  allocation_method   = "Static"
  domain_name_label   = "uucloud"

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_network_interface" "vm1-nic" {
  name                = "${local.vm1}-nic"
  location            = "westeurope"
  resource_group_name = "uucloud"

  ip_configuration {
    name                          = "${local.vm1}-ip-configuration"
    private_ip_address_allocation = "Static"
    private_ip_address            = local.vm1ip
    public_ip_address_id          = azurerm_public_ip.vm1-publicip.id
    subnet_id                     = azurerm_subnet.subnet1.id
  }

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_virtual_machine" "vm1" {
  name                  = local.vm1
  location              = "westeurope"
  resource_group_name   = "uucloud"
  network_interface_ids = [azurerm_network_interface.vm1-nic.id]
  vm_size               = local.vmSizeMedium

  storage_os_disk {
    name              = "${local.vm1}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

//  storage_image_reference {
//    publisher = "OpenLogic"
//    offer     = "CentOS"
//    sku       = "7_9"
//    version   = "7.9.2020111900"
//  }
  storage_image_reference {
    id = local.imageIdReference
  }

  os_profile {
    computer_name  = local.vm1
    admin_username = "uucloud"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/uucloud/.ssh/authorized_keys"
      key_data = local.sshKey
    }
  }

  tags = {
    environment = "uucloud"
  }
}

//resource "azurerm_network_interface" "vm2-nic" {
//  name                = "${local.vm2}-nic"
//  location            = "westeurope"
//  resource_group_name = "uucloud"
//
//  ip_configuration {
//    name                          = "${local.vm2}-ip-configuration"
//    private_ip_address_allocation = "Static"
//    private_ip_address            = local.vm2ip
//    subnet_id                     = azurerm_subnet.subnet1.id
//  }
//
//  tags = {
//    environment = "uucloud"
//  }
//}

//resource "azurerm_virtual_machine" "vm2" {
//  name                  = local.vm2
//  location              = "westeurope"
//  resource_group_name   = "uucloud"
//  network_interface_ids = [azurerm_network_interface.vm2-nic.id]
//  vm_size               = local.vmSizeSmall
//
//  storage_os_disk {
//    name              = "${local.vm2}-os"
//    caching           = "ReadWrite"
//    create_option     = "FromImage"
//    managed_disk_type = "Standard_LRS"
//  }
//
//  storage_image_reference {
//    id = local.imageIdReference
//  }
//  }
//
//  os_profile {
//    computer_name  = local.vm2
//    admin_username = "uucloud"
//  }
//
//  os_profile_linux_config {
//    disable_password_authentication = true
//    ssh_keys {
//      path     = "/home/uucloud/.ssh/authorized_keys"
//      key_data = local.sshKey
//    }
//  }
//
//  tags = {
//    environment = "uucloud"
//  }
//}

//resource "azurerm_network_interface" "vm3-nic" {
//  name                = "${local.vm3}-nic"
//  location            = "westeurope"
//  resource_group_name = "uucloud"
//
//  ip_configuration {
//    name                          = "${local.vm3}-ip-configuration"
//    private_ip_address_allocation = "Static"
//    private_ip_address            = local.vm3ip
//    subnet_id                     = azurerm_subnet.subnet1.id
//  }
//
//  tags = {
//    environment = "uucloud"
//  }
//}

//resource "azurerm_virtual_machine" "vm3" {
//  name                  = local.vm3
//  location              = "westeurope"
//  resource_group_name   = "uucloud"
//  network_interface_ids = [azurerm_network_interface.vm3-nic.id]
//  vm_size               = local.vmSizeMedium
//
//  storage_os_disk {
//    name              = "${local.vm3}-os"
//    caching           = "ReadWrite"
//    create_option     = "FromImage"
//    managed_disk_type = "Standard_LRS"
//  }
//
//  storage_image_reference {
//    id = local.imageIdReference
//  }
//
//  os_profile {
//    computer_name  = local.vm3
//    admin_username = "uucloud"
//  }
//
//  os_profile_linux_config {
//    disable_password_authentication = true
//    ssh_keys {
//      path     = "/home/uucloud/.ssh/authorized_keys"
//      key_data = local.sshKey
//    }
//  }
//
//  tags = {
//    environment = "uucloud"
//  }
//}

//resource "azurerm_network_interface" "vm4-nic" {
//  name                = "${local.vm4}-nic"
//  location            = "westeurope"
//  resource_group_name = "uucloud"
//
//  ip_configuration {
//    name                          = "${local.vm4}-ip-configuration"
//    private_ip_address_allocation = "Static"
//    private_ip_address            = local.vm4ip
//    subnet_id                     = azurerm_subnet.subnet1.id
//  }
//
//  tags = {
//    environment = "uucloud"
//  }
//}
//
//resource "azurerm_virtual_machine" "vm4" {
//  name                  = local.vm4
//  location              = "westeurope"
//  resource_group_name   = "uucloud"
//  network_interface_ids = [azurerm_network_interface.vm4-nic.id]
//  vm_size               = local.vmSizeSmall
//
//  storage_os_disk {
//    name              = "${local.vm4}-os"
//    caching           = "ReadWrite"
//    create_option     = "FromImage"
//    managed_disk_type = "Standard_LRS"
//  }
//
//  storage_image_reference {
//    id = local.imageIdReference
//  }
//
//  os_profile {
//    computer_name  = local.vm4
//    admin_username = "uucloud"
//  }
//
//  os_profile_linux_config {
//    disable_password_authentication = true
//    ssh_keys {
//      path     = "/home/uucloud/.ssh/authorized_keys"
//      key_data = local.sshKey
//    }
//  }
//
//  tags = {
//    environment = "uucloud"
//  }
//}

resource "azurerm_network_interface" "vm5-nic" {
  name                = "${local.vm5}-nic"
  location            = "westeurope"
  resource_group_name = "uucloud"

  ip_configuration {
    name                          = "${local.vm5}-ip-configuration"
    private_ip_address_allocation = "Static"
    private_ip_address            = local.vm5ip
    subnet_id                     = azurerm_subnet.subnet1.id
  }

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_virtual_machine" "vm5" {
  name                  = local.vm5
  location              = "westeurope"
  resource_group_name   = "uucloud"
  network_interface_ids = [azurerm_network_interface.vm5-nic.id]
  vm_size               = local.vmSizeSmall

  storage_os_disk {
    name              = "${local.vm5}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    id = local.imageIdReference
  }

  os_profile {
    computer_name  = local.vm5
    admin_username = "uucloud"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/uucloud/.ssh/authorized_keys"
      key_data = local.sshKey
    }
  }

  tags = {
    environment = "uucloud"
  }
}

//resource "azurerm_network_interface" "vm6-nic" {
//  name                = "${local.vm6}-nic"
//  location            = "westeurope"
//  resource_group_name = "uucloud"
//
//  ip_configuration {
//    name                          = "${local.vm6}-ip-configuration"
//    private_ip_address_allocation = "Static"
//    private_ip_address            = local.vm6ip
//    subnet_id                     = azurerm_subnet.subnet1.id
//  }
//
//  tags = {
//    environment = "uucloud"
//  }
//}
//
//resource "azurerm_virtual_machine" "vm6" {
//  name                  = local.vm6
//  location              = "westeurope"
//  resource_group_name   = "uucloud"
//  network_interface_ids = [azurerm_network_interface.vm6-nic.id]
//  vm_size               = local.vmSizeSmall
//
//  storage_os_disk {
//    name              = "${local.vm6}-os"
//    caching           = "ReadWrite"
//    create_option     = "FromImage"
//    managed_disk_type = "Standard_LRS"
//  }
//
//  storage_image_reference {
//    id = local.imageIdReference
//  }
//
//  os_profile {
//    computer_name  = local.vm6
//    admin_username = "uucloud"
//  }
//
//  os_profile_linux_config {
//    disable_password_authentication = true
//    ssh_keys {
//      path     = "/home/uucloud/.ssh/authorized_keys"
//      key_data = local.sshKey
//    }
//  }
//
//  tags = {
//    environment = "uucloud"
//  }
//}

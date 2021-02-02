provider "azurerm" {
  subscription_id = "required_value" // https://portal.azure.com/ -> Subscriptions
  tenant_id       = "required_value" // https://portal.azure.com/ -> Azure Active Directory -> App registrations -> Create Service Principal
  client_id       = "required_value" // https://portal.azure.com/ -> Azure Active Directory -> App registrations -> Created Service Principal
  client_secret   = "required_value" // // https://portal.azure.com/ -> Azure Active Directory -> App registrations -> Created Service Principal -> Certificates & secrets
  // https://portal.azure.com/ -> Subscriptions -> AIM -> Add -> Contributor -> Service Principal -> Created Service Principal
  features {}
}

locals {
  sshKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDB+ZJJIfGYpYOy/1fJV4gUbrhxwnUyIawojlSRdquLz4+Evc7B5Yu8zkLgTlVHungaAvSUVnaf8Y4oDDnt0bG3xMALy+wblAbLYhZowhAN0z5Z9pXwlUJNp/p54EAnQjauq7epM4E0ggl71cFhVdJbBAdVavATJuosLoGj9eJPgDGxfECfder8CPT+G/lsF9JuI5AjnyG4Tm61yBw/h2sf4wIAEBZ92W8FK1tft8umEuaVil2JsRKK20O1C9OwOCWJUoBkzVbEH+8dD40kD5wF1CXGw0VSXD4gkCuQ/Vi/AtJyN/g8qZrVnoG8qnRBxy/Kl5ZGT11P49O4Ro7eDi11 root@syshost"
  vm1    = "syshost"
  vm2    = "registry"
  vm3    = "graylog"
  vm4    = "gw"
  vm5    = "swarmmanager"
  vm6    = "dockerhost1"
  vm7    = "dockerhost2"
  vm8    = "dockerhost3"
  vm9    = "dockerhost4"
  vm10   = "dockerhost5"
  vm1ip  = "10.0.1.101"
  vm2ip  = "10.0.1.102"
  vm3ip  = "10.0.1.103"
  vm4ip  = "10.0.1.104"
  vm5ip  = "10.0.1.105"
  vm6ip  = "10.0.1.106"
  vm7ip  = "10.0.1.107"
  vm8ip  = "10.0.1.108"
  vm9ip  = "10.0.1.109"
  vm10ip = "10.0.1.110"

  vmSizeSmall  = "Standard_B1MS"
  vmSizeMedium = "Standard_B2S"
}

resource "azurerm_resource_group" "resourceGroup" {
  name     = "uucloud"
  location = "westeurope"

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_network_security_group" "networkSecurityGroup" {
  name                = "networkSecurityGroup"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

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
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.resourceGroup.name
  virtual_network_name = azurerm_virtual_network.virtualNetwork1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "vm1-publicip" {
  name                = "${local.vm1}-publicip"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  allocation_method   = "Static"

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_network_interface" "vm1-nic" {
  name                = "${local.vm1}-nic"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

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
  location              = azurerm_resource_group.resourceGroup.location
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  network_interface_ids = [azurerm_network_interface.vm1-nic.id]
  vm_size               = local.vmSizeMedium

  storage_os_disk {
    name              = "${local.vm1}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "7.9.2020111900"
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

resource "azurerm_public_ip" "vm2-publicip" {
  name                = "${local.vm2}-publicip"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_network_interface" "vm2-nic" {
  name                = "${local.vm2}-nic"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    name                          = "${local.vm2}-ip-configuration"
    private_ip_address_allocation = "Static"
    private_ip_address            = local.vm2ip
    public_ip_address_id          = azurerm_public_ip.vm2-publicip.id
    subnet_id = azurerm_subnet.subnet1.id
  }

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_virtual_machine" "vm2" {
  name                  = local.vm2
  location              = azurerm_resource_group.resourceGroup.location
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  network_interface_ids = [azurerm_network_interface.vm2-nic.id]
  vm_size               = local.vmSizeSmall

  storage_os_disk {
    name              = "${local.vm2}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "7.9.2020111900"
  }

  os_profile {
    computer_name  = local.vm2
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

resource "azurerm_public_ip" "vm3-publicip" {
  name = "${local.vm3}-publicip"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location = azurerm_resource_group.resourceGroup.location
  allocation_method = "Static"

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_network_interface" "vm3-nic" {
  name                = "${local.vm3}-nic"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    name                          = "${local.vm3}-ip-configuration"
    private_ip_address_allocation = "Static"
    private_ip_address            = local.vm3ip
    public_ip_address_id            = azurerm_public_ip.vm3-publicip.id
    subnet_id                     = azurerm_subnet.subnet1.id
  }

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_virtual_machine" "vm3" {
  name                  = local.vm3
  location              = azurerm_resource_group.resourceGroup.location
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  network_interface_ids = [azurerm_network_interface.vm3-nic.id]
  vm_size               = local.vmSizeMedium

  storage_os_disk {
    name              = "${local.vm3}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "7.9.2020111900"
  }

  os_profile {
    computer_name  = local.vm3
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

resource "azurerm_public_ip" "vm4-publicip" {
  name                = "${local.vm4}-publicip"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  allocation_method   = "Static"
  domain_name_label   = "uucloud"

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_network_interface" "vm4-nic" {
  name                = "${local.vm4}-nic"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    name                          = "${local.vm4}-ip-configuration"
    private_ip_address_allocation = "Static"
    private_ip_address            = local.vm4ip
    public_ip_address_id          = azurerm_public_ip.vm4-publicip.id
    subnet_id                     = azurerm_subnet.subnet1.id
  }

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_virtual_machine" "vm4" {
  name                  = local.vm4
  location              = azurerm_resource_group.resourceGroup.location
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  network_interface_ids = [azurerm_network_interface.vm4-nic.id]
  vm_size               = local.vmSizeSmall

  storage_os_disk {
    name              = "${local.vm4}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "7.9.2020111900"
  }

  os_profile {
    computer_name  = local.vm4
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

resource "azurerm_public_ip" "vm5-publicip" {
  name                = "${local.vm5}-publicip"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_network_interface" "vm5-nic" {
  name                = "${local.vm5}-nic"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    name                          = "${local.vm5}-ip-configuration"
    private_ip_address_allocation = "Static"
    private_ip_address            = local.vm5ip
    public_ip_address_id          = azurerm_public_ip.vm5-publicip.id
    subnet_id                     = azurerm_subnet.subnet1.id
  }

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_virtual_machine" "vm5" {
  name                  = local.vm5
  location              = azurerm_resource_group.resourceGroup.location
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  network_interface_ids = [azurerm_network_interface.vm5-nic.id]
  vm_size               = local.vmSizeSmall

  storage_os_disk {
    name              = "${local.vm5}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "7.9.2020111900"
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

resource "azurerm_public_ip" "vm6-publicip" {
  name                = "${local.vm6}-publicip"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_network_interface" "vm6-nic" {
  name                = "${local.vm6}-nic"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    name                          = "${local.vm6}-ip-configuration"
    private_ip_address_allocation = "Static"
    private_ip_address            = local.vm6ip
    public_ip_address_id          = azurerm_public_ip.vm6-publicip.id
    subnet_id                     = azurerm_subnet.subnet1.id
  }

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_virtual_machine" "vm6" {
  name                  = local.vm6
  location              = azurerm_resource_group.resourceGroup.location
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  network_interface_ids = [azurerm_network_interface.vm6-nic.id]
  vm_size               = local.vmSizeSmall

  storage_os_disk {
    name              = "${local.vm6}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "7.9.2020111900"
  }

  os_profile {
    computer_name  = local.vm6
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

resource "azurerm_public_ip" "vm7-publicip" {
  name                = "${local.vm7}-publicip"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_network_interface" "vm7-nic" {
  name                = "${local.vm7}-nic"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    name                          = "${local.vm7}-ip-configuration"
    private_ip_address_allocation = "Static"
    private_ip_address            = local.vm7ip
    public_ip_address_id          = azurerm_public_ip.vm7-publicip.id
    subnet_id                     = azurerm_subnet.subnet1.id
  }

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_virtual_machine" "vm7" {
  name                  = local.vm7
  location              = azurerm_resource_group.resourceGroup.location
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  network_interface_ids = [azurerm_network_interface.vm7-nic.id]
  vm_size               = local.vmSizeSmall

  storage_os_disk {
    name              = "${local.vm7}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "7.9.2020111900"
  }

  os_profile {
    computer_name  = local.vm7
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

resource "azurerm_public_ip" "vm8-publicip" {
  name                = "${local.vm8}-publicip"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_network_interface" "vm8-nic" {
  name                = "${local.vm8}-nic"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    name                          = "${local.vm8}-ip-configuration"
    private_ip_address_allocation = "Static"
    private_ip_address            = local.vm8ip
    public_ip_address_id          = azurerm_public_ip.vm8-publicip.id
    subnet_id = azurerm_subnet.subnet1.id
  }

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_virtual_machine" "vm8" {
  name                  = local.vm8
  location              = azurerm_resource_group.resourceGroup.location
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  network_interface_ids = [azurerm_network_interface.vm8-nic.id]
  vm_size               = local.vmSizeSmall

  storage_os_disk {
    name              = "${local.vm8}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "7.9.2020111900"
  }

  os_profile {
    computer_name  = local.vm8
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

resource "azurerm_public_ip" "vm9-publicip" {
  name                = "${local.vm9}-publicip"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "uucloud"
  }
}


resource "azurerm_network_interface" "vm9-nic" {
  name                = "${local.vm9}-nic"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    name                          = "${local.vm9}-ip-configuration"
    private_ip_address_allocation = "Static"
    private_ip_address            = local.vm9ip
    public_ip_address_id          = azurerm_public_ip.vm9-publicip.id
    subnet_id = azurerm_subnet.subnet1.id
  }

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_virtual_machine" "vm9" {
  name                  = local.vm9
  location              = azurerm_resource_group.resourceGroup.location
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  network_interface_ids = [azurerm_network_interface.vm9-nic.id]
  vm_size               = local.vmSizeSmall

  storage_os_disk {
    name              = "${local.vm9}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "7.9.2020111900"
  }

  os_profile {
    computer_name  = local.vm9
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

resource "azurerm_public_ip" "vm10-publicip" {
  name                = "${local.vm10}-publicip"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_network_interface" "vm10-nic" {
  name                = "${local.vm10}-nic"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    name                          = "${local.vm10}-ip-configuration"
    private_ip_address_allocation = "Static"
    private_ip_address            = local.vm10ip
    public_ip_address_id          = azurerm_public_ip.vm10-publicip.id
    subnet_id                     = azurerm_subnet.subnet1.id
  }

  tags = {
    environment = "uucloud"
  }
}

resource "azurerm_virtual_machine" "vm10" {
  name                  = local.vm10
  location              = azurerm_resource_group.resourceGroup.location
  resource_group_name   = azurerm_resource_group.resourceGroup.name
  network_interface_ids = [azurerm_network_interface.vm10-nic.id]
  vm_size               = local.vmSizeSmall

  storage_os_disk {
    name              = "${local.vm10}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "7.9.2020111900"
  }

  os_profile {
    computer_name  = local.vm10
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
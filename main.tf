resource "azurerm_resource_group" "terraform-labs-rg" {
  name     = "terraform-labs-rg"
  location = var.location
}

resource "azurerm_network_security_group" "terraform-labs-sg" {
  name                = "terraform-labs-sg"
  location            = azurerm_resource_group.terraform-labs-rg.location
  resource_group_name = azurerm_resource_group.terraform-labs-rg.name

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "AllowSSH"
    priority                   = 1000
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_port_range     = "22-22"
    destination_address_prefix = "*"
  }

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "AllowRDP"
    priority                   = 1001
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_port_range     = "3389-3389"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "terraform-labs-vn" {
  name                = "terraform-labs-vn"
  location            = azurerm_resource_group.terraform-labs-rg.location
  resource_group_name = azurerm_resource_group.terraform-labs-rg.name
  address_space       = var.vn_address_space
}

resource "azurerm_subnet" "terraform-labs-subnet" {
  name                                      = "terraform-labs-subnet"
  resource_group_name                       = azurerm_resource_group.terraform-labs-rg.name
  virtual_network_name                      = azurerm_virtual_network.terraform-labs-vn.name
  address_prefixes                          = var.vn_subnet
  private_endpoint_network_policies_enabled = false

  delegation {
    name = "Microsoft.LabServices.labplans"

    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action",]
      name    = "Microsoft.LabServices/labplans"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "terraform-labs-sg-association" {
  subnet_id                 = azurerm_subnet.terraform-labs-subnet.id
  network_security_group_id = azurerm_network_security_group.terraform-labs-sg.id
}

resource "azapi_resource" "symbolicname" {
  type      = "Microsoft.LabServices/labPlans@2022-08-01"
  name      = "terraform-labs-plan"
  location  = var.azure_location
  parent_id = azurerm_resource_group.terraform-labs-rg.id
  tags = {
    tagName1 = "test-tag-1"
    tagName2 = "test-tag-2"
  }
  body = jsonencode({
    properties = {
      allowedRegions = [
        var.azure_location
      ]
      defaultAutoShutdownProfile = {
        disconnectDelay          = "00:15:00"
        idleDelay                = "00:15:00"
        noConnectDelay           = "00:15:00"
        shutdownOnDisconnect     = "Disabled"
        shutdownOnIdle           = "None"
        shutdownWhenNotConnected = "Disabled"
      }
      defaultConnectionProfile = {
        clientRdpAccess = "Public"
        clientSshAccess = "Public"
        webRdpAccess    = "Public"
        webSshAccess    = "Public"
      }
      defaultNetworkProfile = {
        subnetId = azurerm_subnet.terraform-labs-subnet.id
      }
    }
  })
}
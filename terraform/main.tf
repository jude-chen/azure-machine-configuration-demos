resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_resource_group" "demo-rg" {
  location = var.location
  name     = "${var.resource_prefix}-demo-rg"
}

resource "azurerm_virtual_network" "demo-vnet" {
  name                = "${var.resource_prefix}-vnet"
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.demo-rg.location
  resource_group_name = azurerm_resource_group.demo-rg.name
}

resource "azurerm_subnet" "test-subnet" {
  name                 = "test-subnet"
  resource_group_name  = azurerm_resource_group.demo-rg.name
  virtual_network_name = azurerm_virtual_network.demo-vnet.name
  address_prefixes     = ["10.0.0.0/26"]
}

resource "azurerm_network_security_group" "nsg-rdp" { // This is the network security group will allow us to configure RDP access to the VM
  name                = "${var.resource_prefix}-nsg"
  resource_group_name = azurerm_resource_group.demo-rg.name
  location            = azurerm_resource_group.demo-rg.location
  security_rule = [
    {
      name                                       = "RDP"
      description                                = "Allow RDP"
      priority                                   = 1001
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_range                     = "3389"
      source_address_prefix                      = "*"
      destination_address_prefix                 = "*"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_ranges                    = []
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_ranges                         = []
    }
  ]
}

resource "azurerm_subnet_network_security_group_association" "nsg-association" { // This is the association between the subnet and the network security group
  subnet_id                 = azurerm_subnet.test-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg-rdp.id
}

# Storage account and blob container for publishing the configuration packages
resource "azurerm_storage_account" "demo-sa" {
  name                      = "${var.resource_prefix}sa${random_string.suffix.result}"
  resource_group_name       = azurerm_resource_group.demo-rg.name
  location                  = azurerm_resource_group.demo-rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  local_user_enabled        = false
  shared_access_key_enabled = true
}

resource "azurerm_storage_container" "demo-container" {
  name                  = "machine-configurations"
  storage_account_id    = azurerm_storage_account.demo-sa.id
  container_access_type = "private"
}

# User assigned identity for policy assignment
resource "azurerm_user_assigned_identity" "amcidentity" {
  location            = var.location
  name                = "${var.resource_prefix}-${random_string.suffix.result}-identity"
  resource_group_name = azurerm_resource_group.demo-rg.name
}

resource "azurerm_role_assignment" "amci-role-assignment" {
  principal_id         = azurerm_user_assigned_identity.amcidentity.principal_id
  role_definition_name = "Storage Blob Data Reader"
  scope                = azurerm_resource_group.demo-rg.id
}

# Assign the built-in policy for deploying machine configuration prerequisites (system managed identity and GuestConfiguration extension)
resource "azurerm_resource_group_policy_assignment" "prereq-policy-assignments" {
  for_each             = var.policy_definition_ids
  name                 = each.key
  resource_group_id    = azurerm_resource_group.demo-rg.id
  location             = var.location
  policy_definition_id = each.value
  identity {
    type = "SystemAssigned"
  }
}

# Assign the "contributor" role to the policy assignment identity for remediation
resource "azurerm_role_assignment" "prereq-policy-role-assignments" {
  for_each             = var.policy_definition_ids
  principal_id         = azurerm_resource_group_policy_assignment.prereq-policy-assignments[each.key].identity[0].principal_id
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.demo-rg.id
}

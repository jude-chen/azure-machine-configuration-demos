resource "azurerm_public_ip" "vm-pip" {
  name                = "testvm001-pip"
  resource_group_name = azurerm_resource_group.demo-rg.name
  location            = azurerm_resource_group.demo-rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "vm-nic" {
  name                = "testvm001-nic"
  location            = azurerm_resource_group.demo-rg.location
  resource_group_name = azurerm_resource_group.demo-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-pip.id
  }
}

resource "azurerm_windows_virtual_machine" "testvm" { // Note: never hardcode credentials in your code, this is just an example!
  resource_group_name               = azurerm_resource_group.demo-rg.name
  name                              = "testvm001"
  location                          = azurerm_resource_group.demo-rg.location
  size                              = "Standard_B2s_v2"
  admin_username                    = "azureadmin"
  admin_password                    = "Password1234!"
  vm_agent_platform_updates_enabled = true
  network_interface_ids = [
    azurerm_network_interface.vm-nic.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.amcidentity.id,
    ]
  }
  depends_on = [azurerm_resource_group_policy_assignment.machine-config-policy-assignment]
}

# Alternatively, install the extension using the code below instead of using the built-in policy initiative.
# resource "azurerm_virtual_machine_extension" "guestconfiguration-extension" {
#   name                       = "AzurePolicyforWindows"
#   virtual_machine_id         = azurerm_windows_virtual_machine.testvm.id
#   publisher                  = "Microsoft.GuestConfiguration"
#   type                       = "ConfigurationForWindows"
#   type_handler_version       = "1.1"
#   auto_upgrade_minor_version = true
# }

# probably not needed
# resource "azurerm_role_assignment" "vm-identity-role-assignment" {
#   principal_id         = azurerm_windows_virtual_machine.testvm.identity[0].principal_id
#   role_definition_name = "Storage Blob Data Reader"
#   scope                = azurerm_resource_group.demo-rg.id
# }


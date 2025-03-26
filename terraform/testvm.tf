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
  depends_on = [azurerm_resource_group_policy_assignment.prereq-policy-assignments]
}

# Alternatively, install the extension using the code below instead of using the built-in policy initiative.
# resource "azurerm_virtual_machine_extension" "guestconfiguration-extension" {
#   name                       = "AzurePolicyforWindows"
#   virtual_machine_id         = azurerm_windows_virtual_machine.testvm.id
#   publisher                  = "Microsoft.GuestConfiguration"
#   type                       = "ConfigurationForWindows"
#   type_handler_version       = "1.1"
#   auto_upgrade_minor_version = true
#   automatic_upgrade_enabled  = true
# }

# Alternatively, assign the configuration using the code below instead of using the custom configuration policy.
# resource "azapi_resource" "settimezonecst-assignment" {
#   type      = "Microsoft.GuestConfiguration/guestConfigurationAssignments@2024-04-05"
#   name      = "SetTimezoneCST"
#   parent_id = azurerm_windows_virtual_machine.testvm.id
#   location  = azurerm_resource_group.demo-rg.location
#   body = {
#     properties = {
#       guestConfiguration = {
#         name                   = "SetTimeZoneCST"
#         assignmentType         = "ApplyAndAutoCorrect"
#         contentHash            = filesha256("../dsc_configurations/timezone/SetTimeZoneCST.zip")
#         contentManagedIdentity = azurerm_user_assigned_identity.amcidentity.id
#         contentUri             = "${azurerm_storage_account.demo-sa.primary_blob_endpoint}${var.container_name}/SetTimeZoneCST.zip"
#         version                = "1.0.0"
#       }
#     }
#   }
# }

output "user_managed_identity_resource_id" {
  value       = azurerm_user_assigned_identity.amcidentity.id
  description = "The resource ID of the user assigned identity."
}

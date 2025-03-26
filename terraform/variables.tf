variable "location" {
  description = "The Azure location where the resources will be created."
  type        = string
  default     = "eastus2"
}

variable "resource_prefix" {
  description = "The prefix for the resource names."
  type        = string
  default     = "machineconfig"
}

variable "subscription_id" {
  description = "The Azure subscription ID."
  type        = string
  default     = "49a8be25-7877-4460-a634-7c9c60a5be08"
}

variable "policy_definition_ids" {
  description = "The policy definition IDs for the built-in guest configuration prerequisites policy initiative."
  type        = map(string)
  default = {
    machine_config_prereq_policy_msi = "/providers/Microsoft.Authorization/policySetDefinitions/12794019-7a00-42cf-95c2-882eed337cc8"
    machine_config_prereq_policy_mui = "/providers/Microsoft.Authorization/policySetDefinitions/2b0ce52e-301c-4221-ab38-1601e2b4cee3"
  }
}

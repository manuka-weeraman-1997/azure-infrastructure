variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "gateway_subnet_id" {
  type = string
}

variable "ssl_certificate_name" {
  type = string
}

variable "key_vault_secret_id" {
  type = string
}

variable "user_assigned_identity_id" {
  type = string
}

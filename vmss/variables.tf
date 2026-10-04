variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "default_instances" {
  type    = number
  default = 2
}

variable "min_instances" {
  type    = number
  default = 2
}

variable "max_instances" {
  type    = number
  default = 10
}

variable "admin_username" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "image_publisher" {
  type    = string
  default = "Canonical"
}

variable "image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  type    = string
  default = "22_04-lts"
}

variable "subnet_id" {
  type = string
}

variable "backend_pool_id" {
  type = string
}

variable "health_probe_id" {
  type = string
}

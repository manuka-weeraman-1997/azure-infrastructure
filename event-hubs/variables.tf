variable "namespace_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "throughput_units" {
  type    = number
  default = 2
}

variable "subnet_id" {
  type = string
}

variable "partition_count" {
  type    = number
  default = 4
}

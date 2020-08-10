variable "vnet_name" {
  type = string
}
variable "name" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "instances" {
  type = number
}
variable "subnet_address_prefix" {
  type = string
}
variable application_port {
    type = number
    default = 80
}
variable admin_user {
    type = string
    default = "sysadmin"
}
variable admin_password {
    type = string
    default = "Password$123"
}
variable wait_for {
    type = list(string)
    default = []
}

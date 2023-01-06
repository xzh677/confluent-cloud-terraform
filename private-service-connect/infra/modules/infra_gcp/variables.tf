variable "resource_prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "subnet_name_by_zone" {
  type = list(string)
}

variable "gcp_project_id" {
  type = string
}

variable "cc_psc_attachments" {
  type = map(string)
}

variable "cc_hosted_zone" {
  type = string
}

variable "cc_network_id" {
  type = string
}

variable "proxy_server_type" {
  type = string
}

variable "proxy_server_image" {
  type = string
}

variable "proxy_server_ssh_key" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "confluent_cloud_api_key" {
  type = string
}

variable "confluent_cloud_api_secret" {
  type = string
}

variable "region" {
  type = string
}

variable "schema_region_id" {
  type = string
}

variable "subnet_name_by_zone" {
  type = list(string)
}

variable "gcp_project_id" {
  type = string
}

variable "gcp_creds_path" {
  type = string
}

variable "oauth_issuer" {
  type = string
}

variable "oauth_jwks_uri" {
  type = string
}

variable "proxy_server_ssh_key" {
  type = string
}
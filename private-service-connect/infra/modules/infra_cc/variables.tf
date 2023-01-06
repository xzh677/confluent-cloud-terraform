variable "resource_prefix" {
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

variable "oauth_issuer" {
  type = string
}

variable "oauth_jwks_uri" {
  type = string
}
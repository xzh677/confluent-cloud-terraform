terraform {
  required_version = ">= 0.14.0"
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.23.0"
    }
  }
}

resource "confluent_identity_pool" "okta_identity_pool" {
  display_name = "${var.resource_prefix}-okta-identity-pool"
  description  = "oauth identity pool"

  identity_claim = "claims.sub"

  filter = "has(claims.aud)"

  identity_provider {
    id = var.oauth_identity_provider_id
  }
}

resource "confluent_role_binding" "okta_identity_pool_role_binding_topic" {
  principal = "User:${confluent_identity_pool.okta_identity_pool.id}"
  role_name = "ResourceOwner"
  # https://docs.confluent.io/cloud/current/api.html#section/Identifiers-and-URLs/Confluent-Resource-Names-(CRNs)
  crn_pattern = "${var.cluster_rbac_crn}/kafka=${var.cluster_id}/topic=xyz.*"
}

resource "confluent_role_binding" "okta_identity_pool_role_binding_group" {
  principal = "User:${confluent_identity_pool.okta_identity_pool.id}"
  role_name = "ResourceOwner"
  # https://docs.confluent.io/cloud/current/api.html#section/Identifiers-and-URLs/Confluent-Resource-Names-(CRNs)
  crn_pattern = "${var.cluster_rbac_crn}/kafka=${var.cluster_id}/group=console-consumer-*"
}
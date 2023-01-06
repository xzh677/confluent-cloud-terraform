terraform {
  required_version = ">= 0.14.0"
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.23.0"
    }
  }
}

resource "confluent_identity_provider" "okta_provider" {
  display_name = "${var.resource_prefix}-okta-identity-provider"
  description  = "oauth identity provider"
  issuer       = var.oauth_issuer
  jwks_uri     = var.oauth_jwks_uri
}

resource "confluent_environment" "dev" {
  display_name = "${var.resource_prefix}-dev"
}

resource "confluent_schema_registry_cluster" "schema_registry" {

  # See https://docs.confluent.io/cloud/current/stream-governance/packages.html#stream-governance-regions
  package = "ADVANCED"

  environment {
    id = confluent_environment.dev.id
  }

  region {
    # See https://docs.confluent.io/cloud/current/stream-governance/packages.html#sr-regions
    id = var.schema_region_id
  }
}

resource "confluent_network" "private_service_connect" {
  display_name     = "${var.resource_prefix}-psc"
  cloud            = "GCP"
  region           = var.region
  connection_types = ["PRIVATELINK"]
  zones            = var.subnet_name_by_zone
  environment {
    id = confluent_environment.dev.id
  }
}

resource "confluent_kafka_cluster" "dev" {
  display_name = "${var.resource_prefix}-cluster"
  availability = "MULTI_ZONE"
  cloud        = confluent_network.private_service_connect.cloud
  region       = confluent_network.private_service_connect.region
  dedicated {
    cku = 2
  }
  environment {
    id = confluent_environment.dev.id
  }
  network {
    id = confluent_network.private_service_connect.id
  }

  # Self managed encryption
}

resource "confluent_private_link_access" "gcp" {
  display_name = "${var.resource_prefix}-gcp-access"
  gcp {
    project = var.gcp_project_id
  }
  environment {
    id = confluent_environment.dev.id
  }
  network {
    id = confluent_network.private_service_connect.id
  }
}

resource "confluent_service_account" "cluster_admin" {
  display_name = "${var.resource_prefix}-${confluent_kafka_cluster.dev.id}-admin"
  description  = "Service account to manage Kafka cluster"
}

resource "confluent_role_binding" "cluster_admin_role_binding" {
  principal = "User:${confluent_service_account.cluster_admin.id}"
  role_name = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.dev.rbac_crn
}

locals {
  hostname_regex_result = regex("^[^.]+-([0-9a-zA-Z]+[.].*):[0-9]+$", confluent_kafka_cluster.dev.bootstrap_endpoint)[0]
  hosted_zone  = replace(local.hostname_regex_result, "glb.", "")
  network_id   = regex("^([^.]+)[.].*", local.hosted_zone)[0]
}

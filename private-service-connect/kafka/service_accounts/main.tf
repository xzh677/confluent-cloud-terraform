terraform {
  required_version = ">= 0.14.0"
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.23.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.47.0"
    }
  }
}

resource "confluent_api_key" "cluster_admin_kafka_api_key" {
  display_name = "${var.resource_prefix}-${var.cluster_id}-admin-kafka-api-key"
  description  = "Kafka API Key that is owned by 'cluster admin' service account"
  owner {
    id          = var.cluster_admin_id
    api_version = var.cluster_admin_api_version
    kind        = var.cluster_admin_kind
  }

  managed_resource {
    id          = var.cluster_id
    api_version = var.cluster_api_version
    kind        = var.cluster_kind

    environment {
      id = var.environment_id
    }
  }
}

resource "google_secret_manager_secret" "cluster_admin_key" {
  secret_id = "${var.resource_prefix}-${var.cluster_id}-admin-key"
  replication {
    automatic = true
  }
  depends_on = [
    confluent_api_key.cluster_admin_kafka_api_key
  ]
}

resource "google_secret_manager_secret_version" "cluster_admin_key_1" {
  secret      = google_secret_manager_secret.cluster_admin_key.id
  secret_data = confluent_api_key.cluster_admin_kafka_api_key.id
}

resource "google_secret_manager_secret" "cluster_admin_secret" {
  secret_id = "${var.resource_prefix}-${var.cluster_id}-admin-secret"
  replication {
    automatic = true
  }
  depends_on = [
    confluent_api_key.cluster_admin_kafka_api_key
  ]
}

resource "google_secret_manager_secret_version" "cluster_admin_secret_1" {
  secret      = google_secret_manager_secret.cluster_admin_secret.id
  secret_data = confluent_api_key.cluster_admin_kafka_api_key.secret
}

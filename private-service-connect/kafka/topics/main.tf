terraform {
  required_version = ">= 0.14.0"
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.23.0"
    }
  }
}

resource "confluent_kafka_topic" "abc_topic" {
  kafka_cluster {
    id = var.cluster_id
  }
  rest_endpoint = var.cluster_rest_endpoint
  credentials {
    key    = var.confluent_kafka_api_key
    secret = var.confluent_kafka_api_secret
  }

  topic_name       = "abc.topic"
  partitions_count = 2
}

resource "confluent_kafka_topic" "xyz_topic" {
  kafka_cluster {
    id = var.cluster_id
  }
  rest_endpoint = var.cluster_rest_endpoint
  credentials {
    key    = var.confluent_kafka_api_key
    secret = var.confluent_kafka_api_secret
  }

  topic_name       = "xyz.topic"
  partitions_count = 2
}
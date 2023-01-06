output "cluster_admin_kafka_api_key" {
  value     = confluent_api_key.cluster_admin_kafka_api_key
  sensitive = true
}
output "environment_id" {
  value = confluent_environment.dev.id
}

output "oauth_identity_provider_id" {
  value = confluent_identity_provider.okta_provider.id
}

output "cluster_id" {
  value = confluent_kafka_cluster.dev.id
}

output "cluster_api_version" {
  value = confluent_kafka_cluster.dev.api_version
}

output "cluster_kind" {
  value = confluent_kafka_cluster.dev.kind
}

output "cluster_bootstrap_endpoint" {
  value = confluent_kafka_cluster.dev.bootstrap_endpoint
}

output "cluster_rest_endpoint" {
  value = confluent_kafka_cluster.dev.rest_endpoint
}

output "psc_attachements" {
  value = confluent_network.private_service_connect.gcp[0].private_service_connect_service_attachments
}

output "hosted_zone" {
  value = local.hosted_zone
}

output "network_id" {
  value = local.network_id
}

output "cluster_rbac_crn" {
 value = confluent_kafka_cluster.dev.rbac_crn
}

output "cluster_admin_id" {
  value = confluent_service_account.cluster_admin.id
}

output "cluster_admin_api_verion" {
  value = confluent_service_account.cluster_admin.api_version
}

output "cluster_admin_api_kind" {
  value = confluent_service_account.cluster_admin.kind
}
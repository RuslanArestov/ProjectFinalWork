output "bucket_name" {
  value = yandex_storage_bucket.tf_state.bucket
}

output "sa-infra_id" {
  value = yandex_iam_service_account.sa-infra.id
}

output "access_key_id" {
  value = yandex_iam_service_account_static_access_key.sa-infra_key.access_key
}

output "secret_key" {
  value     = yandex_iam_service_account_static_access_key.sa-infra_key.secret_key
  sensitive = true
}
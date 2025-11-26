# Использовал первоначально
output "bucket_name" {
  value = yandex_storage_bucket.tf_state.bucket
}

# Для импорта в директорию Infrastructure
output "sa-infra_id" {
  value = yandex_iam_service_account.sa-infra.id
}

# Получаем секреты для авторизации в бакете. Использовал для миграции state файлов в бакет,
# и импорта id infra-sa из одного состояния (из Backend в Infrastructure)
# в другое через ресурс data "terraform_remote_state" 
output "access_key_id" {
  value = yandex_iam_service_account_static_access_key.sa-infra_key.access_key
}

output "secret_key" {
  value     = yandex_iam_service_account_static_access_key.sa-infra_key.secret_key
  sensitive = true
}

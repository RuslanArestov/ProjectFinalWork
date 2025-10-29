resource "yandex_iam_service_account" "sa-infra" {
  name        = "sa-infra"
  folder_id = var.folder_id 
  description = " sa для управления инфраструктурой Terraform"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-infra_storage_admin" {
  role        = "storage.admin"
  member      = "serviceAccount:${yandex_iam_service_account.sa-infra.id}"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "sa-infra_vpc_admin" {
  role        = "vpc.admin"
  member      = "serviceAccount:${yandex_iam_service_account.sa-infra.id}"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "sa-infra_compute_admin" {
  role      = "compute.admin"           
  member    = "serviceAccount:${yandex_iam_service_account.sa-infra.id}"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "sa-infra_kms_keys_encrypter_decrypter" {
  role      = "kms.keys.encrypterDecrypter"           
  member    = "serviceAccount:${yandex_iam_service_account.sa-infra.id}"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "sa-infra_alb_admin" {
  role      = "alb.admin"           
  member    = "serviceAccount:${yandex_iam_service_account.sa-infra.id}"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "sa-infra_kms_admin" {
  role      = "kms.admin"           
  member    = "serviceAccount:${yandex_iam_service_account.sa-infra.id}"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "sa-infra_iam_admin" {
  role      = "iam.admin"           
  member    = "serviceAccount:${yandex_iam_service_account.sa-infra.id}"
  folder_id = var.folder_id
}

resource "yandex_iam_service_account_static_access_key" "sa-infra_key" {
  service_account_id = yandex_iam_service_account.sa-infra.id
  depends_on = [yandex_iam_service_account.sa-infra]
}

resource "yandex_kms_symmetric_key" "infra_key" {
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h"
}

resource "yandex_storage_bucket" "tf_state" {
  bucket     = var.bucket_name       
  max_size   = 1073741824
    force_destroy = true 
  versioning {
    enabled = true
  }

    #Настроить блокировку состояния (создать таблицу в YDB)
  #Настроить блокировку версии объекта
  # object_lock_configuration {
  #   object_lock_enabled = "Enabled"
  # }

  # server_side_encryption_configuration {
  #   rule {
  #     apply_server_side_encryption_by_default {
  #       kms_master_key_id = yandex_kms_symmetric_key.infra_key.id
  #       sse_algorithm     = "aws:kms"
  #     }
  #   }
  # }

  depends_on = [
    yandex_iam_service_account.sa-infra
  ]
} 

resource "yandex_storage_bucket_iam_binding" "sa-admins" {
  bucket  = var.bucket_name
  role    = "storage.admin"
  members = [
              "serviceAccount:${yandex_iam_service_account.sa-infra.id}"
            ]
  depends_on = [yandex_storage_bucket.tf_state]          
}
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.125.0"
    }
  }
  required_version = ">=1.5"

backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    region = "ru-central1"
    key    = "infrastructure/state/main.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    bucket = "my-terraform-state-bucket"
  } 
}

provider "yandex" {
  zone                     = var.zone_a
  service_account_key_file = file("./key.json")
}


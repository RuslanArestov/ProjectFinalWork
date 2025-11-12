terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.125.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
  }
  required_version = ">=1.13.4"

backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "bucket-tf1"
    region = "ru-central1"
    key    = "infrastructure/state/main.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  } 
}

provider "yandex" {
  zone                     = var.zone_a
  service_account_key_file = file("./key.json")
}


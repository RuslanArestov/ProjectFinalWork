# Добавление прочих переменных

locals {
  registry_name      = "my-registry"
  function_name      = "scan-on-push"
  trigger_name       = "trigger-for-reg"
}

resource "yandex_container_registry" "nginx-app" {
  name = local.registry_name
  labels = {
    my-label = "nginx"
  }
}

resource "null_resource" "docker_build_and_push" {
  provisioner "local-exec" {
    command = <<EOT
      yc config profile create infra-sa
      yc config set service-account-key key.json --profile infra-sa
      yc config set folder-id $YC_FOLDER_ID --profile infra-sa
      yc config set cloud-id $YC_FOLDER_ID --profile infra-sa
      yc container registry configure-docker
      docker build -t cr.yandex/${yandex_container_registry.nginx-app.id}/nginx-app:latest ~/App
      docker push cr.yandex/${yandex_container_registry.nginx-app.id}/nginx-app:latest
    
      
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [ 
                 yandex_container_registry.nginx-app,
                 yandex_function.test-function,
                 yandex_function_trigger.my-trigger
               ]
}

# Создание функции для автоматического сканирования

resource "yandex_function" "test-function" {
  name               = local.function_name
  user_hash          = "my-first-function"
  runtime            = "bash"
  entrypoint         = "handler.sh"
  memory             = "128"
  execution_timeout  = "60"
  service_account_id = data.terraform_remote_state.backend.outputs["sa-infra_id"]
  content {
    zip_filename   = "function.zip"
  }
}

# Создание триггера

resource "yandex_function_trigger" "my-trigger" {

  name = local.trigger_name
  function {
    id                 = yandex_function.test-function.id
    service_account_id = data.terraform_remote_state.backend.outputs["sa-infra_id"]
  }
  container_registry {
    registry_id      = yandex_container_registry.nginx-app.id
    create_image_tag = true
    batch_cutoff     = "10"
    batch_size       = "1"
  }
}

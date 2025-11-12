resource "yandex_vpc_network" "k8s-network" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "k8s-subnet-a" {
  name           = var.subnet_a_name
  zone           = var.zone_a
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = [var.subnet_cidr_a]
  route_table_id = yandex_vpc_route_table.private_nodes_rt.id
}

resource "yandex_vpc_subnet" "k8s-subnet-b" {
  name           = var.subnet_b_name
  zone           = var.zone_b
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = [var.subnet_cidr_b]
  route_table_id = yandex_vpc_route_table.private_nodes_rt.id
}

resource "yandex_vpc_subnet" "bastion-subnet" {
  name           = "bastion-subnet"
  zone           = var.zone_a
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["10.0.4.0/24"]
}

#Не использовал ru-central1-d в workers, т.к. в ней нельзя создать дешевый standard-v1
resource "yandex_vpc_subnet" "k8s-subnet-d" {
  name           = var.subnet_d_name
  zone           = var.zone_d
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = [var.subnet_cidr_d]
}

# Меняем маршрут по умолчанию для мастер и воркер нод для выхода в Интернет
resource "yandex_vpc_route_table" "private_nodes_rt" {
  name       = "private-nodes-rt"
  network_id = yandex_vpc_network.k8s-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.bastion.network_interface.0.ip_address
  }
}

resource "yandex_vpc_security_group" "k8s_sg" {
  name       = "k8s_sg"
  network_id = yandex_vpc_network.k8s-network.id

  #  ingress {
  #   protocol       = "TCP"
  #   port           = 22
  #   v4_cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   protocol       = "TCP"
  #   port           = 30080
  #   security_group_id = yandex_vpc_security_group.alb_sg.id
  # }

  # ingress {
  #   protocol       = "TCP"
  #   port           = 30080
  #   v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
  # }

    ingress {
    protocol       = "TCP"
    from_port = 0
    to_port = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    protocol       = "UDP"
    from_port = 0
    to_port = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    protocol       = "ICMP"
    description    = "Allow all ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "alb_sg" {
  name       = "alb-sg"
  network_id = yandex_vpc_network.k8s-network.id


  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 30080
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  zone        = "ru-central1-a"
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 4
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.bastion-subnet.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
  }

  metadata = {
    user-data = data.template_file.userdata_bastion.rendered
  }
}

resource "yandex_compute_instance" "master" {
  count = 3
  name  = "master-${count.index}"
  zone       = element(["ru-central1-a", "ru-central1-b"], count.index)
  platform_id = "standard-v1"

  resources {
    cores  = 4
    memory = 6
    core_fraction = 5
  }

  scheduling_policy {
    preemptible = false
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = element([yandex_vpc_subnet.k8s-subnet-a.id, yandex_vpc_subnet.k8s-subnet-b.id], count.index)
    nat       = false
    security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
  }

  allow_stopping_for_update = true

  metadata = {
     user-data = data.template_file.userdata.rendered
  }
}

resource "yandex_compute_instance_group" "worker" {
  name                = "worker-instance-group"
  service_account_id = data.terraform_remote_state.backend.outputs["sa-infra_id"]
  deletion_protection = false

  instance_template {
    platform_id = "standard-v1"
    name        = "worker-{instance.index}"
    
    resources {
      memory = 6
      cores  = 2
    }

    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu.image_id
        size     = 20
        type     = "network-hdd"
      }
    }

    scheduling_policy {
    preemptible = true
  }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.k8s-subnet-a.id, yandex_vpc_subnet.k8s-subnet-b.id]
      nat       = false
      security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
    }

    metadata = {
      user-data = data.template_file.userdata.rendered
    }
  }

  application_load_balancer {
      target_group_name        = "k8s-nodes"
      target_group_description = "Workers for ALB"
    }

  scale_policy {
    auto_scale {
      initial_size = 4
      min_zone_size     = 2
      max_size     = 6
      measurement_duration = 60
      cpu_utilization_target = 75
    }  
  }
  
  allocation_policy {
    zones = [var.zone_a, var.zone_b]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }
}

resource "yandex_alb_backend_group" "k8s_backend" {
  name = "k8s-backend-group"

  http_backend {
    name   = "k8s-http-backend"
    weight = 1
    port   = 30082

    target_group_ids = [yandex_compute_instance_group.worker.application_load_balancer[0].target_group_id]

    
    healthcheck {
      timeout             = "10s"
      interval            = "5s"
      healthy_threshold   = 3
      unhealthy_threshold = 3
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "k8s_router" {
  name = "k8s-http-router"
}

resource "yandex_alb_virtual_host" "k8s_host" {
  name           = "k8s-virtual-host"
  http_router_id = yandex_alb_http_router.k8s_router.id

  route {
    name = "k8s-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.k8s_backend.id
        timeout          = "60s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "k8s_alb" {
  name               = "k8s-alb"
  network_id         = yandex_vpc_network.k8s-network.id
  security_group_ids = [yandex_vpc_security_group.alb_sg.id]

  allocation_policy {
    location {
      zone_id   = var.zone_a
      subnet_id = yandex_vpc_subnet.k8s-subnet-a.id
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.k8s_router.id
      }
    }
  }
}

# # Импортирую сведения о state файле изи папки Backend.
# В частности это нужно для импорта id infra-sa в ресурс resource "yandex_compute_instance_group" "worker"
data "terraform_remote_state" "backend" {
  backend = "s3"
  config  = {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "bucket-tf1"
    region   = "ru-central1"
    key    = "backend/state/main.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    access_key = var.access_key
    secret_key = var.secret_key
  }
}

data "template_file" "userdata" {
  template = file("${path.module}/cloud-init.yml")
  vars = {
    username     = var.username
    ssh_public_key = file(var.ssh_public_key)
  }
}

data "template_file" "userdata_bastion" {
  template = file("${path.module}/cloud-init-bastion.yml")
  vars = {
    username     = var.username
    ssh_public_key = file(var.ssh_public_key)
  }
}

# comment
# comment # 2
# comment # 3
# comment # 4
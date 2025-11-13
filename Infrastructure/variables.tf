#Использовать вместо обычных переменных map, local и т.п.
variable "folder_id" {
  type        = string
}

variable "network_name" {
  type    = string
  default = "k8s-network"
}

variable "subnet_a_name" {
  type    = string
  default = "k8s-subnet-a"
}

variable "subnet_b_name" {
  type    = string
  default = "k8s-subnet-b"
}

variable "subnet_d_name" {
  type    = string
  default = "k8s-subnet-d"
}

variable "zone_a" {
  type    = string
  default = "ru-central1-a"
}

variable "zone_b" {
  type    = string
  default = "ru-central1-b"
}

variable "zone_d" {
  type    = string
  default = "ru-central1-d"
}

variable "zones" {
  default = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}

variable "subnet_cidr_a" {
  type    = string
  default = "10.0.1.0/24"
}

variable "subnet_cidr_b" {
  type    = string
  default = "10.0.2.0/24"
}

variable "subnet_cidr_d" {
  type    = string
  default = "10.0.3.0/24"
}

variable "ssh_public_key" {
  type    = string
  # default = "~/.ssh/k8s_key.pub"
  default     = "/secrets/ssh/k8s_key.pub"
}

variable "ssh_private_key_path" {
  type    = string
  # default = "~/.ssh/k8s_key"
  default     = "/secrets/ssh/k8s_key"
}

variable "username" {
  type    = string
  default = "user_admin"
}

variable "access_key" {
  type      = string
  sensitive = true
}

variable "secret_key" {
  type      = string
  sensitive = true
}

variable "sa_key_json" {
  type    = string
  default = "/secrets/infra/key.json"
}

output "bastion_public_ip" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

# output "alb_ip" {
#   value = yandex_alb_load_balancer.k8s_alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
# }

output "master_private_ips" {
  value = [for m in yandex_compute_instance.master : m.network_interface[0].ip_address]
}

output "worker_private_ips" {
  value = [for w in yandex_compute_instance_group.worker.instances : w.network_interface[0].ip_address]
}

output "ssh_user" {
  value = var.username
}

output "ssh_private_key_path" {
  value = var.ssh_private_key_path
}

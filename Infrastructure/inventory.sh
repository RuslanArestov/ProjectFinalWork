#!/usr/bin/env bash
set -e

# Получаем значения outputов из Terraform
masters=$(terraform output -json master_private_ips | jq -r '.[]')
workers=$(terraform output -json worker_private_ips | jq -r '.[]')
user=$(terraform output -raw ssh_user)
key_path=$(terraform output -raw ssh_private_key_path)

inventory_file="inventory.ini"

echo "[kube_control_plane]" > $inventory_file
i=1
for ip in $masters; do
  echo "master${i} ansible_host=${ip} ip=${ip} etcd_member_name=etcd${i}" >> $inventory_file
  ((i++))
done

echo -e "\n[etcd:children]\nkube_control_plane" >> $inventory_file

echo -e "\n[kube_node]" >> $inventory_file
i=1
for ip in $workers; do
  echo "worker${i} ansible_host=${ip} ip=${ip}" >> $inventory_file
  ((i++))
done

cat <<EOF >> $inventory_file

[all:vars]
ansible_user=${user}
ansible_ssh_private_key_file=${key_path}
EOF

echo "Inventory успешно сгенерирован: ${inventory_file}"
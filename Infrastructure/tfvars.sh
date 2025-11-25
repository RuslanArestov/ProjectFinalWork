#!/usr/bin/env bash
set -e

echo "" > terraform.tfvars
echo "access_key = \"$YC_ACCESS_KEY\"" > terraform.tfvars
echo "secret_key = \"$YC_SECRET_KEY\"" >> terraform.tfvars
echo "sa_key_json = \"./key.json\"" >> terraform.tfvars
echo "ssh_public_key = \"~/.ssh/k8s_key.pub\"" >> terraform.tfvars
echo "ssh_private_key_path = \"~/.ssh/k8s_key\"" >> terraform.tfvars
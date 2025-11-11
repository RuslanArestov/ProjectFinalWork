#!/bin/bash
set -e

if [ ! -d "kubespray" ]; then
    git clone https://github.com/kubernetes-sigs/kubespray.git
fi

cd kubespray
python3 -m venv venv1

source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

cp -rfp ~/kubespray/inventory/sample inventory/mycluster
cp -rfp inventory.ini ~/kubespray/inventory/mycluster/

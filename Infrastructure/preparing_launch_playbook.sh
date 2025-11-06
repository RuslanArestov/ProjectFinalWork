#!/bin/bash
set -e

if [ ! -d "kubespray" ]; then
    git clone https://github.com/kubernetes-sigs/kubespray.git
    cd kubespray
fi

python3 -m venv venv

source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

cp -rfp inventory/sample inventory/mycluster

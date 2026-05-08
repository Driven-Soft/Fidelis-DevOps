#!/bin/bash

# =========================================
# CONFIGURAÇÕES DO PROJETO FIDELIS
# =========================================

GRUPO=fidelis
LOCATION=brazilsouth
USER=azureuser
PASSWORD='Fidelis@2026'

RG=rg-$GRUPO
VNET=vnet-$GRUPO
SUBNET=subnet-$GRUPO
NSG=nsg-$GRUPO
VM=vm-$GRUPO
VMSIZE=Standard_E2s_v3

# =========================================
# LOGIN AZURE
# =========================================
# az login

# =========================================
# 1. CRIAR RESOURCE GROUP
# =========================================

az group create \
  --name $RG \
  --location $LOCATION \
  --tags projeto=Fidelis ambiente=dev

# =========================================
# 2. CRIAR VNET E SUBNET
# =========================================

az network vnet create \
  --resource-group $RG \
  --name $VNET \
  --address-prefix 10.10.0.0/16 \
  --subnet-name $SUBNET \
  --subnet-prefix 10.10.1.0/24

# =========================================
# 3. CRIAR NETWORK SECURITY GROUP
# =========================================

az network nsg create \
  --resource-group $RG \
  --name $NSG

# =========================================
# 4. ADICIONAR REGRAS DE PORTA
# =========================================

# SSH
az network nsg rule create \
  --resource-group $RG \
  --nsg-name $NSG \
  --name allow-ssh \
  --protocol Tcp \
  --priority 1000 \
  --destination-port-range 22 \
  --access Allow

# HTTP
az network nsg rule create \
  --resource-group $RG \
  --nsg-name $NSG \
  --name allow-http \
  --protocol Tcp \
  --priority 1001 \
  --destination-port-range 80 \
  --access Allow

# API
az network nsg rule create \
  --resource-group $RG \
  --nsg-name $NSG \
  --name allow-8080 \
  --protocol Tcp \
  --priority 1002 \
  --destination-port-range 8080 \
  --access Allow

# H2 Console (opcional)
az network nsg rule create \
  --resource-group $RG \
  --nsg-name $NSG \
  --name allow-9090 \
  --protocol Tcp \
  --priority 1003 \
  --destination-port-range 9090 \
  --access Allow

# =========================================
# 5. ASSOCIAR NSG À SUBNET
# =========================================

az network vnet subnet update \
  --resource-group $RG \
  --vnet-name $VNET \
  --name $SUBNET \
  --network-security-group $NSG

# =========================================
# 6. CRIAR VM UBUNTU
# =========================================

az vm create \
  --resource-group $RG \
  --name $VM \
  --image Ubuntu2204 \
  --admin-username $USER \
  --admin-password $PASSWORD \
  --authentication-type password \
  --size $VMSIZE \
  --vnet-name $VNET \
  --subnet $SUBNET \
  --nsg $NSG

# =========================================
# 7. INSTALAR DOCKER, GIT E NANO
# =========================================

az vm run-command invoke \
  --resource-group $RG \
  --name $VM \
  --command-id RunShellScript \
  --scripts '
    export DEBIAN_FRONTEND=noninteractive

    sudo apt-get update -y

    sudo apt-get install -y \
      ca-certificates \
      curl \
      git \
      nano

    sudo install -m 0755 -d /etc/apt/keyrings

    sudo curl -fsSL \
      https://download.docker.com/linux/ubuntu/gpg \
      -o /etc/apt/keyrings/docker.asc

    sudo chmod a+r /etc/apt/keyrings/docker.asc

    sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    sudo apt-get update -y

    sudo apt-get install -y \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin

    sudo systemctl enable docker
    sudo systemctl start docker

    sudo usermod -aG docker azureuser
  '
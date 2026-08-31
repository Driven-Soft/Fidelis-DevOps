#!/bin/bash

# =========================================================
# CONFIGURAÇÕES GERAIS - FIDELIS CHALLENGE ACR/ACI
# =========================================================

RM="rm564723"

RESOURCE_GROUP="rg-${RM}-fidelis-challenge"
LOCATION="eastus"

# Azure Container Registry
# Nome deve ser globalmente único e usar apenas letras/números
ACR_NAME="${RM}fidelisacr"

# Storage Account
# Nome deve usar apenas letras minúsculas e números
STORAGE_ACCOUNT="${RM}fidelisdata"

FILE_SHARE="mysql-fidelis-volume"

# Imagens
APP_IMAGE="${RM}-fidelis-api"
DB_IMAGE="${RM}-fidelis-mysql"
TAG="v1"

# Azure Container Instances
APP_ACI="${RM}-fidelis-api"
DB_ACI="${RM}-fidelis-mysql"

# DNS públicos
APP_DNS="${RM}-fidelis-api"
DB_DNS="${RM}-fidelis-mysql"
#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/00_config_geral.sh"


echo "=========================================="
echo "FIDELIS - CONFIGURAÇÃO DO MYSQL MANAGED"
echo "=========================================="

if [ ! -f "$REPO_ROOT/.env" ]; then
    echo "ERRO: arquivo .env não encontrado."
    echo "Crie o .env baseado no .env.example."
    exit 1
fi

set -a
source "$REPO_ROOT/.env"
set +a

if [ -z "${MYSQL_PASSWORD:-}" ]; then
    echo "ERRO: MYSQL_PASSWORD não definida no .env."
    exit 1
fi

if ! az mysql flexible-server show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$MYSQL_SERVER_NAME" &>/dev/null; then

    echo "ERRO: MySQL Flexible Server '$MYSQL_SERVER_NAME' não encontrado."
    echo "Execute primeiro: azure/01_criacao_infra.sh"
    exit 1
fi

if ! az mysql flexible-server db show \
    --resource-group "$RESOURCE_GROUP" \
    --server-name "$MYSQL_SERVER_NAME" \
    --database-name "$MYSQL_DATABASE" &>/dev/null; then

    echo "Criando banco '$MYSQL_DATABASE'..."

    az mysql flexible-server db create \
        --resource-group "$RESOURCE_GROUP" \
        --server-name "$MYSQL_SERVER_NAME" \
        --database-name "$MYSQL_DATABASE" \
        --output none
fi

if ! az mysql flexible-server firewall-rule show \
    --resource-group "$RESOURCE_GROUP" \
    --server-name "$MYSQL_SERVER_NAME" \
    --name "AllowAzureServices" &>/dev/null; then

    echo "Criando regra de firewall 'AllowAzureServices'..."

    az mysql flexible-server firewall-rule create \
        --resource-group "$RESOURCE_GROUP" \
        --server-name "$MYSQL_SERVER_NAME" \
        --name "AllowAzureServices" \
        --start-ip-address "0.0.0.0" \
        --end-ip-address "0.0.0.0" \
        --output none
fi

MYSQL_FQDN=$(az mysql flexible-server show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$MYSQL_SERVER_NAME" \
    --query fullyQualifiedDomainName \
    --output tsv)

echo "MySQL Flexible Server disponível em:"
echo "$MYSQL_FQDN"

echo ""
echo "Connection string para app service:"
echo "Server=${MYSQL_FQDN};Port=3306;Database=${MYSQL_DATABASE};User ID=${MYSQL_ADMIN_LOGIN}@${MYSQL_SERVER_NAME};Password=${MYSQL_PASSWORD};Ssl Mode=Required;"
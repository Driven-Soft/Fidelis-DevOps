#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/00_config_geral.sh"

AZ_RETRY_ATTEMPTS="${AZ_RETRY_ATTEMPTS:-12}"
AZ_RETRY_WAIT_SECONDS="${AZ_RETRY_WAIT_SECONDS:-20}"

wait_for_resource() {
    local resource_type="$1"
    local resource_name="$2"
    local check_command=("${@:3}")

    local attempt=1
    while (( attempt <= AZ_RETRY_ATTEMPTS )); do
        if "${check_command[@]}" &>/dev/null; then
            echo "Recurso '$resource_name' disponível."
            return 0
        fi

        echo "Aguardando disponibilidade de $resource_type '$resource_name' (${attempt}/${AZ_RETRY_ATTEMPTS})..."
        sleep "$AZ_RETRY_WAIT_SECONDS"
        ((attempt++))
    done

    echo "ERRO: timeout aguardando $resource_type '$resource_name'."
    return 1
}

retry_az_create() {
    local description="$1"
    shift

    local attempt=1
    while (( attempt <= AZ_RETRY_ATTEMPTS )); do
        local output
        if output=$("$@" 2>&1); then
            echo "$output"
            return 0
        fi

        echo "Tentativa $attempt/$AZ_RETRY_ATTEMPTS para $description falhou."
        echo "$output"

        if echo "$output" | grep -Eqi "exclusive lock|retry the request later|operation is in progress|locked|temporarily unavailable"; then
            echo "Azure está com lock/transiente. Aguardando e tentando novamente..."
            sleep "$AZ_RETRY_WAIT_SECONDS"
            ((attempt++))
            continue
        fi

        if echo "$output" | grep -Eqi "already exists|conflict"; then
            echo "Recurso já existe; assumindo criação concluída."
            return 0
        fi

        echo "ERRO: falha persistente em $description."
        return 1
    done

    echo "ERRO: excedeu o número de tentativas para $description."
    return 1
}

echo "=========================================="
echo "FIDELIS - CRIAÇÃO DA INFRAESTRUTURA AZURE"
echo "=========================================="

# ---------------------------------------------------------
# Verifica autenticação Azure
# ---------------------------------------------------------

if ! az account show &>/dev/null; then
    echo "ERRO: Azure CLI não está autenticado."
    echo "Execute: az login"
    exit 1
fi

# ---------------------------------------------------------
# Providers utilizados pelo projeto
# ---------------------------------------------------------

echo "Registrando providers..."

az provider register \
    --namespace Microsoft.Web \
    --wait \
    --output none

az provider register \
    --namespace Microsoft.DBforMySQL \
    --wait \
    --output none

# ---------------------------------------------------------
# Resource Group
# ---------------------------------------------------------

if ! az group show \
    --name "$RESOURCE_GROUP" &>/dev/null; then

    echo "Criando Resource Group '$RESOURCE_GROUP'..."

    retry_az_create "criação do Resource Group '$RESOURCE_GROUP'" \
        az group create \
            --name "$RESOURCE_GROUP" \
            --location "$LOCATION" \
            --output none

    wait_for_resource "Resource Group" "$RESOURCE_GROUP" \
        az group show \
            --name "$RESOURCE_GROUP"

else
    echo "Resource Group '$RESOURCE_GROUP' já existe."
fi

# ---------------------------------------------------------
# App Service Plan + Web App
# ---------------------------------------------------------

if ! az appservice plan show \
    --name "$APP_SERVICE_PLAN" \
    --resource-group "$RESOURCE_GROUP" &>/dev/null; then

    echo "Criando App Service Plan '$APP_SERVICE_PLAN'..."

    retry_az_create "criação do App Service Plan '$APP_SERVICE_PLAN'" \
        az appservice plan create \
            --name "$APP_SERVICE_PLAN" \
            --resource-group "$RESOURCE_GROUP" \
            --location "$LOCATION" \
            --is-linux \
            --sku B1 \
            --output none

    wait_for_resource "App Service Plan" "$APP_SERVICE_PLAN" \
        az appservice plan show \
            --name "$APP_SERVICE_PLAN" \
            --resource-group "$RESOURCE_GROUP"

else
    echo "App Service Plan '$APP_SERVICE_PLAN' já existe."
fi

if ! az webapp show \
    --name "$WEBAPP_NAME" \
    --resource-group "$RESOURCE_GROUP" &>/dev/null; then

    echo "Criando Web App '$WEBAPP_NAME'..."

    retry_az_create "criação do Web App '$WEBAPP_NAME'" \
        az webapp create \
            --resource-group "$RESOURCE_GROUP" \
            --plan "$APP_SERVICE_PLAN" \
            --name "$WEBAPP_NAME" \
            --runtime "$APP_RUNTIME" \
            --output none

    wait_for_resource "Web App" "$WEBAPP_NAME" \
        az webapp show \
            --name "$WEBAPP_NAME" \
            --resource-group "$RESOURCE_GROUP"

else
    echo "Web App '$WEBAPP_NAME' já existe."
fi

# ---------------------------------------------------------
# Azure Database for MySQL Flexible Server
# ---------------------------------------------------------

if [ ! -f "$SCRIPT_DIR/../.env" ]; then
    echo "ERRO: arquivo .env não encontrado."
    echo "Crie o .env com MYSQL_PASSWORD=sua_senha."
    exit 1
fi

set -a
source "$SCRIPT_DIR/../.env"
set +a

if [ -z "${MYSQL_PASSWORD:-}" ]; then
    echo "ERRO: MYSQL_PASSWORD não definida no .env."
    exit 1
fi

if ! az mysql flexible-server show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$MYSQL_SERVER_NAME" &>/dev/null; then

    echo "Criando MySQL Flexible Server '$MYSQL_SERVER_NAME'..."

    retry_az_create "criação do MySQL Flexible Server '$MYSQL_SERVER_NAME'" \
        az mysql flexible-server create \
            --resource-group "$RESOURCE_GROUP" \
            --name "$MYSQL_SERVER_NAME" \
            --location "$LOCATION" \
            --admin-user "$MYSQL_ADMIN_LOGIN" \
            --admin-password "$MYSQL_PASSWORD" \
            --sku-name "$MYSQL_SKU" \
            --tier Burstable \
            --version 8.0.21 \
            --public-access Enabled \
            --output none

    wait_for_resource "MySQL Flexible Server" "$MYSQL_SERVER_NAME" \
        az mysql flexible-server show \
            --resource-group "$RESOURCE_GROUP" \
            --name "$MYSQL_SERVER_NAME"

else
    echo "MySQL Flexible Server '$MYSQL_SERVER_NAME' já existe."
fi

if ! az mysql flexible-server db show \
    --resource-group "$RESOURCE_GROUP" \
    --server-name "$MYSQL_SERVER_NAME" \
    --database-name "$MYSQL_DATABASE" &>/dev/null; then

    echo "Criando banco '$MYSQL_DATABASE'..."

    retry_az_create "criação do banco '$MYSQL_DATABASE' no MySQL" \
        az mysql flexible-server db create \
            --resource-group "$RESOURCE_GROUP" \
            --server-name "$MYSQL_SERVER_NAME" \
            --database-name "$MYSQL_DATABASE" \
            --output none

else
    echo "Banco '$MYSQL_DATABASE' já existe."
fi

if ! az mysql flexible-server firewall-rule show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$MYSQL_SERVER_NAME" \
    --rule-name "AllowAzureServices" &>/dev/null; then

    echo "Configurando regra de firewall do MySQL para Azure Services..."

    retry_az_create "criação da regra de firewall 'AllowAzureServices'" \
        az mysql flexible-server firewall-rule create \
            --resource-group "$RESOURCE_GROUP" \
            --name "$MYSQL_SERVER_NAME" \
            --rule-name "AllowAzureServices" \
            --start-ip-address "0.0.0.0" \
            --end-ip-address "0.0.0.0" \
            --output none

else
    echo "Regra de firewall do MySQL já existe."
fi

echo ""
echo "=========================================="
echo "INFRAESTRUTURA BASE CRIADA COM SUCESSO"
echo "=========================================="

az resource list \
    --resource-group "$RESOURCE_GROUP" \
    --output table
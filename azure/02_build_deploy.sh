#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/00_config_geral.sh"

cd "$REPO_ROOT"

echo "=========================================="
echo "FIDELIS - BUILD E DEPLOY DO APP NO AZURE APP SERVICE"
echo "=========================================="

if [ ! -f "$REPO_ROOT/.env" ]; then
    echo "ERRO: arquivo .env não encontrado."
    echo "Crie o .env com MYSQL_PASSWORD=sua_senha."
    exit 1
fi

set -a
source "$REPO_ROOT/.env"
set +a

if [ -z "${MYSQL_PASSWORD:-}" ]; then
    echo "ERRO: MYSQL_PASSWORD não definida no .env."
    exit 1
fi

if ! az webapp show \
    --name "$WEBAPP_NAME" \
    --resource-group "$RESOURCE_GROUP" &>/dev/null; then

    echo "ERRO: Web App '$WEBAPP_NAME' não encontrado."
    echo "Execute primeiro: azure/01_criacao_infra.sh"
    exit 1
fi

if ! az mysql flexible-server show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$MYSQL_SERVER_NAME" &>/dev/null; then

    echo "ERRO: MySQL Flexible Server '$MYSQL_SERVER_NAME' não encontrado."
    echo "Execute primeiro: azure/01_criacao_infra.sh"
    exit 1
fi

PUBLISH_DIR="$REPO_ROOT/.publish/fidelis-api"
ZIP_PATH="$REPO_ROOT/.publish/fidelis-api.zip"

rm -rf "$PUBLISH_DIR" "$ZIP_PATH"
mkdir -p "$PUBLISH_DIR"

echo "Publicando a API do Fidelis..."

dotnet publish Fidelis.Api/Fidelis.Api.csproj \
    --configuration Release \
    --output "$PUBLISH_DIR" \
    --nologo

echo "Compactando a publicação..."

if command -v zip &>/dev/null; then

    cd "$PUBLISH_DIR"
    zip -r "$ZIP_PATH" .
    cd "$REPO_ROOT"

elif command -v powershell.exe &>/dev/null; then

    PUBLISH_DIR_WIN="$(cygpath -w "$PUBLISH_DIR")"
    ZIP_PATH_WIN="$(cygpath -w "$ZIP_PATH")"

    powershell.exe -NoProfile -Command "
        Add-Type -AssemblyName System.IO.Compression;
        Add-Type -AssemblyName System.IO.Compression.FileSystem;

        \$source = '$PUBLISH_DIR_WIN';
        \$destination = '$ZIP_PATH_WIN';

        if (Test-Path \$destination) {
            Remove-Item \$destination -Force
        }

        \$base = (Resolve-Path \$source).Path.TrimEnd('\') + '\';

        \$archive = [System.IO.Compression.ZipFile]::Open(
            \$destination,
            [System.IO.Compression.ZipArchiveMode]::Create
        );

        try {
            Get-ChildItem -Path \$source -Recurse -File | ForEach-Object {

                \$relative = \$_.FullName.Substring(\$base.Length);

                # IMPORTANTE:
                # converte separador Windows para padrão ZIP/Linux
                \$relative = \$relative.Replace('\', '/');

                \$entry = \$archive.CreateEntry(
                    \$relative,
                    [System.IO.Compression.CompressionLevel]::Optimal
                );

                \$entryStream = \$entry.Open();
                \$fileStream = [System.IO.File]::OpenRead(\$_.FullName);

                try {
                    \$fileStream.CopyTo(\$entryStream);
                }
                finally {
                    \$fileStream.Dispose();
                    \$entryStream.Dispose();
                }
            }
        }
        finally {
            \$archive.Dispose();
        }
    "

else
    echo "ERRO: nenhum compactador ZIP disponível."
    exit 1
fi

MYSQL_HOST="${MYSQL_SERVER_NAME}.mysql.database.azure.com"
CONNECTION_STRING="Server=${MYSQL_HOST};Port=3306;Database=${MYSQL_DATABASE};User ID=${MYSQL_ADMIN_LOGIN};Password=${MYSQL_PASSWORD};SslMode=Required;"

az webapp config appsettings set \
    --resource-group "$RESOURCE_GROUP" \
    --name "$WEBAPP_NAME" \
    --settings \
        ASPNETCORE_ENVIRONMENT="Production" \
        ConnectionStrings__FidelisMySql="$CONNECTION_STRING" \
    --output none

echo "Fazendo deploy do pacote no App Service..."
az webapp deploy \
    --resource-group "$RESOURCE_GROUP" \
    --name "$WEBAPP_NAME" \
    --src-path "$ZIP_PATH" \
    --type zip \
    --output none \
    --clean true \
    --track-status false

az webapp restart \
    --resource-group "$RESOURCE_GROUP" \
    --name "$WEBAPP_NAME" \
    --output none

# Aguarda a API ficar disponível
APP_HOST=$(az webapp show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$WEBAPP_NAME" \
    --query defaultHostName \
    --output tsv)

APP_URL="https://${APP_HOST}"
SWAGGER_URL="${APP_URL}/swagger/index.html"

echo ""
echo "Aguardando inicialização da API..."

MAX_ATTEMPTS=60
WAIT_SECONDS=10
ATTEMPT=1
HTTP_STATUS="000"

while (( ATTEMPT <= MAX_ATTEMPTS )); do

    HTTP_STATUS=$(curl \
        --location \
        --silent \
        --output /dev/null \
        --write-out "%{http_code}" \
        --connect-timeout 5 \
        --max-time 15 \
        "$SWAGGER_URL" || true)

    if [ "$HTTP_STATUS" = "200" ]; then
        echo "API disponível com sucesso."
        break
    fi

    echo "Aguardando API iniciar... ($ATTEMPT/$MAX_ATTEMPTS) - HTTP $HTTP_STATUS"

    sleep "$WAIT_SECONDS"
    ((ATTEMPT++))
done

if [ "$HTTP_STATUS" != "200" ]; then
    echo ""
    echo "ERRO: a API não ficou disponível dentro do tempo esperado."
    echo "Último status HTTP: $HTTP_STATUS"
    echo ""
    echo "Para verificar os logs:"
    echo "az webapp log startup show -g $RESOURCE_GROUP -n $WEBAPP_NAME"

    exit 1
fi

echo ""
echo "=========================================="
echo "DEPLOY DO APP SERVICE CONCLUÍDO"
echo "=========================================="
echo ""
echo "Swagger disponível em:"
echo "${APP_URL}/swagger"
echo ""
echo "Conexão MySQL configurada via ConnectionStrings__FidelisMySql"
#!/bin/bash

# =========================================================
# CONFIGURAÇÕES GERAIS - FIDELIS CHALLENGE APP SERVICE
# =========================================================

RM="rm564723"

RESOURCE_GROUP="rg-${RM}-fidelis-challenge"
LOCATION="southafricanorth"

# Azure App Service
APP_SERVICE_PLAN="${RM}-fidelis-plan"
WEBAPP_NAME="${RM}-fidelis-api"
APP_RUNTIME="DOTNETCORE|10.0"

# Azure Database for MySQL - Flexible Server
MYSQL_SERVER_NAME="${RM}-fidelis-mysql"
MYSQL_DATABASE="fidelis"
MYSQL_ADMIN_LOGIN="fidelis"
MYSQL_SKU="Standard_B1ms"

# Compatibilidade com o código da API
# A aplicação lê a connection string a partir de ConnectionStrings__FidelisMySql
# fornecida como variável de ambiente no App Service.
APP_DNS="${RM}-fidelis-api"
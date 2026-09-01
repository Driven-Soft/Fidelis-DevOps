# Fidelis

## Descrição da solução

O Fidelis é uma solução para clínicas veterinárias que centraliza o acompanhamento de pets em um único ambiente digital. A plataforma permite registrar e consultar informações de clínica, tutor, veterinário, pet, consultas, exames, vacinas, prescrições, lembretes, histórico de peso e recomendações.

A ideia da aplicação é melhorar o controle clínico, reduzir falhas operacionais e facilitar a gestão do cuidado do animal, com foco em acompanhamento contínuo e organização da rotina veterinária.

## Benefícios para o negócio

- centralização da ficha clínica do pet
- melhor organização de consultas, vacinas e prescrições
- acompanhamento de histórico de peso e comportamento
- redução de esquecimentos de tratamentos e lembretes
- apoio ao relacionamento entre clínica, veterinário e tutor
- maior rastreabilidade das informações de saúde do animal

## Arquitetura atual

A solução foi implementada com a opção correta do desafio: App Service + banco em nuvem (PaaS), sem misturar com ACR/ACI.

### Componentes principais

- Azure App Service: hospeda a API .NET
- App Service Plan: define o plano de capacidade do App Service
- Azure Database for MySQL Flexible Server: banco relacional gerenciado
- Azure CLI + scripts Bash: provisiona e automatiza a infraestrutura
- Docker Compose: ambiente local para testes e execução de desenvolvimento

### Fluxo da arquitetura

1. O script de infraestrutura cria o Resource Group, App Service Plan, Web App e MySQL Flex Server.
2. A API é publicada e enviada ao App Service.
3. A aplicação recebe a connection string como App Setting.
4. O Web App acessa o MySQL gerenciado e expõe a API pelo Swagger.

## Requisitos atendidos

- banco em nuvem obrigatório atendido
- API em App Service atendido
- infraestrutura criada via Azure CLI atendido
- DDL em arquivo separado atendido em [db/script_db.sql](db/script_db.sql)
- documentação de execução no README atendido

## Pré-requisitos

- Azure CLI instalado e autenticado
- conta Azure com permissão para criar Resource Group, App Service e MySQL Flexible Server
- .NET SDK compatível com o projeto
- Docker e Docker Compose para execução local
- Git, Bash ou WSL

## Configuração local

### 1. Clonar e entrar no projeto

```bash
git clone <url-do-repositorio>
cd Fidelis-DevOps
```

### 2. Criar o arquivo .env

```bash
cp .env.example .env
```

Edite o arquivo `.env` com a senha do banco:

```dotenv
MYSQL_PASSWORD=sua_senha
```

### 3. Permissões dos scripts

```bash
chmod +x azure/*.sh
```

## Implantação na Azure

### 1. Criar infraestrutura

```bash
bash azure/01_criacao_infra.sh
```

Esse script cria ou reutiliza:

- Resource Group
- App Service Plan
- Web App
- MySQL Flexible Server
- banco `fidelis`
- regra de firewall `AllowAzureServices`

### 2. Publicar e implantar a API

```bash
bash azure/02_push_imagens.sh
```

Esse script:

- publica a API com `dotnet publish`
- compacta a publicação em ZIP
- faz deploy no App Service
- define o App Setting `ConnectionStrings__FidelisMySql`
- reinicia a aplicação

### 3. Validar a infraestrutura do banco

```bash
bash azure/03_deploy_database.sh
```

Esse script serve como validação do MySQL gerenciado e da regra de firewall. Ele verifica se o banco e os acessos estão consistentes.

### 4. Remover a infraestrutura

```bash
bash azure/05_remocao.sh
```

## Como acessar a aplicação

Depois do deploy, o Swagger fica em:

```text
https://<nome-do-webapp>.azurewebsites.net/swagger
```

Para localizar o host do App Service:

```bash
az webapp show \
  --resource-group rg-rm564723-fidelis-challenge \
  --name rm564723-fidelis-api \
  --query defaultHostName \
  --output tsv
```

## Execução local com Docker Compose

```bash
docker compose build
docker compose up -d
docker compose ps
```

Swagger local:

```text
http://localhost:8080/swagger
```

Para encerrar:

```bash
docker compose down
```

## DDL do banco

A estrutura do banco está no arquivo [db/script_db.sql](db/script_db.sql).

Esse arquivo foi simplificado para manter apenas os objetos principais do core da solução, atendendo ao requisito do desafio sem incluir estruturas desnecessárias.

## Estrutura de scripts Azure

- [azure/00_config_geral.sh](azure/00_config_geral.sh): nomes e variáveis globais
- [azure/01_criacao_infra.sh](azure/01_criacao_infra.sh): provisiona infra Azure
- [azure/02_push_imagens.sh](azure/02_push_imagens.sh): publica e deploya a API no App Service
- [azure/03_deploy_database.sh](azure/03_deploy_database.sh): validação do MySQL gerenciado
- [azure/05_remocao.sh](azure/05_remocao.sh): remoção do ambiente

## Observações finais

- a solução foi ajustada para a opção correta do challenge: App Service + banco PaaS
- o banco não fica em container na infraestrutura Azure
- a API não é executada em container pela Azure na entrega final
- a arquitetura evita os problemas de compatibilidade de armazenamento/volume que ocorriam com Azure Files em ACI

## Equipe

- Henrique Cunha Torres, RM: 565119
- Max Hayashi Batista, RM: 563717
- Felipe Bezerra Beatriz, RM: 564723

# Fidelis

## Descrição do Projeto

O Fidelis é uma solução desenvolvida para auxiliar clínicas veterinárias no acompanhamento contínuo da saúde de animais de estimação, permitindo o gerenciamento de informações clínicas, consultas, vacinas, tratamentos e lembretes preventivos.

A plataforma busca melhorar a comunicação entre clínica e tutor, promovendo maior fidelização dos clientes e contribuindo para a prevenção de problemas de saúde através do acompanhamento periódico dos pets.

O projeto foi desenvolvido como parte do Challenge FIAP, integrando conceitos de desenvolvimento back-end, banco de dados, arquitetura em nuvem e DevOps.

## Benefícios para o Negócio

- Fidelização de clientes através do acompanhamento contínuo dos pets
- Redução do abandono de tratamentos e consultas preventivas
- Centralização das informações clínicas dos animais
- Melhor organização do histórico veterinário
- Automatização de lembretes de vacinação e consultas
- Maior eficiência operacional para clínicas veterinárias
- Possibilidade de expansão futura para notificações e dashboards analíticos

## Arquitetura da Solução

A solução utiliza serviços gerenciados de containers da Microsoft Azure. As imagens da API e do MySQL são armazenadas no Azure Container Registry (ACR) e executadas no Azure Container Instances (ACI), sem necessidade de uma Máquina Virtual para hospedar o Docker.

O MySQL utiliza um Azure File Share montado no ACI em `/var/lib/mysql`, garantindo persistência dos dados quando a instância do container é recriada. As credenciais são fornecidas por variáveis de ambiente e não ficam armazenadas nos scripts versionados.

## Como Executar o Projeto (How To)

### Pré-requisitos

- Docker instalado e em execução
- Azure CLI instalada
- Conta Azure autenticada e com permissão para criar ACR, Storage Account e ACI
- Git e Bash, por exemplo Git Bash ou WSL

### 1. Preparar o projeto

```bash
git clone https://github.com/Driven-Soft/Fidelis-DevOps.git
cd Fidelis-DevOps
az login
cp .env.example .env
```

Edite `.env` e informe a senha do MySQL:

```dotenv
MYSQL_PASSWORD=sua_senha
```

O `.env` é ignorado pelo Git. Não publique esse arquivo.

No Linux, Git Bash ou WSL, conceda permissão aos scripts:

```bash
chmod +x azure/*.sh
```

### 2. Criar a infraestrutura base

```bash
bash azure/01_criacao_infra.sh
```

O script cria ou reutiliza o Resource Group, o ACR, o Storage Account e o Azure File Share usado para persistir o MySQL.

### 3. Construir e publicar as imagens

```bash
bash azure/02_push_imagens.sh
```

As imagens da API e do MySQL são construídas pelos Dockerfiles em [docker/app/Dockerfile](docker/app/Dockerfile) e [docker/database/Dockerfile](docker/database/Dockerfile), depois são enviadas ao ACR.

### 4. Criar o ACI do MySQL

```bash
bash azure/03_deploy_database.sh
```

O MySQL é executado no ACI com DNS público e Azure File Share montado em `/var/lib/mysql`. Para consultar o estado e o FQDN:

```bash
az container show \
  --resource-group rg-rm564723-fidelis-challenge \
  --name rm564723-fidelis-mysql \
  --query "{Status:instanceView.state,IP:ipAddress.ip,FQDN:ipAddress.fqdn}" \
  --output table
```

Logs do MySQL:

```bash
az container logs --resource-group rg-rm564723-fidelis-challenge --name rm564723-fidelis-mysql
```

### 5. Criar o ACI da API

```bash
bash azure/04_deploy_api.sh
```

O script recupera o FQDN do MySQL e injeta a connection string como variável segura. Para obter o FQDN da API:

```bash
az container show \
  --resource-group rg-rm564723-fidelis-challenge \
  --name rm564723-fidelis-api \
  --query ipAddress.fqdn \
  --output tsv
```

Acesse no navegador:

```text
http://FQDN_DA_API:8080/swagger
```

Logs da API:

```bash
az container logs --resource-group rg-rm564723-fidelis-challenge --name rm564723-fidelis-api
```

### 6. Executar localmente com Docker Compose

Com o `.env` na raiz do projeto:

```bash
docker compose build
docker compose up -d
docker compose ps
```

Swagger local: `http://localhost:8080/swagger`.

Para parar os containers locais:

```bash
docker compose down
```

### 7. Remover a infraestrutura Azure

```bash
bash azure/05_remocao.sh
```

Esse script remove o Resource Group e todos os recursos associados. A exclusão é iniciada de forma assíncrona por causa do parâmetro `--no-wait`.

## Infraestrutura Azure

Os scripts em [azure](azure) automatizam o provisionamento e o deploy:

- `00_config_geral.sh`: nomes, região, imagens e DNS
- `01_criacao_infra.sh`: Resource Group, ACR, Storage Account e Azure File Share
- `02_push_imagens.sh`: build e push das imagens para o ACR
- `03_deploy_database.sh`: deploy do MySQL no ACI
- `04_deploy_api.sh`: deploy da API no ACI
- `05_remocao.sh`: remoção do Resource Group

O ambiente Azure é composto por um ACR para armazenar as imagens, dois ACIs para executar API e MySQL e um Azure File Share para persistência do banco.

## Docker

Docker e Docker Compose são utilizados para execução local e para construir as imagens publicadas no ACR. Os arquivos principais são [docker-compose.yml](docker-compose.yml), [docker/app/Dockerfile](docker/app/Dockerfile) e [docker/database/Dockerfile](docker/database/Dockerfile).

Os containers locais são a API Fidelis e o banco MySQL.

## Equipe
Henrique Cunha Torres, RM: 565119

Max Hayashi Batista, RM: 563717

Felipe Bezerra Beatriz, RM: 564723

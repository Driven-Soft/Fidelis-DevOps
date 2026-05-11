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

A solução foi arquitetada utilizando infraestrutura em nuvem na Microsoft Azure, com conteinerização via Docker.

Fluxo macro da arquitetura:

Usuário → API Fidelis → Banco H2 → Containers Docker → VM Linux Azure

O desenho detalhado da arquitetura será disponibilizado na pasta `/docs`.

## Tecnologias Utilizadas

- Java / Spring Boot
- Banco de Dados H2
- Docker
- Docker Compose
- Microsoft Azure
- Azure CLI
- GitHub
- Linux Ubuntu Server

## Rotas da API

### Pets

| Método | Rota | Descrição |
|---|---|---|
| GET | /pets | Lista todos os pets |
| GET | /pets/{id} | Busca pet por ID |
| POST | /pets | Cadastra novo pet |
| PUT | /pets/{id} | Atualiza pet |
| DELETE | /pets/{id} | Remove pet |

### Consultas

| Método | Rota | Descrição |
|---|---|---|
| GET | /consultas | Lista consultas |
| POST | /consultas | Agenda consulta |

## Como Executar o Projeto (How To)

### Pré-requisitos

Antes de iniciar, é necessário possuir:

- Docker instalado
- Docker Compose instalado
- Azure CLI instalada
- Conta Microsoft Azure ativa
- Git instalado

---

### 1. Clonar o repositório

```bash
git clone https://github.com/Driven-Soft/Fidelis-DevOps.git
```

---

### 2. Acessar a pasta do projeto

```bash
cd Fidelis-DevOps
```

---

### 3. Realizar login na Azure

```bash
az login
```

---

### 4. Conceder permissão de execução aos scripts

```bash
chmod +x azure/criacao.sh
chmod +x azure/remocao.sh
```

---

### 5. Executar criação da infraestrutura na Azure

```bash
./azure/criacao.sh
```

Esse script realiza:
- Criação do Resource Group
- Criação da VNet e Subnet
- Criação do NSG e regras de firewall
- Provisionamento da Máquina Virtual Linux
- Instalação do Docker
- Instalação do Git e Nano

---

### 6. Obter IP público da Máquina Virtual

```bash
az vm show \
  --resource-group rg-fidelis \
  --name vm-fidelis \
  -d \
  --query publicIps \
  -o tsv
```

---

### 7. Acessar a VM via SSH

```bash
ssh azureuser@IP_DA_VM
```

Exemplo:

```bash
ssh azureuser@20.xxx.xxx.xxx
```

Are you sure you want to continue connecting (yes/no/[fingerprint])?
```
yes
```

Senha padrão definida no script:

```text
Fidelis@2026
```

---

### 8. Executar a aplicação com Docker

```bash
docker compose up -d
```

---

### 9. Remover infraestrutura da Azure

```bash
./azure/remocao.sh
```

Esse script remove todos os recursos criados na Azure.

---

## Infraestrutura Azure

A infraestrutura do projeto Fidelis foi provisionada utilizando Microsoft Azure através de scripts automatizados com Azure CLI.

Os scripts realizam automaticamente:

- Criação do Resource Group
- Criação da Virtual Network (VNet)
- Criação da Subnet
- Configuração do Network Security Group (NSG)
- Liberação das portas necessárias
- Provisionamento de Máquina Virtual Linux Ubuntu
- Instalação automática do Docker
- Instalação do Git e Nano

Estrutura criada:
- VM Ubuntu Server
- Containers Docker
- Banco H2 conteinerizado
- API Fidelis conteinerizada

Scripts disponíveis:
- azure/criacao.sh
- azure/remocao.sh

## Docker

A aplicação Fidelis utiliza conteinerização com Docker para facilitar a execução da API e do banco de dados em ambientes isolados e reproduzíveis.

Os containers são orquestrados utilizando Docker Compose.

Arquivos utilizados:
- Dockerfile
- docker-compose.yml

Principais comandos:

```bash
docker compose build
docker compose up -d
docker ps
```

Os containers executados incluem:
- API Fidelis
- Banco de Dados H2

## Equipe
Henrique Cunha Torres, RM: 565119

Max Hayashi Batista, RM: 563717

Felipe Bezerra Beatriz, RM: 564723

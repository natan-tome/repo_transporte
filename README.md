<br>
<br>

# 🚀 Projeto Checkpoint 02 – Pipeline de Infraestrutura e Ingestão de Dados

<br>

## 📖 Sumário

- [Descrição do Projeto e Solução](#descrição-do-projeto-e-solução)
- [Arquitetura Geral e Fluxo de Dados](#arquitetura-geral-e-fluxo-de-dados)
- [Estrutura do Repositório](#estrutura-do-repositório)
- [Fontes de Dados, Formatos e Schemas](#fontes-de-dados-formatos-e-schemas)
- [Tecnologias, Ferramentas e Dependências](#tecnologias-ferramentas-e-dependências)
    - [Por Container/Ferramenta](#por-containerferramenta)
- [Configuração do Ambiente de Desenvolvimento](#configuração-do-ambiente-de-desenvolvimento)
- [Passo a Passo de Execução (Guia do Usuário)](#passo-a-passo-de-execução-guia-do-usuário)
- [Manual de Uso do Makefile](#manual-de-uso-do-makefile)
- [Métodos de Acesso e Autenticação](#métodos-de-acesso-e-autenticação)
- [Estratégia de Extração e Mapeamento dos Dados](#estratégia-de-extração-e-mapeamento-dos-dados)
- [Decisões Técnicas e Justificativas](#decisões-técnicas-e-justificativas)
- [Escalabilidade, Otimização, Modularidade e Reusabilidade](#escalabilidade-otimização-modularidade-e-reusabilidade)
- [Descrição dos Recursos de Infraestrutura](#descrição-dos-recursos-de-infraestrutura)

<br>

## 📋 Descrição do Projeto e Solução

Este projeto entrega um pipeline de dados robusto, modular e escalável, capaz de extrair dados de um banco relacional SQL Server e de uma API REST, transformar e carregar estes dados no Databricks Delta Lake, utilizando boas práticas de engenharia de dados, conteinerização e versionamento seguro. Toda a orquestração é realizada via Makefile, garantindo reprodutibilidade e facilidade operacional.

<br>

## 🏗️ Arquitetura Geral e Fluxo de Dados

1. **Extração SQL Server (Embulk):** Dados extraídos do banco relacional e convertidos em Parquet.
2. **Extração API (Meltano):** Dados extraídos da API REST e salvos em JSONL.
3. **Ingestão Databricks:** Arquivos Parquet e JSONL são enviados para volumes no Databricks.
4. **Provisionamento Infraestrutura (Terraform):** Criação de volumes, schemas e notebooks no Databricks.
5. **Processamento Delta (Notebook):** Conversão dos arquivos para tabelas Delta Lake.
6. **Orquestração:** Todo o fluxo é automatizado via Makefile e Docker Compose.

<br>

## 📂 Estrutura do Repositório
```bash
.
├── ap_extracao_embulk/ # 🏭 Pipeline Embulk (SQL Server → Parquet)
│ ├── config/
│ │ ├── template.yml
│ │ └── extracao_tabelas.yml
│ ├── scripts/
│ │ └── criacao_yml.sh
│ ├── entrypoint.sh
│ └── Dockerfile
├── ap_extracao_meltano/ # 🌐 Pipeline Meltano (API → JSONL)
│ ├── meltano.yml
│ ├── plugins/
│ │ └── custom/tap-aw-api/
│ │ ├── tap.py, client.py, streams.py, ...
│ ├── entrypoint.sh
│ └── Dockerfile
├── ap_infra_pipeline/ # 🏗️ Infraestrutura Databricks (Terraform)
│ ├── main.tf, variables.tf, ...
│ ├── notebooks/
│ │ └── create_delta_tables.py
│ ├── entrypoint.sh
│ ├── destroy.sh
│ └── Dockerfile
├── ap_ingestao_databricks/ # ⬆️ Upload de arquivos para Databricks
│ ├── entrypoint.sh
│ └── Dockerfile
├── ap_processamento_job/ # ⚡ Execução de jobs Databricks
│ ├── entrypoint.sh
│ ├── destroy.sh
│ └── Dockerfile
├── docker-compose.yml # 🐳 Orquestração dos containers
├── Makefile # 🛠️ Orquestração dos comandos do pipeline
├── .env # 🔒 Variáveis de ambiente (Template para preenchimento)
└── README.md # 📖 Este arquivo
```

<br>

## 🗄️ Fontes de Dados, Formatos e Schemas

- **Banco Relacional (SQL Server):**  
  - Tabelas: [Ver lista completa em `extracao_tabelas.yml`][1]
  - Formato de saída: Parquet
- **API REST (AdventureWorks):**  
  - Endpoints: PurchaseOrderDetail, PurchaseOrderHeader, SalesOrderDetail, SalesOrderHeader
  - Formato de saída: JSONL
- **Schema dos Dados:**  
  - Definido nos arquivos JSON de schema e YAML do projeto.
  - Mapeamento automático via Embulk e Meltano.

<br>

## 🛠️ Tecnologias, Ferramentas e Dependências

### Por Container/Ferramenta

#### **1. Embulk (ap_extracao_embulk)**
- **Tecnologia:** Embulk
- **Dependências:** JDK, JRuby, Parquet plugin, yq
- **Bibliotecas:** embulk-input-sqlserver, embulk-output-parquet
- **Descrição:** Ferramenta robusta para extração de dados de SQL Server e conversão para Parquet. Utiliza templates YAML para geração dinâmica dos jobs de extração.  
- **Benefícios:** Alta performance, fácil integração, automação de jobs via shell script.

#### **2. Meltano (ap_extracao_meltano)**
- **Tecnologia:** Meltano, Singer SDK, Python 3.10
- **Dependências:** Python, pip, Singer SDK, requests
- **Bibliotecas:** tap-aw-api (custom), target-jsonl
- **Descrição:** Plataforma de ELT moderna, utilizada para extrair dados de APIs REST e salvar em JSONL. Tap customizado para AdventureWorks API.
- **Benefícios:** Modularidade, extensibilidade, fácil integração com pipelines modernos.

#### **3. Infraestrutura Databricks (ap_infra_pipeline)**
- **Tecnologia:** Terraform, Databricks CLI, Python 3
- **Dependências:** terraform, python3, pip, databricks-cli, requests
- **Bibliotecas:** databricks-cli, requests
- **Descrição:** Provisionamento de volumes, schemas, notebooks e jobs no Databricks via código declarativo.
- **Benefícios:** Infraestrutura como código, reprodutibilidade, versionamento seguro.

#### **4. Ingestão Databricks (ap_ingestao_databricks)**
- **Tecnologia:** Databricks CLI, Bash
- **Dependências:** databricks-cli, jq, bash
- **Descrição:** Upload automatizado dos arquivos Parquet e JSONL para os volumes do Databricks.
- **Benefícios:** Automação, integração transparente com o pipeline.

#### **5. Processamento Job (ap_processamento_job)**
- **Tecnologia:** Databricks CLI, Bash
- **Dependências:** databricks-cli, bash
- **Descrição:** Execução de jobs Databricks que convertem arquivos Parquet/JSONL em tabelas Delta.
- **Benefícios:** Orquestração automatizada, integração com variáveis de ambiente.

<br>

## ⚙️ Configuração do Ambiente de Desenvolvimento

1. **Clone o repositório:**

git clone <URL_DO_SEU_REPOSITORIO>
cd <nome_do_repositorio>


2. **Configure o arquivo `.env`:**
- Preencha todas as variáveis do template `.env` com suas credenciais e informações de ambiente.
- **Nunca** commite o arquivo `.env` preenchido.

3. **Instale o Docker e Docker Compose** (caso ainda não tenha):
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

<br>

## 🧑‍💻 Passo a Passo de Execução (Guia do Usuário)

1. **Edite o arquivo `.env` com suas credenciais:**
- Insira dados de acesso ao SQL Server, API, Databricks e demais variáveis obrigatórias.
- Exemplo de variáveis:
  ```
  SQLSERVER_HOST=
  SQLSERVER_PORT=
  SQLSERVER_USER=
  SQLSERVER_PASSWORD=
  SQLSERVER_DB=
  API_USERNAME=
  API_PASSWORD=
  API_URL=
  API_START_DATE=
  DATABRICKS_HOST=
  DATABRICKS_TOKEN=
  CATALOG_NAME=
  SCHEMA_NAME=
  EMAIL=
  ```

2. **Suba os containers e execute o pipeline completo:**

make all


3. **Manual de uso do Makefile:**

| Comando            | Descrição                                                                 |
|--------------------|---------------------------------------------------------------------------|
| `make init`        | 🐳 Inicializa todos os containers (build/rebuild)                          |
| `make extract_api` | 🌐 Executa extração de dados via API (Meltano)                             |
| `make extract_db`  | 🏭 Executa extração de dados do banco relacional via Embulk                |
| `make provision_infra` | 🏗️ Provisiona recursos no Databricks via Terraform                   |
| `make load_databricks` | ⬆️ Carrega arquivos para o Databricks                                 |
| `make run_job`     | ⚡ Executa o job Databricks para criar tabelas Delta                       |
| `make destroy_infra` | 💣 Destroi infraestrutura provisionada no Databricks                    |
| `make destroy_job` | 💥 Destroi o job programado no Databricks                                  |
| `make destroy_all` | 🧹 Atalho para destruir infraestrutura e job no Databricks                 |
| `make clean`       | 🗑️ Remove containers, volumes e redes órfãs                               |

4. **Para executar etapas específicas:**

make extract_db  | 
make provision_infra  | 
make load_databricks  | 
make run_job


<br>

## 🔒 Métodos de Acesso e Autenticação

- **Banco de Dados:** Autenticação via usuário/senha definidos no `.env`.
- **API:** Autenticação básica HTTP (usuário/senha do `.env`).
- **Databricks:** Autenticação via token pessoal (`DATABRICKS_TOKEN`), nunca exposto no repositório.
- **Variáveis de ambiente:** Carregadas dinamicamente por cada container, nunca versionadas.

<br>

## 🗺️ Estratégia para Extração e Mapeamento dos Dados

- **SQL Server → Parquet:** Extração via Embulk, jobs YAML dinâmicos, schemas automatizados.
- **API → JSONL:** Extração via Meltano, tap customizado, schemas JSON centralizados.
- **Parquet/JSONL → Databricks:** Upload automatizado para volumes.
- **Volumes → Delta Lake:** Conversão via notebook Python parametrizado, execução automatizada por job Databricks.

<br>

## 🧠 Decisões Técnicas e Justificativas

- **Conteinerização:** Garantia de ambiente isolado, reprodutível e fácil de distribuir.
- **Infraestrutura como Código (Terraform):** Provisionamento seguro, versionado e auditável.
- **Makefile:** Orquestração simples, transparente e padronizada.
- **Separação por módulos:** Cada etapa do pipeline em seu próprio container/ferramenta.
- **Uso de Parquet/JSONL:** Formatos eficientes e compatíveis com o Databricks.
- **Segurança:** Variáveis sensíveis nunca são versionadas.

<br>

## 📈 Escalabilidade, Otimização, Modularidade e Reusabilidade

- **Escalabilidade:** Pipeline projetado para suportar aumento de volume de dados e novas fontes.
- **Otimização:** Uso de formatos colunares, paralelismo nas extrações, jobs idempotentes.
- **Modularidade:** Cada etapa isolada, facilitando manutenção e evolução.
- **Reusabilidade:** Ferramentas e scripts podem ser reaproveitados em outros projetos.

<br>

## ☁️ Descrição dos Recursos de Infraestrutura

- **Containers Docker:** Cada etapa do pipeline roda em seu próprio container.
- **Volumes Docker:** Compartilhamento eficiente de dados intermediários.
- **Databricks:** Armazenamento final dos dados, processamento Delta Lake, notebooks automatizados.
- **Terraform:** Gerenciamento de recursos Databricks (volumes, schemas, jobs).

<br>

## 📝 Considerações Finais

- **Pipeline seguro, modular, escalável e eficiente.**
- **Documentação clara e detalhada para facilitar onboarding e manutenção.**
- **Pronto para demonstração ao vivo e futuras evoluções.**

<br>

> **Atenção:**  
> - Nunca compartilhe o arquivo `.env` preenchido publicamente.  
> - Sempre valide as variáveis antes de executar o pipeline.
> - Consulte a documentação inline dos scripts e notebooks para detalhes de uso e troubleshooting.

---
<br>


## **Boa utilização e boas análises!** 🚀

<br>



*[1]: extracao_tabelas.yml
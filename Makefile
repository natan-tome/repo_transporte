# 📦 Makefile para orquestração do pipeline completo Databricks
.PHONY: all init extract_api extract_db provision_infra \
        load_databricks run_job \
        destroy_infra destroy_job destroy_all \
        clean

# 🚀 Inicializa todos os containers com rebuild forçado
init:
	docker compose up -d --build

# 🔗 Executa a pipeline ponta-a-ponta (ordem recomendada)
all: init extract_api extract_db provision_infra load_databricks run_job

# 🌐 Executa extração de dados via API (Meltano)
extract_api:
	docker exec -it ap_extracao_meltano sh ./entrypoint.sh

# 🏭 Executa extração de dados do banco relacional via Embulk
extract_db:
	docker exec -it ap_extracao_embulk sh ./entrypoint.sh

# 🏗️ Provisiona recursos no Databricks via Terraform
provision_infra:
	docker exec -it ap_infra_pipeline sh ./entrypoint.sh

# ⬆️ Carrega arquivos JSONL e Parquet para o Databricks
load_databricks:
	docker exec -it ap_ingestao_databricks sh ./entrypoint.sh

# ⚡ Executa job Databricks que cria tabelas Delta
run_job:
	docker exec -it ap_processamento_job sh ./entrypoint.sh

# 💣 Destroi infraestrutura provisionada no Databricks
destroy_infra:
	docker exec -it ap_infra_pipeline sh scripts/destroy.sh

# 💥 Destroi o job programado no Databricks
destroy_job:
	docker exec -it ap_processamento_job sh scripts/destroy.sh

# 🧹 Atalho para destruir infraestrutura e job no Databricks
destroy_all: destroy_infra destroy_job

# 🗑️ Remove containers, volumes e redes órfãs
clean:
	docker compose down --volumes --remove-orphans


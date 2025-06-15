# 🌐 Configuração do provedor Databricks (versão fixa para evitar quebras)
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"  # 🔌 Provedor oficial
      version = "1.82.0"  # 🚨 Versão estável testada
    }
  }
}

# 🔐 Configuração de autenticação no workspace
provider "databricks" {
  host  = var.databricks_host  # 🌍 URL do workspace (ex: https://dbc-123456.cloud.databricks.com)
  token = var.databricks_token  # 🔒 Token de acesso pessoal (sensível)
}

# 🚀 Job para execução do notebook de transformação
resource "databricks_job" "run_create_delta_tables" {
  name = "Run Create Delta Tables (Serverless)"  # 🏷️ Nome claro do job

  task {
    task_key = "run_delta_notebook"
    notebook_task {
      notebook_path = var.notebook_path  # 📓 Caminho do notebook no workspace
    }
  }

  description = "Executa notebook para criar tabelas Delta a partir de arquivos JSONL e Parquet no volume"  # 📝 Descrição técnica
  tags = {
    environment = "dev"  # 🏷️ Ambiente de execução
    owner       = var.owner  # 👤 Responsável pelo job
  }
}

# 📋 Output com ID do job para referência em pipelines
output "job_id" {
  value = databricks_job.run_create_delta_tables.id  # 🆔 Identificador único do job
}

# 🌐 Configuração do provedor Databricks (conexão com workspace)
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"  # 🔌 Provedor oficial
      version = "1.82.0"  # 🚨 Versão fixa para evitar breaking changes
    }
  }
}

# 🔐 Configuração de autenticação
provider "databricks" {
  host  = var.databricks_host  # 🌍 URL do workspace (ex: https://dbc-123456.cloud.databricks.com)
  token = var.databricks_token  # 🔒 Token de acesso pessoal (sensível)
}

# 👤 Recupera informações do usuário autenticado
data "databricks_current_user" "me" {}

# 📦 Cria volume gerenciado para dados brutos
resource "databricks_volume" "raw" {
  name         = "raw"  # 🏷️ Nome lógico do volume
  catalog_name = var.catalog_name  # 🗃️ Catálogo Unity Catalog
  schema_name  = var.schema_name  # 📑 Schema alvo
  volume_type  = "MANAGED"  # 🔄 Tipo gerenciado (Databricks controla storage)
  comment      = "Volume para ingestão bruta de dados (.parquet e .jsonl)"  # 📝 Descrição técnica
}

# 📓 Notebook de transformação (Parquet/JSONL → Delta)
resource "databricks_notebook" "create_delta" {
  path     = "/Workspace/Users/${var.email}/create_delta_tables"  # 🏠 Path personalizado por email
  language = "PYTHON"  # 🐍 Linguagem principal do notebook
  source   = "${path.module}/notebooks/create_delta_tables.py"  # 💾 Caminho local do arquivo (montado no container)
}

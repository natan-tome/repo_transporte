terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.82.0"
    }
  }
}

provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}

data "databricks_current_user" "me" {}

resource "databricks_volume" "raw" {
  name         = "raw"
  catalog_name = var.catalog_name
  schema_name  = var.schema_name
  volume_type  = "MANAGED"
  comment      = "Volume para ingestão bruta de dados (.parquet e .jsonl)"
}

resource "databricks_notebook" "create_delta" {
  path     = "/Users/${data.databricks_current_user.me.user_name}/create_delta_tables"
  language = "PYTHON"
  source   = "${path.module}/notebooks/create_delta_tables.py"  # ✅ Caminho correto
}


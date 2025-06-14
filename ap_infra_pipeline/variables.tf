# 🌐 Variáveis de conexão com o workspace Databricks
variable "databricks_host" {
  type        = string
  description = "URL completa do workspace (ex: https://dbc-123456.cloud.databricks.com)"
}

variable "databricks_token" {
  type        = string
  description = "Token de acesso pessoal gerado no User Settings"
  sensitive   = true  # 🚨 Valor sensível (não aparece em logs)
}

# 🗃️ Configurações do Unity Catalog
variable "catalog_name" {
  type        = string
  description = "Nome do catálogo onde os recursos serão criados"
}

variable "schema_name" {
  type        = string
  description = "Schema padrão para organização dos dados"
}

# 📦 Variável para caminho completo do volume (usada no Terraform)
variable "volume_path" {
  type        = string
  description = "Caminho completo do volume no DBFS (ex: /Volumes/catalog/schema/raw)"
}

# 📓 Configurações do Notebook
variable "notebook_path" {
  type        = string
  description = "Caminho completo do notebook no workspace do usuário"
}

variable "email" {
  type        = string
  description = "Email do usuário para construção do path do notebook"
}


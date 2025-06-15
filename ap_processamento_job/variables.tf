# 🌐 Variáveis de conexão com o workspace Databricks
variable "databricks_host" {
  type        = string
  description = "URL completa do workspace (ex: https://dbc-123456.cloud.databricks.com)"  # 🌍
}

variable "databricks_token" {
  type        = string
  description = "Token de acesso pessoal gerado no User Settings"  # 🔒
  sensitive   = true
}

# 🗃️ Configurações do Unity Catalog
variable "catalog_name" {
  type        = string
  description = "Nome do catálogo onde os recursos serão criados"  # 🏷️
}

variable "schema_name" {
  type        = string
  description = "Schema padrão para organização dos dados"  # 📜
}

variable "volume_path" {
  type        = string
  description = "Caminho completo do volume de dados brutos (ex: /Volumes/catalog/schema/raw)"  # 📦
}

# 👤 Configurações de usuário e execução
variable "owner" {
  type        = string
  description = "Responsável pela execução (auto-detectado via variável de ambiente USER)"  # 🕵️♂️
  default     = ""
}

variable "email" {
  type        = string
  description = "E-mail do usuário para construção do path do notebook"  # 📧
}

variable "notebook_path" {
  type        = string
  description = "Caminho do notebook de transformação no workspace"  # 📓
  default     = "/Shared/create_delta_tables"  # 🤝 Path compartilhado padrão
}

# 🌐 Configuração da URL do workspace Databricks (ex: https://123456.cloud.databricks.com)
variable "databricks_host" {
  type        = string
  description = "URL completa do workspace do Databricks"
}

# 🔒 Token de acesso pessoal (gerado em User Settings -> Access Tokens)
variable "databricks_token" {
  type        = string
  description = "Token de API com permissões de workspace e catalog"
  sensitive   = true  # 🚨 Valor sensível (não é exibido nos logs)
}

# 📚 Nome do catálogo Unity Catalog (onde os recursos serão criados)
variable "catalog_name" {
  type        = string
  description = "Catálogo principal para organização dos recursos"
}

# 📜 Schema padrão dentro do catálogo (estrutura lógica para tabelas/volumes)
variable "schema_name" {
  type        = string
  description = "Schema padrão para armazenamento de dados brutos"
}

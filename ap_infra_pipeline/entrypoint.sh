#!/bin/bash
set -euo pipefail  # 🛡️ Modo seguro: erro, vars não definidas e pipefail

echo "🚀 [ENTRYPOINT] Iniciando container do pipeline de infra..."

# ⚠️ Validação crítica das variáveis essenciais (já injetadas via Docker env_file)
required_vars=(
  DATABRICKS_HOST
  DATABRICKS_TOKEN
  CATALOG_NAME
  SCHEMA_NAME
)

for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "❌ [ERRO CRÍTICO] Variável $var não definida no ambiente"
    exit 1
  fi
done

# 🏗️ Inicialização do Terraform (configuração básica)
echo "⚙️ Inicializando Terraform..."
terraform init

# 🛠️ Aplicação da infraestrutura com variáveis do ambiente
echo "🔄 Aplicando configuração de infra..."
terraform apply -auto-approve

echo "✅ [SUCESSO] Infraestrutura provisionada com sucesso!"


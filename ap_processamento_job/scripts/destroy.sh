#!/bin/sh
set -e  # 🛡️ Interrompe a execução em caso de erro

echo "========================================"
echo "🚀 [INFO] Iniciando destruição de recursos do job Delta via Terraform..."
echo "========================================"

# 🔄 Carrega variáveis do .env (se montado via Docker)
if [ -f "/env/.env" ]; then
  echo "🔧 [INFO] Carregando variáveis de ambiente do /env/.env..."
  export $(grep -v '^#' ./.env | xargs)
fi

# 📦 Construção dinâmica do caminho do volume (caso não definido)
if [ -z "${VOLUME_PATH:-}" ]; then
  export VOLUME_PATH="/Volumes/${CATALOG_NAME}/${SCHEMA_NAME}/raw"
  echo "📦 [INFO] VOLUME_PATH construído dinamicamente: $VOLUME_PATH"
fi

# 🌐 Exporta variáveis para o Terraform
export TF_VAR_databricks_host="$DATABRICKS_HOST"
export TF_VAR_databricks_token="$DATABRICKS_TOKEN"
export TF_VAR_catalog_name="$CATALOG_NAME"
export TF_VAR_email="$EMAIL"
export TF_VAR_schema_name="$SCHEMA_NAME"
export TF_VAR_volume_path="$VOLUME_PATH"

# 🏗️ Execução do Terraform Destroy
echo "🔄 [INFO] Inicializando Terraform..."
terraform init -input=false

echo "💥 [INFO] Destruindo recursos..."
terraform destroy -auto-approve

echo "✅ [SUCESSO] Recursos do job Delta destruídos com sucesso! 🎉"

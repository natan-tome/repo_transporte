#!/usr/bin/env bash
set -eo pipefail  # 🛡️ Habilita modo seguro: erro, pipefail e vars não definidas

echo "========================================"
echo "🚀 [DESTROY] Iniciando terraform destroy..."
echo "========================================"

# 🔄 Carrega variáveis do .env se DATABRICKS_HOST não estiver definido
if [ -z "${DATABRICKS_HOST:-}" ] && [ -f "./.env" ]; then
  echo "🔧 [DESTROY] Carregando variáveis do .env..."
  set -a
  . ./.env
  set +a
fi

# 📓 Valida e constrói dinamicamente o NOTEBOOK_PATH
if [ -z "${NOTEBOOK_PATH:-}" ]; then
  if [ -n "${EMAIL:-}" ]; then
    NOTEBOOK_PATH="/Workspace/Users/${EMAIL}/create_delta_tables"
    export NOTEBOOK_PATH
  else
    echo "❌ [ERRO] Variável EMAIL não definida para gerar o NOTEBOOK_PATH."
    exit 1
  fi
fi

# 📦 Construção dinâmica do VOLUME_PATH (se necessário)
if [ -z "${VOLUME_PATH:-}" ]; then
  export VOLUME_PATH="/Volumes/${CATALOG_NAME}/${SCHEMA_NAME}/raw"
  echo "📦 [INFO] VOLUME_PATH construído dinamicamente: $VOLUME_PATH"
fi

# 🌐 Exporta variáveis para o Terraform
export TF_VAR_databricks_host="$DATABRICKS_HOST"
export TF_VAR_databricks_token="$DATABRICKS_TOKEN"
export TF_VAR_catalog_name="$CATALOG_NAME"
export TF_VAR_schema_name="$SCHEMA_NAME"
export TF_VAR_notebook_path="$NOTEBOOK_PATH"
export TF_VAR_volume_path="$VOLUME_PATH"
export TF_VAR_email="$EMAIL"

# 🏗️ Execução do Terraform Destroy
echo "🔄 Inicializando Terraform..."
terraform init

echo "💥 Destruindo recursos..."
terraform destroy -auto-approve \
  -var="databricks_host=${DATABRICKS_HOST}" \
  -var="databricks_token=${DATABRICKS_TOKEN}" \
  -var="catalog_name=${CATALOG_NAME}" \
  -var="schema_name=${SCHEMA_NAME}" \
  -var="notebook_path=${NOTEBOOK_PATH}" \
  -var="volume_path=${VOLUME_PATH}" \
  -var="email=${EMAIL}"

echo "✅ [SUCESSO] Recursos destruídos com sucesso! 🎉"

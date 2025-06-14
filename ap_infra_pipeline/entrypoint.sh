#!/bin/bash
set -eu  # 🛡️ Para execução segura: erro em variáveis indefinidas e qualquer falha

echo "🚀 [ENTRYPOINT] Iniciando terraform apply..."

# ─────────────────────────────────────────────────────────────
# 🔄 Carrega variáveis do .env se ainda não estiverem no ambiente
# Suporta montagem externa via Docker: .env → /env/.env
# ─────────────────────────────────────────────────────────────
if [ -z "${DATABRICKS_HOST:-}" ]; then
  if [ -f "/env/.env" ]; then
    echo "🔧 [ENTRYPOINT] Carregando variáveis de /env/.env..."
    export $(grep -v '^#' /env/.env | xargs)
  elif [ -f "./.env" ]; then
    echo "🔧 [ENTRYPOINT] Carregando variáveis de ./.env..."
    export $(grep -v '^#' ./.env | xargs)
  else
    echo "⚠️ [WARNING] Nenhum arquivo .env encontrado. Variáveis podem estar ausentes."
  fi
fi

# ─────────────────────────────────────────────
# 📦 Construção dinâmica do VOLUME_PATH (se necessário)
# ─────────────────────────────────────────────
if [ -z "${VOLUME_PATH:-}" ]; then
  export VOLUME_PATH="/Volumes/${CATALOG_NAME}/${SCHEMA_NAME}/raw"
  echo "📦 [INFO] VOLUME_PATH construído dinamicamente: $VOLUME_PATH"
fi

# ─────────────────────────────────────────────────────────────
# 📓 Valida e constrói dinamicamente o caminho do notebook
# ─────────────────────────────────────────────────────────────
if [ -z "${NOTEBOOK_PATH:-}" ]; then
  if [ -n "${EMAIL:-}" ]; then
    NOTEBOOK_PATH="/Workspace/Users/${EMAIL}/create_delta_tables"
    export NOTEBOOK_PATH
  else
    echo "❌ [ERRO] Variável EMAIL não definida para gerar o NOTEBOOK_PATH."
    exit 1
  fi
fi

# 🐞 Debug opcional: mostra variáveis carregadas
echo "📝 [INFO] Variáveis carregadas:"
echo " - DATABRICKS_HOST = $DATABRICKS_HOST"
echo " - CATALOG_NAME    = $CATALOG_NAME"
echo " - SCHEMA_NAME     = $SCHEMA_NAME"
echo " - VOLUME_PATH     = $VOLUME_PATH"
echo " - NOTEBOOK_PATH   = $NOTEBOOK_PATH"
echo " - EMAIL           = $EMAIL"

# ─────────────────────────────────────────────────────────────
# 🏗️ Executa Terraform (init e apply)
# ─────────────────────────────────────────────────────────────
terraform init -input=false

terraform apply -auto-approve \
  -var="databricks_host=${DATABRICKS_HOST}" \
  -var="databricks_token=${DATABRICKS_TOKEN}" \
  -var="catalog_name=${CATALOG_NAME}" \
  -var="schema_name=${SCHEMA_NAME}" \
  -var="volume_path=${VOLUME_PATH}" \
  -var="notebook_path=${NOTEBOOK_PATH}" \
  -var="email=${EMAIL}"

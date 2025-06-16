#!/bin/sh
set -e  # 🛡️ Interrompe em qualquer erro

echo "========================================"
echo "🚀 [INFO] Iniciando execução do job Delta via Terraform"
echo "========================================"

# 🗂️ Carrega variáveis do .env (caso esteja montado)
if [ -f "./.env" ]; then
  echo "🔧 [INFO] Carregando variáveis do arquivo .env..."
  export $(grep -v '^#' ./.env | xargs)
else
  echo "⚠️ [AVISO] Arquivo ./.env não encontrado. Variáveis podem não estar carregadas."
fi

# 📦 Construção dinâmica do VOLUME_PATH (se necessário)
if [ -z "${VOLUME_PATH:-}" ]; then
  export VOLUME_PATH="/Volumes/${CATALOG_NAME}/${SCHEMA_NAME}/raw"
  echo "📦 [INFO] VOLUME_PATH construído dinamicamente: $VOLUME_PATH"
fi

# 🌐 Exporta variáveis para o Terraform (TF_VAR_*)
export TF_VAR_databricks_host="$DATABRICKS_HOST"
export TF_VAR_databricks_token="$DATABRICKS_TOKEN"
export TF_VAR_catalog_name="$CATALOG_NAME"
export TF_VAR_schema_name="$SCHEMA_NAME"
export TF_VAR_volume_path="$VOLUME_PATH"
export TF_VAR_email="$EMAIL"
export TF_VAR_owner="${OWNER:-$(whoami)}"

# 📓 Gera dinamicamente o notebook path com base no e-mail
NOTEBOOK_PATH="/Workspace/Users/${EMAIL}/create_delta_tables"
export TF_VAR_notebook_path="$NOTEBOOK_PATH"
echo "📓 [INFO] Notebook path gerado: $NOTEBOOK_PATH"

# 📝 Exibe variáveis carregadas para conferência
echo "🔎 [INFO] Variáveis carregadas:"
echo " - HOST..........: $TF_VAR_databricks_host"
echo " - CATALOG.......: $TF_VAR_catalog_name"
echo " - SCHEMA........: $TF_VAR_schema_name"
echo " - VOLUME_PATH...: $TF_VAR_volume_path"
echo " - NOTEBOOK PATH.: $TF_VAR_notebook_path"
echo " - OWNER.........: $TF_VAR_owner"

# 🏗️ Inicializa e aplica Terraform
terraform init -input=false
terraform apply -auto-approve

# 🚦 Captura e executa job criado com parâmetros dinâmicos
echo "🔄 [INFO] Obtendo job_id..."
JOB_ID=$(terraform output -raw job_id)
echo "🆔 [INFO] Job ID: $JOB_ID"

echo "🚦 [INFO] Disparando execução do job no Databricks com parâmetros:"
echo " - CATALOG_NAME: $CATALOG_NAME"
echo " - SCHEMA_NAME: $SCHEMA_NAME"
echo " - VOLUME_PATH: $VOLUME_PATH"

databricks jobs run-now --job-id "$JOB_ID" \
  --notebook-params "{
    \"CATALOG_NAME\": \"$CATALOG_NAME\",
    \"SCHEMA_NAME\": \"$SCHEMA_NAME\",
    \"VOLUME_PATH\": \"$VOLUME_PATH\"
  }"

echo "✅ [SUCESSO] Job executado com sucesso! 🎉"

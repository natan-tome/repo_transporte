#!/bin/sh
set -e

# 🚀 Carrega variáveis da .env (se existir)
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
fi

# 📝 Exibe variáveis carregadas (debug rápido)
echo "[INFO] Variáveis de ambiente carregadas:"
echo "DATABRICKS_HOST: $DATABRICKS_HOST"
echo "CATALOG_NAME: $CATALOG_NAME"
echo "SCHEMA_NAME: $SCHEMA_NAME"

# 📦 Define caminho base do volume no DBFS
VOLUME_BASE="dbfs:/Volumes/${CATALOG_NAME}/${SCHEMA_NAME}/raw"
echo "[INFO] Caminho destino no DBFS: $VOLUME_BASE"

# 🔒 Verifica autenticação e acesso ao volume
echo "[INFO] Verificando autenticação e acesso ao volume..."
if databricks fs ls "$VOLUME_BASE" > /dev/null 2>&1; then
  echo "[✅ OK] Volume acessível."
else
  echo "[❌ ERRO] Não foi possível acessar o volume em $VOLUME_BASE"
  echo "          Verifique as variáveis DATABRICKS_HOST, DATABRICKS_TOKEN, CATALOG_NAME e SCHEMA_NAME."
  exit 1
fi

# ⬆️ Upload de arquivos .parquet para o DBFS
echo "[INFO] Iniciando upload de arquivos .parquet do diretório /data/parquet..."
found_parquet=false
for file in /data/parquet/*.parquet; do
  [ -f "$file" ] || continue
  found_parquet=true
  fname=$(basename "$file")
  prefixed_name="db_${fname}"
  echo "[UPLOAD] $prefixed_name 🚚"
  databricks fs cp "$file" "$VOLUME_BASE/$prefixed_name" --overwrite
done

if [ "$found_parquet" = false ]; then
  echo "[⚠️ AVISO] Nenhum arquivo .parquet encontrado em /data/parquet."
fi

# ⬆️ Upload de arquivos .jsonl para o DBFS
echo "[INFO] Iniciando upload de arquivos .jsonl do diretório /data/jsonl..."
found_jsonl=false
for file in /data/jsonl/*.jsonl; do
  [ -f "$file" ] || continue
  found_jsonl=true
  fname=$(basename "$file")
  prefixed_name="api_${fname}"
  echo "[UPLOAD] $prefixed_name 🚚"
  databricks fs cp "$file" "$VOLUME_BASE/$prefixed_name" --overwrite
done

if [ "$found_jsonl" = false ]; then
  echo "[⚠️ AVISO] Nenhum arquivo .jsonl encontrado em /data/jsonl."
fi

# 🎉 Finalização do processo
echo "[✅ SUCESSO] Upload concluído com sucesso! 🎯"

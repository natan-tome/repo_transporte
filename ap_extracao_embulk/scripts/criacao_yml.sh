#!/bin/bash
set -e

# 🚀 Caminho dos JARs fixos (fora do volume compartilhado, sem risco de sumir)
EMBULK_JAR="/opt/embulk/embulk.jar"
JRUBY_JAR="file:///opt/embulk/jruby-complete.jar"
EMBULK_PROPERTIES="$HOME/.embulk/embulk.properties"

# 📁 Caminhos do projeto (onde fica config e saída)
TEMPLATE=config/template.yml
TABLES_YML=config/extracao_tabelas.yml
JOBS_DIR=config/jobs
PARQUET_DIR=/data/parquet

# 🔄 Carrega variáveis do .env se existir (sem poluir o ambiente)
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
fi

# ⚠️ Checa se as variáveis obrigatórias estão setadas (sem elas, nem adianta seguir)
: "${SQLSERVER_HOST:?Variável não definida}"
: "${SQLSERVER_PORT:?Variável não definida}"
: "${SQLSERVER_USER:?Variável não definida}"
: "${SQLSERVER_PASSWORD:?Variável não definida}"
: "${SQLSERVER_DB:?Variável não definida}"

# 🛠️ Configura JRuby pro Embulk funcionar direito
mkdir -p ~/.embulk
echo "jruby=$JRUBY_JAR" > "$EMBULK_PROPERTIES"

# 🗂️ Garante que os diretórios existem e limpa jobs antigos
mkdir -p "$JOBS_DIR" "$PARQUET_DIR"
rm -f "$JOBS_DIR"/*.yml

# 🏁 Marca o início do processo (pra saber que começou mesmo)
echo "========================================"
echo "INÍCIO DO PROCESSO DE EXTRAÇÃO COM EMBULK"
echo "========================================"

schemas=$(yq eval '.schemas | keys | .[]' "$TABLES_YML")

for schema in $schemas; do
  tables=$(yq eval ".schemas.${schema}[]" "$TABLES_YML")
  for table in $tables; do
    full_table="${schema}.${table}"
    output_name="$(echo "${schema}_${table}" | tr '[:upper:]' '[:lower:]')"
    output_file="${JOBS_DIR}/${output_name}.yml"

    echo
    echo "----------------------------------------"
    echo "Processando tabela: ${full_table} 🛠️"
    echo "----------------------------------------"

    # ✍️ Gera o arquivo de job FORÇANDO sobrescrita (overwrite: true, indentação correta)
    envsubst < "$TEMPLATE" | \
      sed "s/{{FULL_TABLE}}/${full_table}/g; s/{{OUTPUT_NAME}}/${output_name}/g" | \
      sed '/path:/a\    overwrite: true' > "$output_file"

    # 🚨 Se o arquivo ficou vazio, avisa e pula pra próxima
    if [ ! -s "$output_file" ]; then
      echo "[ERRO] Arquivo de configuração '${output_file}' está vazio. Verifique variáveis de ambiente. ❌"
      continue
    fi

    # 🧹 Limpa arquivo temporário anterior (se existir)
    old_file="data/${output_name}.000.parquet"
    if [ -f "$old_file" ]; then
      rm -f "$old_file"
      echo "[INFO] Arquivo temporário anterior removido: ${old_file} 🗑️"
    fi

    # ▶️ Roda o Embulk pra extrair os dados (agora com overwrite)
    echo "[INFO] Executando Embulk... ⚡"
    java -Djruby="$JRUBY_JAR" -jar "$EMBULK_JAR" run "$output_file"

    new_file="${PARQUET_DIR}/${output_name}.parquet"

    # 📦 Move o arquivo gerado pro diretório final (sobrescreve se existir)
    if [ -f "$old_file" ]; then
      mv -f "$old_file" "$new_file"
      echo "[SUCESSO] Arquivo gerado em: ${new_file} ✅"
    else
      echo "[AVISO] Arquivo esperado não encontrado: ${old_file} ⚠️"
    fi
  done
done

# 🧹 Limpeza final (pra não deixar sujeira)
echo "----------------------------------------"
echo "Limpando arquivos temporários... 🧽"

# Remove arquivos temporários de job
rm -f "$JOBS_DIR"/*.yml

# Remove arquivos .crc que aparecem junto dos .parquet
find "$PARQUET_DIR" -type f -name "*.crc" -exec rm -f {} +

echo "[CONCLUÍDO] Processo finalizado com sucesso! 🎉"

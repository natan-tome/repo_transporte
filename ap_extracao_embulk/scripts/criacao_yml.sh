#!/bin/bash
set -e

# Caminhos fixos dos JARs necessários (fora do volume compartilhado)
EMBULK_JAR="/opt/embulk/embulk.jar"
JRUBY_JAR="file:///opt/embulk/jruby-complete.jar"
EMBULK_PROPERTIES="$HOME/.embulk/embulk.properties"

# Defino os caminhos principais do projeto
TEMPLATE=config/template.yml
TABLES_YML=config/extracao_tabelas.yml
JOBS_DIR=config/jobs
PARQUET_DIR=/data/parquet

# Carrego variáveis de ambiente do .env, se existir
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Validação: todas as variáveis essenciais precisam estar setadas
: "${SQLSERVER_HOST:?Variável não definida}"
: "${SQLSERVER_PORT:?Variável não definida}"
: "${SQLSERVER_USER:?Variável não definida}"
: "${SQLSERVER_PASSWORD:?Variável não definida}"
: "${SQLSERVER_DB:?Variável não definida}"

# Configuro o JRuby para o Embulk funcionar corretamente
mkdir -p ~/.embulk
echo "jruby=$JRUBY_JAR" > "$EMBULK_PROPERTIES"

# Instalo gems básicas do Embulk, só se ainda não estiverem presentes
for gem in embulk msgpack liquid bundler; do
  if ! java -jar "$EMBULK_JAR" gem list | grep -q "$gem"; then
    java -jar "$EMBULK_JAR" gem install "$gem"
  fi
done

# Instalo plugins do Embulk necessários para SQL Server e Parquet
for plugin in embulk-input-sqlserver embulk-output-parquet; do
  if ! java -jar "$EMBULK_JAR" gem list | grep -q "$plugin"; then
    java -jar "$EMBULK_JAR" gem install "$plugin"
  fi
done

# Garante que os diretórios existem e limpa jobs antigos
mkdir -p "$JOBS_DIR" "$PARQUET_DIR"
rm -f "$JOBS_DIR"/*.yml

# Para cada schema e tabela definidos no YML, gero o job e executo a carga
schemas=$(yq eval '.schemas | keys | .[]' "$TABLES_YML")

for schema in $schemas; do
  tables=$(yq eval ".schemas.${schema}[]" "$TABLES_YML")
  for table in $tables; do
    full_table="${schema}.${table}"
    output_name="$(echo "${schema}_${table}" | tr '[:upper:]' '[:lower:]')"
    output_file="${JOBS_DIR}/${output_name}.yml"

    echo ">> Gerando config para ${full_table}..."
    envsubst < "$TEMPLATE" | sed "s/{{FULL_TABLE}}/${full_table}/g; s/{{OUTPUT_NAME}}/${output_name}/g" > "$output_file"

    # Se o arquivo de config ficou vazio, já aviso e pulo para o próximo
    if [ ! -s "$output_file" ]; then
      echo "❌ ERRO: Arquivo ${output_file} está vazio. Verifique variáveis de ambiente."
      continue
    fi

    echo ">> Rodando Embulk para ${full_table}..."
    java -Djruby="$JRUBY_JAR" -jar "$EMBULK_JAR" run "$output_file"

    old_file="data/${output_name}.000.parquet"
    new_file="${PARQUET_DIR}/${output_name}.parquet"

    # Renomeio o arquivo gerado para o padrão do projeto
    if [ -f "$old_file" ]; then
      mv "$old_file" "$new_file"
      echo "✅ Arquivo renomeado para: ${new_file}"
    else
      echo "⚠ Arquivo não encontrado: ${old_file}"
    fi
  done
done

# Limpeza final dos arquivos temporários de job
echo "🧹 Limpando arquivos temporários..."
rm -f "$JOBS_DIR"/*.yml
echo "✔ Finalizado com sucesso."

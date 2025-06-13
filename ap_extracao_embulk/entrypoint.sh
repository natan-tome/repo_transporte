#!/bin/bash

# Carrego variáveis do .env se estiver presente
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
fi

set -e

# Se não receber argumento, executo o fluxo padrão de extração com Embulk
if [ $# -eq 0 ]; then
  echo "ℹ️  Nenhum argumento informado. Rodando o processo padrão de extração com Embulk..."
  cd /app
  exec /bin/bash ./scripts/criacao_yml.sh
else
  # Se receber argumento, executo o comando customizado informado
  echo "⚙️  Executando comando customizado: $@"
  exec "$@"
fi

#!/bin/bash

set -e

# 🔄 [1/4] Atualiza o lockfile do Meltano (mantém tudo sincronizado e sem surpresa de dependência)
echo "==================== [1/4] Atualizando lockfile do Meltano ===================="
meltano lock --update --all

# 📦 [2/4] Instala todos os plugins do Meltano (garante que tudo que precisa vai rodar)
echo "==================== [2/4] Instalando plugins do Meltano ======================"
meltano install

# 🗂️ [3/4] Garante estrutura da pasta e limpa arquivos antigos (começa sempre do zero, sem lixo)
echo "==================== [3/4] Garantindo estrutura e limpando arquivos antigos ==="
mkdir -p /data/jsonl  # Cria a pasta se não existir (sem erro)
rm -f /data/jsonl/.jsonl /data/jsonl/.jsonl.gz /data/jsonl/*.parquet  # Limpa arquivos antigos

# ▶️ [4/4] Executa o pipeline Meltano (hora da verdade!)
echo "==================== [4/4] Executando pipeline ================================"
exec meltano run tap-aw-api target-jsonl
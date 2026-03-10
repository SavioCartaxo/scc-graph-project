#!/bin/bash

# =============================================================
# PIPELINE DE BENCHMARK — SCC
# =============================================================
# Uso:
#   ./benchmark.sh <algoritmo> <densidade> <nivel_scc>
#
# Argumentos:
#   algoritmo  → tarjan | kosaraju | tarjan-recursivo | tarjan-recursivo-hash
#   densidade  → baixa | media | alta
#   nivel_scc  → muitos | medios | poucos
#
# Exemplo:
#   ./benchmark.sh tarjan-recursivo media medios
# =============================================================

set -e

# -------------------------------------------------------------
# VALIDAÇÃO DOS ARGUMENTOS
# -------------------------------------------------------------

if [ "$#" -ne 3 ]; then
  echo "Uso: ./benchmark.sh <algoritmo> <densidade> <nivel_scc>"
  echo "  algoritmo : tarjan | kosaraju | tarjan-recursivo | tarjan-recursivo-hash"
  echo "  densidade : baixa | media | alta"
  echo "  nivel_scc : muitos | medios | poucos"
  exit 1
fi

ALGORITMO=$1
DENSIDADE=$2
NIVEL_SCC=$3

# Valida algoritmo
if [[ "$ALGORITMO" != "tarjan" && \
      "$ALGORITMO" != "kosaraju" && \
      "$ALGORITMO" != "tarjan-recursivo" && \
      "$ALGORITMO" != "tarjan-recursivo-hash" ]]; then
  echo "Erro: algoritmo invalido '$ALGORITMO'."
  echo "Use: tarjan | kosaraju | tarjan-recursivo | tarjan-recursivo-hash"
  exit 1
fi

# Valida densidade
if [[ "$DENSIDADE" != "baixa" && "$DENSIDADE" != "media" && "$DENSIDADE" != "alta" ]]; then
  echo "Erro: densidade invalida '$DENSIDADE'. Use: baixa | media | alta"
  exit 1
fi

# Valida nível de SCC
if [[ "$NIVEL_SCC" != "muitos" && "$NIVEL_SCC" != "medios" && "$NIVEL_SCC" != "poucos" ]]; then
  echo "Erro: nivel_scc invalido '$NIVEL_SCC'. Use: muitos | medios | poucos"
  exit 1
fi

# ---------------------------------------------------------------
# CONFIGURAÇÕES
# Progressão constante de 100 até 1.000.000 aumentando em 20.000
# ---------------------------------------------------------------

NS=(100 20000 40000 60000 80000 100000 120000 140000 160000 180000 200000 220000 240000 260000 280000 300000 320000 340000 360000 380000 400000 420000 440000 460000
 480000 500000 520000 540000 560000 580000 600000 620000 640000 660000 680000 700000 720000 740000 760000 780000 800000 820000 840000 860000 880000 900000 9
20000 940000 960000 980000 1000000)

# Densidade → fator de arestas (M = N × fator)
# baixa: esparso | media: intermediário | alta: denso
case $DENSIDADE in
  baixa) FATOR_M=2  ;;
  media) FATOR_M=5  ;;
  alta)  FATOR_M=10 ;;
esac

# Nível SCC → divisor de K (K = N / divisor)
# muitos: SCCs pequenas | medios: intermediário | poucos: SCCs grandes
case $NIVEL_SCC in
  muitos) DIVISOR_K=3  ;;
  medios) DIVISOR_K=10 ;;
  poucos) DIVISOR_K=30 ;;
esac

# -------------------------------------------------------------
# PREPARAÇÃO
# -------------------------------------------------------------

mkdir -p inputs resultados

# Lista que acumula os caminhos de todos os inputs gerados
# Será passada de uma vez só ao container no final
INPUT_FILES=()

echo "============================================="
echo " Benchmark: $ALGORITMO | densidade: $DENSIDADE | sccs: $NIVEL_SCC"
echo "============================================="

# -------------------------------------------------------------
# ETAPA 1 — Gera TODOS os inputs antes de subir o Docker
# Separar geração de inputs da execução elimina o overhead
# de inicialização do container por iteração
# -------------------------------------------------------------

echo ""
echo "[1/3] Gerando inputs..."

for N in "${NS[@]}"; do
  M=$(( N * FATOR_M ))
  K=$(( N / DIVISOR_K ))
  if [ "$K" -lt 1 ]; then K=1; fi

  INPUT_FILE="inputs/grafo_n${N}_m${M}_k${K}.txt"
  python scripts/script_controlled_graph.py "$N" "$M" "$K" > "$INPUT_FILE"
  INPUT_FILES+=("/app/inputs/$(basename $INPUT_FILE)")
  echo "  gerado: $INPUT_FILE"
done

# -------------------------------------------------------------
# ETAPA 2 — Build da imagem
# Sem --no-cache: reutiliza camadas em cache quando o código
# não mudou, tornando rebuilds subsequentes mais rápidos
# Use 'docker compose build --no-cache' manualmente apenas
# quando quiser forçar recompilação completa
# -------------------------------------------------------------

echo ""
echo "[2/3] Buildando imagem..."
docker compose build
echo "  build concluido."

# -------------------------------------------------------------
# ETAPA 3 — Executa o container UMA única vez
# Passa todos os arquivos de input como argumentos para o Java
# O Java faz warmup + medição internamente para cada arquivo,
# eliminando o overhead de inicialização do container por N
# -------------------------------------------------------------

echo ""
echo "[3/3] Executando benchmark (container unico)..."

docker compose run --rm \
  "$ALGORITMO" \
  "$ALGORITMO" "${INPUT_FILES[@]}" \
  | tee "resultados/log_${ALGORITMO}_${DENSIDADE}_${NIVEL_SCC}_$(date +%Y%m%d_%H%M%S).txt"

# -------------------------------------------------------------
# FINALIZAÇÃO
# Renomeia o CSV gerado pelo Java incluindo configuração e timestamp
# Isso permite rodar o mesmo benchmark várias vezes sem sobrescrever
# e facilita o merge.sh encontrar o arquivo mais recente
# -------------------------------------------------------------

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# O nome do CSV usa hífen como separador no algoritmo — normaliza para arquivo
ALGORITMO_SAFE=$(echo "$ALGORITMO" | tr '-' '_')
CSV_ORIGINAL="resultados/resultado_${ALGORITMO}.csv"
CSV_FINAL="resultados/resultado_${ALGORITMO_SAFE}_${DENSIDADE}_${NIVEL_SCC}_${TIMESTAMP}.csv"

if [ -f "$CSV_ORIGINAL" ]; then
  mv "$CSV_ORIGINAL" "$CSV_FINAL"
  echo ""
  echo "============================================="
  echo " Pipeline concluido!"
  echo " CSV: $CSV_FINAL"
  echo "============================================="
else
  echo "Aviso: CSV nao encontrado em $CSV_ORIGINAL"
fi

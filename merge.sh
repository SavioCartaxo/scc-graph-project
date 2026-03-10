#!/bin/bash

# =============================================================
# MERGE DE RESULTADOS — N algoritmos → CSV unificado
# =============================================================
# Uso:
#   ./merge.sh <densidade> <nivel_scc> <algoritmo1> [algoritmo2 ...]
#
# Exemplo — comparar os 4:
#   ./merge.sh media medios tarjan kosaraju tarjan-recursivo tarjan-recursivo-hash
#
# Exemplo — comparar só dois:
#   ./merge.sh baixa poucos tarjan kosaraju
#
# Para cada algoritmo informado, pega o CSV mais recente
# com a configuração (densidade + nivel_scc) e junta tudo
# numa tabela única para plotagem
# =============================================================

set -e

# -------------------------------------------------------------
# VALIDAÇÃO DOS ARGUMENTOS
# -------------------------------------------------------------

if [ "$#" -lt 3 ]; then
  echo "Uso: ./merge.sh <densidade> <nivel_scc> <algoritmo1> [algoritmo2 ...]"
  echo "Exemplo: ./merge.sh media medios tarjan kosaraju tarjan-recursivo tarjan-recursivo-hash"
  exit 1
fi

DENSIDADE=$1
NIVEL_SCC=$2
shift 2              # remove os dois primeiros argumentos — o resto são algoritmos
ALGORITMOS=("$@")   # array com todos os algoritmos passados

echo "============================================="
echo " Merge: $DENSIDADE | $NIVEL_SCC"
echo " Algoritmos: ${ALGORITMOS[*]}"
echo "============================================="

# -------------------------------------------------------------
# LOCALIZA O CSV MAIS RECENTE DE CADA ALGORITMO
# O 'ls -t' ordena por data de modificação (mais recente primeiro)
# O 'head -1' pega apenas o primeiro (mais recente)
# -------------------------------------------------------------

CSV_PATHS=()   # caminhos dos CSVs encontrados
CSV_NOMES=()   # nomes dos algoritmos correspondentes (para o cabeçalho)

for ALGO in "${ALGORITMOS[@]}"; do
  # Normaliza hífens para underscore no nome do arquivo
  ALGO_SAFE=$(echo "$ALGO" | tr '-' '_')

  CSV=$(ls -t resultados/resultado_${ALGO_SAFE}_${DENSIDADE}_${NIVEL_SCC}_*.csv 2>/dev/null | head -1)

  if [ -z "$CSV" ]; then
    echo "Erro: nenhum resultado encontrado para '$ALGO' com: $DENSIDADE $NIVEL_SCC"
    echo "Rode primeiro: ./benchmark.sh $ALGO $DENSIDADE $NIVEL_SCC"
    exit 1
  fi

  echo "  encontrado [$ALGO]: $CSV"
  CSV_PATHS+=("$CSV")
  CSV_NOMES+=("$ALGO")
done

# -------------------------------------------------------------
# MERGE — junta todos os CSVs por N usando Python
# Usa Python para o join pois é mais seguro que manipulação
# de texto no shell, especialmente com valores decimais
# Gera uma coluna <algoritmo>_ms para cada algoritmo informado
# -------------------------------------------------------------

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CSV_FINAL="resultados/comparacao_${DENSIDADE}_${NIVEL_SCC}_${TIMESTAMP}.csv"

# Passa os caminhos e nomes para o Python via argumentos
# Formato: python merge.py saida.csv algo1:path1 algo2:path2 ...
ARGS=("$CSV_FINAL")
for i in "${!ALGORITMOS[@]}"; do
  ALGO_SAFE=$(echo "${CSV_NOMES[$i]}" | tr '-' '_')
  ARGS+=("${ALGO_SAFE}:${CSV_PATHS[$i]}")
done

python3 - "${ARGS[@]}" << 'PYEOF'
import sys, csv

arquivo_saida = sys.argv[1]
entradas      = sys.argv[2:]  # formato: "nome_algo:caminho_csv"

# Lê cada CSV e indexa por N
algoritmos = []
dados = {}  # { nome_algo: { n: media_ms } }
meta  = {}  # { n: { arestas, k_sccs } } — pega do primeiro CSV

for entrada in entradas:
    nome, caminho = entrada.split(":", 1)
    algoritmos.append(nome)
    dados[nome] = {}

    with open(caminho) as f:
        reader = csv.DictReader(f)
        for row in reader:
            n = int(row['n'])
            dados[nome][n] = row['media_ms']
            if n not in meta:
                meta[n] = {'arestas': row['arestas'], 'k_sccs': row['k_sccs']}

# União de todos os N presentes em qualquer algoritmo
todos_n = sorted(set(n for d in dados.values() for n in d))

# Monta cabeçalho dinâmico: n, arestas, k_sccs, algo1_ms, algo2_ms, ...
cabecalho = ['n', 'arestas', 'k_sccs'] + [f"{a}_ms" for a in algoritmos]

with open(arquivo_saida, 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(cabecalho)
    for n in todos_n:
        linha = [
            n,
            meta.get(n, {}).get('arestas', ''),
            meta.get(n, {}).get('k_sccs', '')
        ]
        for algo in algoritmos:
            linha.append(dados[algo].get(n, ''))  # vazio se algoritmo não tem esse N
        writer.writerow(linha)

print(f"CSV unificado salvo em: {arquivo_saida}")
PYEOF

# -------------------------------------------------------------
# FINALIZAÇÃO
# -------------------------------------------------------------

echo ""
echo "============================================="
echo " Merge concluido!"
echo " Arquivo: $CSV_FINAL"
echo "============================================="
echo ""
cat "$CSV_FINAL"

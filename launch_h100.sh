#!/usr/bin/env bash
set -euo pipefail

# Gimlet hetero — 8xH100 launcher (11 layers, 3/5/3 early/middle/late).

RUN_ID="${RUN_ID:-gimlet_hetero_$(date +%Y%m%d_%H%M%S)}"
DATA_PATH="${DATA_PATH:-./data/datasets/fineweb10B_sp1024}"
TOKENIZER_PATH="${TOKENIZER_PATH:-./data/tokenizers/fineweb_1024_bpe.model}"
MAX_WALLCLOCK_SECONDS="${MAX_WALLCLOCK_SECONDS:-0}"
NPROC_PER_NODE="${NPROC_PER_NODE:-8}"

export RUN_ID DATA_PATH TOKENIZER_PATH MAX_WALLCLOCK_SECONDS NPROC_PER_NODE

echo "=== Gimlet hetero (8xH100) ==="
echo "RUN_ID: ${RUN_ID}"
echo "DATA_PATH: ${DATA_PATH}"
echo "TOKENIZER_PATH: ${TOKENIZER_PATH}"
echo "NUM_LAYERS: ${NUM_LAYERS:-11}"
echo "MAX_WALLCLOCK_SECONDS: ${MAX_WALLCLOCK_SECONDS}"
echo "NPROC_PER_NODE: ${NPROC_PER_NODE}"
echo "==================================="

bash ./preflight_h100.sh
torchrun --standalone --nproc_per_node="${NPROC_PER_NODE}" train_gpt.py

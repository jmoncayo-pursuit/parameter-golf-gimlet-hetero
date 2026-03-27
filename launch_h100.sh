#!/usr/bin/env bash
set -euo pipefail

# parameter-golf-gimlet-hetero: 8xH100 launcher
# Heterogeneous 11-layer model with 3/5/3 early/middle/late split.

RUN_ID="${RUN_ID:-gimlet_hetero_$(date +%Y%m%d_%H%M%S)}"
DATA_PATH="${DATA_PATH:-./data/datasets/fineweb10B_sp1024}"
TOKENIZER_PATH="${TOKENIZER_PATH:-./data/tokenizers/fineweb_1024_bpe.model}"

export RUN_ID DATA_PATH TOKENIZER_PATH

echo "=== parameter-golf-gimlet-hetero ==="
echo "RUN_ID: ${RUN_ID}"
echo "DATA_PATH: ${DATA_PATH}"
echo "TOKENIZER_PATH: ${TOKENIZER_PATH}"
echo "NUM_LAYERS: ${NUM_LAYERS:-11}"
echo "==================================="

torchrun --standalone --nproc_per_node=8 train_gpt.py

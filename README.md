# Gimlet Heterogeneous Precision Width Decoder

Based on the official OpenAI parameter-golf baseline train_gpt.py.
Changes from baseline are marked with [HETERO] comments.

## Purpose

This repo implements a single experiment: allocating different precision budgets and MLP widths to different transformer layer groups. The hypothesis is that middle layers benefit from wider MLPs at lower export precision, while early/late layers benefit from narrower MLPs at higher export precision. All training is in bf16/fp32; precision heterogeneity is applied only at post-training quantization export.

## Layer Mapping


| Layer Group | Block Indices | `mlp_mult` | MLP Hidden Dim | Export `clip_val` | Effective Precision |
|:---|:---|:---|:---|:---|:---|
| Early | 0, 1, 2 | 3.0 | 1536 | 31 | ~Int6 (63 levels) |
| Middle | 3, 4, 5, 6, 7 | 4.5 | 2304 | 7 | ~Int4 (15 levels) |
| Late | 8, 9, 10 | 3.0 | 1536 | 31 | ~Int6 (63 levels) |

All attention projections (c_q, c_k, c_v, proj) use `clip_val=31` (Int6) across all layers.

## Optimizer Partitioning

| Parameter Group | Optimizer | LR (default) |
|:---|:---|:---|
| Middle MLP matrices (blocks 3-7, `mlp.fc.weight` / `mlp.proj.weight`) | Muon | `MATRIX_LR` (0.04) |
| Early/late MLP matrices + all attention matrices | Adam | `ADAM_MATRIX_LR` (0.001) |
| Token embedding | Adam | `TIED_EMBED_LR` (0.05) |
| LM head (if untied) | Adam | `HEAD_LR` (0.008) |
| Scalars, control tensors, skip weights | Adam | `SCALAR_LR` (0.04) |

## Design Inspiration

This repo adapts the principle of **heterogeneous resource allocation** from systems-level infrastructure design to transformer layer budgeting.

**Primary inspiration:** "Efficient and Scalable Agentic AI with Heterogeneous Systems" ([arXiv:2507.19635v1](https://arxiv.org/html/2507.19635v1)). The paper discusses how heterogeneous compute infrastructure (mixing different hardware tiers) can optimize performance and cost for AI workloads. This repo takes that systems-level insight as inspiration for allocating different precision and width budgets across transformer layers.

## What Is Adapted vs. What Is Proven

| Claim | Status |
|:---|:---|
| Gimlet paper discusses heterogeneous allocation in systems infrastructure | Paper-supported |
| Heterogeneous allocation principle may translate to model architecture | Adapted hypothesis |
| The specific 3/5/3 early/middle/late precision-width map in this repo | Experimental, unvalidated |
| Int4 middle + Int6 boundary improves val_bpb vs. uniform precision | Not yet measured |
| Muon on middle MLP only improves training dynamics | Not yet measured |

## Risks / Unknowns

- **Artifact size**: With 11 layers and wider middle MLPs (4.5x), the model has significantly more parameters than the 9-layer baseline. Whether the Int4 middle layers compress enough for the artifact to fit under 16MB is unverified.
- **Int4 precision at PTQ**: Quantizing middle MLP weights to 15 discrete levels (clip_val=7) with post-training quantization may cause unacceptable accuracy loss without in-training QAT. This is the primary known risk.
- **Adam LR tuning**: The default `ADAM_MATRIX_LR=0.001` for non-Muon matrix params has not been tuned. This LR is unlikely optimal.
- **PTQ-only v1**: This repo implements precision heterogeneity only at the post-training export step. No training-time quantization (QAT) is performed.
- **Optimizer interaction**: Muon on a subset of matrix params (middle MLP only) has not been tested in this configuration. The baseline uses Muon on all block matrix params.

## Files

| File | Description |
|:---|:---|
| `train_gpt.py` | Modified baseline with heterogeneous changes marked `[HETERO]` |
| `launch_h100.sh` | 8xH100 launcher script |
| `README.md` | This file |
| `ARCHITECTURE.md` | Architecture status document |
| `colab_gimlet_runbook.ipynb` | Colab feasibility runbook (checkpoint-only staging; see below) |
| `RUNBOOK_TRACKING.md` | Cross-experiment Colab / Runpod status (shared `progress.csv` columns) |
| `requirements.txt` | Python dependencies (same as baseline) |

## Colab feasibility runbook

[`colab_gimlet_runbook.ipynb`](colab_gimlet_runbook.ipynb) is a **bounded smoke path** on Google Colab: mount Drive (optional), clone this repo + `openai/parameter-golf` data scripts, run short **checkpoint-only** training sweeps, append rows to `progress.csv`, and apply simple gates (step completion, train-loss trend, optional mini val slice). It is **not** a substitute for full `torchrun` training, official val_bpb leaderboard numbers, or the 16MB artifact check on H100. It exists so you can show a **reproducible protocol** and catch obvious breakage before spending serious GPU credits. Commit the notebook **without cell outputs** so the repo stays protocol, not a frozen Colab session.

**Status chart (all experiments, Colab vs Runpod):** [`RUNBOOK_TRACKING.md`](RUNBOOK_TRACKING.md).

## Usage

```bash
# 1xH100 smoke test
RUN_ID=hetero_smoke \
DATA_PATH=./data/datasets/fineweb10B_sp1024 \
TOKENIZER_PATH=./data/tokenizers/fineweb_1024_bpe.model \
torchrun --standalone --nproc_per_node=1 train_gpt.py

# 8xH100 full run
bash launch_h100.sh
```

## Baseline Provenance

Based on `openai/parameter-golf` `train_gpt.py` as of 2026-03-27. Only the changes marked with `[HETERO]` comments differ from the official baseline.

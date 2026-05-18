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

**Primary inspiration:** "Efficient and Scalable Agentic AI with Heterogeneous Systems" ([arXiv:2507.19635v1](https://arxiv.org/html/2507.19635v1)) by Zain Asgar (Stanford University, Gimlet Labs Inc.), Michelle Nguyen (Gimlet Labs, Inc.), and Sachin Katti (Stanford University, Intel). The paper discusses how heterogeneous compute infrastructure (mixing different hardware tiers) can optimize performance and cost for AI workloads. This repo takes that systems-level insight as inspiration for allocating different precision and width budgets across transformer layers, and adopts the name "Gimlet" as a nod to the lab the paper was published out of.

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
| `preflight_h100.sh` | Fast fail checks for paths, Python syntax, GPU count, and exact-step settings |
| `README.md` | This file |
| `ARCHITECTURE.md` | Architecture status document |
| `RUNPOD_READINESS_STANDARD.md` | Operational standard this repo now serves as for other experiments |
| `EXPERIMENT_READINESS_TRACKER.md` | Inventory of experiment canonical homes and readiness status |
| `colab_gimlet_runbook.ipynb` | Clean Colab proof runbook |
| `kaggle_gimlet_runbook.ipynb` | Clean Kaggle proof runbook |
| `records/` | Saved proof notebooks and result summaries that belong to this repo |
| `requirements.txt` | Python dependencies (same as baseline) |

## Proof runbooks

[`colab_gimlet_runbook.ipynb`](colab_gimlet_runbook.ipynb) and [`kaggle_gimlet_runbook.ipynb`](kaggle_gimlet_runbook.ipynb) are the clean proof paths for this repo.

They exist to prove that this experiment can:

- complete exact-step proof runs
- export `final_model.int8.ptz`
- write final summaries
- finish the roundtrip validation path

They are operational proof artifacts, not leaderboard evidence.

Completed proof results that actually belong to this repo are saved under:

- [`records/colab_600_step_run/README.md`](/Users/jmoncayopursuit.org/Desktop/parameter-golf-gimlet-hetero/records/colab_600_step_run/README.md)
- [`records/kaggle_600_step_run/README.md`](/Users/jmoncayopursuit.org/Desktop/parameter-golf-gimlet-hetero/records/kaggle_600_step_run/README.md)

## Usage

```bash
# 1xH100 smoke test
RUN_ID=hetero_smoke \
NPROC_PER_NODE=1 \
ITERATIONS=200 \
VAL_LOSS_EVERY=0 \
DATA_PATH=./data/datasets/fineweb10B_sp1024 \
TOKENIZER_PATH=./data/tokenizers/fineweb_1024_bpe.model \
MAX_WALLCLOCK_SECONDS=0 \
bash ./preflight_h100.sh && \
torchrun --standalone --nproc_per_node=1 train_gpt.py

# 8xH100 full run
bash launch_h100.sh
```

Set `MAX_WALLCLOCK_SECONDS=0` when you want an exact-step run. If you set a positive cap, training may stop before `ITERATIONS` is reached.

Cheap preflight only:

```bash
NPROC_PER_NODE=8 bash ./preflight_h100.sh
```

What to look for in the smoke log before spending on 8xH100:
- `wallclock_mode:disabled (exact step target)`
- `world_size:1 grad_accum_steps:8`
- `optimizer_groups: ...`
- `Serialized model int8+zlib: ...`
- `final_int8_zlib_roundtrip_exact ...`

## Notes on scope

This repo should only advertise evidence that is actually stored here.

- Cross-experiment tracking lives elsewhere conceptually and should not be treated as Gimlet evidence.
- Result notebooks for other experiments belong in their own repos.
- Old one-off or misleading proof artifacts should not be treated as current evidence for this experiment.

## Baseline Provenance

Based on `openai/parameter-golf` `train_gpt.py` as of 2026-03-27. Only the changes marked with `[HETERO]` comments differ from the official baseline.

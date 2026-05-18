# Real Run Checklist

This checklist is for the first serious paid run now that the Colab `300`-step and `600`-step proof runs have completed successfully.

## Goal

Use the proved experiment path to run a higher-confidence GPU job without rediscovering basic failures around:

- tokenizer/data paths
- silent wallclock truncation
- missing output artifacts
- ambiguous post-training stalls

## Proven Gate

The experiment has already cleared these gates:

- `300/300` end-to-end proof run on Colab/T4
- `600/600` end-to-end proof run on Colab/T4
- `final_model.int8.ptz` export works
- `final_summary.json` / `final_summary.md` writing works
- compressed artifact is well under the `16,000,000`-byte submission limit

## Preflight

Run this before any paid GPU job:

```bash
NPROC_PER_NODE=1 bash ./preflight_h100.sh
```

For an 8-GPU box:

```bash
NPROC_PER_NODE=8 bash ./preflight_h100.sh
```

Expected preflight output:

- `Python syntax: OK`
- `Train shards: ...`
- `Val shards: ...`
- `Preflight: OK`

## Step 1: 1xH100 Smoke

Use a clean single-GPU smoke first if you can.

```bash
RUN_ID=hetero_h100_smoke \
NPROC_PER_NODE=1 \
ITERATIONS=200 \
VAL_LOSS_EVERY=0 \
TRAIN_LOG_EVERY=10 \
WARMUP_STEPS=2 \
MAX_WALLCLOCK_SECONDS=0 \
VAL_MAX_TOKENS=65536 \
DATA_PATH=./data/datasets/fineweb10B_sp1024 \
TOKENIZER_PATH=./data/tokenizers/fineweb_1024_bpe.model \
bash ./preflight_h100.sh && \
torchrun --standalone --nproc_per_node=1 train_gpt.py
```

Smoke pass criteria:

- no OOM
- reaches `ITERATIONS`
- writes `final_model.pt`
- writes `final_model.int8.ptz`
- writes `final_summary.json`
- logs `phase:training_complete`
- logs `phase:roundtrip_eval_start`
- logs `phase:done`

## Step 2: Serious Run

If the smoke run is clean, launch the serious run.

On an 8xH100 machine:

```bash
RUN_ID=gimlet_hetero_real_$(date +%Y%m%d_%H%M%S) \
NPROC_PER_NODE=8 \
MAX_WALLCLOCK_SECONDS=0 \
DATA_PATH=./data/datasets/fineweb10B_sp1024 \
TOKENIZER_PATH=./data/tokenizers/fineweb_1024_bpe.model \
bash ./launch_h100.sh
```

## What To Watch

Early run:

- `world_size:... grad_accum_steps:...`
- `train_batch_tokens:... train_seq_len:...`
- `max_wallclock_seconds:0.000`
- `wallclock_mode:disabled (exact step target)`

End of training:

- `phase:training_complete`
- `phase:serialization_start`
- `phase:quantization_start`
- `phase:roundtrip_eval_start`
- `phase:done`

Artifacts:

- `final_model.pt`
- `final_model.int8.ptz`
- `final_summary.json`
- `final_summary.md`

## Success Criteria

A serious run counts as successful if it:

- exits with code `0`
- writes all four final artifacts
- includes exact total submission bytes in the log
- includes exact roundtrip `val_loss` and `val_bpb`
- stays below `16,000,000` total bytes

## Immediate Save List

After a successful run, save or copy:

- `logs/<run_id>.txt`
- `final_model.int8.ptz`
- `final_summary.json`
- `final_summary.md`

If the run is especially important, also save:

- a short result note under `records/`
- the exact launch command used

## Recommendation

Do not spend on another speculative run until the 1xH100 smoke is boring and clean.

The experiment itself is now proven enough to justify the spend. The remaining job is operational discipline, not research uncertainty.

# Gimlet-Hetero Colab 600-Step Proof Run

This folder captures the first clean end-to-end **600-step** T4 Colab proof run for the Gimlet heterogeneous precision/width experiment.

## Files

- `colab_gimlet_runbook_600_step_run.ipynb`: The exact Colab notebook session used for the successful 600-step run.

## Configuration

- Device: Tesla T4 (Colab)
- Iterations: `600`
- `TRAIN_SEQ_LEN=128`
- `TRAIN_BATCH_TOKENS=8192`
- `NO_COMPILE=1`
- `MAX_WALLCLOCK_SECONDS=0`
- `VAL_MAX_TOKENS=65536`

## Final Results

- Steps completed: `600/600`
- Capped-val loss at step 600: `3.5956`
- Capped-val BPB at step 600: `2.1259`
- Roundtrip val_loss: `4.61575699`
- Roundtrip val_bpb: `2.72911466`
- `final_model.int8.ptz`: `3,920,619` bytes
- `train_gpt.py`: `56,631` bytes
- Total submission size: `3,977,250` bytes
- 16 MB limit: `PASS`

## Why This Matters

This run is the checkpoint we wanted before spending more serious GPU time:

- the heterogeneous model trains cleanly through `600` steps
- post-training quantization/export completes successfully
- the compressed artifact is comfortably under the `16,000,000` byte rule
- the roundtrip evaluation path works end-to-end on a constrained Colab/T4 environment

## Notes

- Validation in this proof run was intentionally capped with `VAL_MAX_TOKENS=65536` so the T4 Colab run could finish in practical time.
- This is a **proof-of-concept / non-record evidence run**, not a final leaderboard-equivalent evaluation.

# Gimlet-Hetero Kaggle 600-Step Proof Run

This folder records the successful Kaggle portability proof for the Gimlet heterogeneous precision/width experiment.

## Summary

The Kaggle run confirmed that the workflow is portable beyond Colab and completes end-to-end on **Tesla T4** hardware.

## Environment

- Platform: Kaggle
- GPU: `Tesla T4 x2`
- Iterations: `600`
- `TRAIN_SEQ_LEN=128`
- `TRAIN_BATCH_TOKENS=8192`
- `NO_COMPILE=1`
- `MAX_WALLCLOCK_SECONDS=0`
- `VAL_MAX_TOKENS=65536`

## Verified Signals

- CUDA available: `True`
- Device count: `2`
- Device 0: `Tesla T4`
- Device 1: `Tesla T4`
- Reached `600/600`
- Reached `phase:done`
- Exit code: `0`

## Final Results

- Total submission size: `3,977,333` bytes
- Roundtrip val_loss: `4.61575699`
- Roundtrip val_bpb: `2.72911466`
- Artifact status: `final_model.int8.ptz` successfully produced

## Why This Matters

This is the portability checkpoint we wanted before spending more serious GPU money:

- Colab/T4 works
- Kaggle/T4 works
- the experiment is no longer tied to one fragile notebook environment
- the remaining risk is primarily operational/cost-related, not correctness-related

# Architecture — Gimlet Heterogeneous Precision Width Decoder

## Purpose

Parameter Golf experiment fork: vary MLP width and export precision by layer group (early / middle / late) and compare to a uniform baseline, within the 16MB artifact constraint.

This is a separate experiment lineage starting from the official OpenAI parameter-golf baseline, not a branch of any prior experimental codebase.

## Verified Now

- `train_gpt.py` contains the following baseline-derived components (unchanged from official):
  - Muon optimizer with Newton-Schulz orthogonalized matrix updates.
  - CastedLinear (fp32 weights, bf16 compute).
  - RoPE with configurable base frequency.
  - U-Net style skip connections (encoder/decoder halves).
  - Post-training int8 quantization with per-row scales and zlib export.
  - Sentencepiece-based tokenizer-agnostic BPB evaluation.
  - Distributed training via DDP + torchrun.
  - Wallclock-based warmdown and early stopping.

- `train_gpt.py` contains the following heterogeneous modifications (marked `[HETERO]`):
  - `NUM_LAYERS` default changed from 9 to 11.
  - `get_layer_config()` returns per-layer `(mlp_mult, export_clip_val)` for 3/5/3 split.
  - `MLP.__init__` accepts `float` mlp_mult; hidden dim computed as `int(mlp_mult * dim)`.
  - `GPT.__init__` constructs blocks with per-layer mlp_mult via `get_layer_config`.
  - `quantize_float_tensor` accepts `clip_val` parameter (default 127).
  - `quantize_state_dict_int8` accepts `clip_val_map` for per-tensor export precision.
  - Optimizer partitioning: Muon on middle MLP matrices only; Adam on all other matrices.
  - New `ADAM_MATRIX_LR` hyperparameter for non-Muon matrix params.
  - Heterogeneous config logged per-block at startup.

## Feasibility Summary

- **The architecture changes are structurally minimal.** Per-layer MLP width requires only `float` typing in `MLP.__init__` and per-index config in `GPT.__init__`. No forward-pass logic changes beyond hidden dimension size.
- **The export path modification is self-contained.** Heterogeneous `clip_val` is threaded through `quantize_float_tensor` → `quantize_state_dict_int8` without changing `dequantize_state_dict_int8`. The scale vector already encodes the range, so dequantization is correct without modification.
- **The optimizer split is explicit.** Parameter group construction iterates over blocks by index, checking whether each block is in the middle group before assigning to Muon vs Adam. This is not a heuristic — it's a direct index comparison.
- **PTQ-only v1.** Precision heterogeneity is applied only at the post-training export step. This keeps the training loop identical to baseline except for optimizer grouping. No training-time QAT.

## Current Evidence

- **Colab feasibility runbook (`colab_gimlet_runbook.ipynb`).** Optional **checkpoint-only** staging on a small iteration grid: verifies the modified `train_gpt.py` runs on Colab GPU, writes checkpoints and `progress.csv`, and passes the runbook’s **trend / completion gates**. This does **not** validate heterogeneous PTQ quality, 16MB artifact size, or competitive val_bpb — only that the code path and short-run training dynamics look sane in that environment.
- **No full H100 / leaderboard-equivalent runs** are implied by the runbook. Full `torchrun` jobs, artifact export checks, and baseline comparisons remain the real proof bar.
- **Import/syntax correctness** is verifiable locally; CUDA behavior can be partially exercised via the runbook or a 1×GPU smoke test.

## Not Yet Proven

- Whether the 11-layer heterogeneous model fits under the 16MB artifact limit after Int4/Int6 PTQ + zlib compression.
- Whether Int4 PTQ (clip_val=7, 15 levels) on middle MLP weights causes unacceptable accuracy degradation without training-time QAT.
- Whether Muon on only middle MLP matrices (vs. all block matrices) maintains healthy training dynamics.
- Whether `ADAM_MATRIX_LR=0.001` is a reasonable default for early/late MLP + attention matrices.
- Whether the 3/5/3 split (as opposed to other groupings) is meaningfully better than uniform allocation.
- Actual val_bpb, training wall-clock, and peak memory on target hardware.

## Risks / Open Questions

- **Artifact size is the primary gating risk.** The model has ~30M+ float params (vs ~15M in the 9-layer baseline). Even with aggressive Int4 compression on middle layers, the zlib-compressed artifact may exceed 16MB. If it does, the model_dim or layer count must be reduced.
- **PTQ-only Int4 may be insufficient.** 15 discrete levels per weight is aggressive for post-training quantization. The baseline uses 255 levels (int8). If middle-layer accuracy drops significantly, training-time QAT will need to be added in a future version.
- **Optimizer LR sensitivity.** Muon and Adam have different effective learning rate scales. The default `ADAM_MATRIX_LR=0.001` is an untested starting point.
- **No baseline comparison yet.** Without running the 9-layer baseline and this 11-layer variant on the same hardware, we cannot measure the delta.

## Next Concrete Step

Use the Colab runbook for a **cheap** first pass if credits are limited; then run a 1xH100 smoke test with reduced iterations (e.g., `ITERATIONS=200 VAL_LOSS_EVERY=0`) to verify:
1. The model constructs and compiles correctly on CUDA.
2. The optimizer groups are populated as expected (check log output).
3. The export path produces a valid compressed artifact.
4. The artifact round-trips through dequantize and evaluates without error.

Then run a full training job and compare val_bpb and artifact size against the baseline.

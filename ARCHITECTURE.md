# Architecture Status: parameter-golf-gimlet-hetero

## Purpose

Experimental repo implementing a heterogeneous-precision / heterogeneous-width decoder for the Parameter Golf challenge. Tests whether allocating different MLP widths and export precision budgets to different layer groups (early/middle/late) improves val_bpb compared to a uniform allocation, within the 16MB artifact constraint.

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
  - Optimizer partitioning: Muon on middle MLP matrices only; AdamW on all other matrices.
  - New `ADAMW_MATRIX_LR` hyperparameter for non-Muon matrix params.
  - Heterogeneous config logged per-block at startup.

## Feasibility Summary

- **The architecture changes are structurally minimal.** Per-layer MLP width requires only `float` typing in `MLP.__init__` and per-index config in `GPT.__init__`. No forward-pass logic changes beyond hidden dimension size.
- **The export path modification is self-contained.** Heterogeneous `clip_val` is threaded through `quantize_float_tensor` → `quantize_state_dict_int8` without changing `dequantize_state_dict_int8`. The scale vector already encodes the range, so dequantization is correct without modification.
- **The optimizer split is explicit.** Parameter group construction iterates over blocks by index, checking whether each block is in the middle group before assigning to Muon vs AdamW. This is not a heuristic — it's a direct index comparison.
- **No training-time quantization (v1).** Precision heterogeneity is applied only at the post-training export step. This keeps the training loop identical to baseline except for optimizer grouping. True QAT is deferred to a future experiment.

## Current Evidence

- **No training runs have been executed.** There are no val_bpb measurements, artifact sizes, or runtime benchmarks for this architecture.
- **No external results.** No friend-runs or preliminary numbers exist for this exact configuration.
- **Import/syntax correctness is verifiable locally** but has not been verified on CUDA hardware.

## Not Yet Proven

- Whether the 11-layer heterogeneous model fits under the 16MB artifact limit after Int4/Int6 PTQ + zlib compression.
- Whether Int4 PTQ (clip_val=7, 15 levels) on middle MLP weights causes unacceptable accuracy degradation without training-time QAT.
- Whether Muon on only middle MLP matrices (vs. all block matrices) maintains healthy training dynamics.
- Whether `ADAMW_MATRIX_LR=0.001` is a reasonable default for early/late MLP + attention matrices.
- Whether the 3/5/3 split (as opposed to other groupings) is meaningfully better than uniform allocation.
- Actual val_bpb, training wall-clock, and peak memory on target hardware.

## Risks / Open Questions

- **Artifact size is the primary gating risk.** The model has ~30M+ float params (vs ~15M in the 9-layer baseline). Even with aggressive Int4 compression on middle layers, the zlib-compressed artifact may exceed 16MB. If it does, the model_dim or layer count must be reduced.
- **PTQ-only Int4 may be insufficient.** 15 discrete levels per weight is aggressive for post-training quantization. The baseline uses 255 levels (int8). If middle-layer accuracy drops significantly, training-time QAT will need to be added.
- **Optimizer LR sensitivity.** Muon and Adam have different effective learning rate scales. The default `ADAMW_MATRIX_LR=0.001` is an untested starting point.
- **No baseline comparison yet.** Without running the 9-layer baseline and this 11-layer variant on the same hardware, we cannot measure the delta.

## Next Concrete Step

Run a 1xH100 smoke test with reduced iterations (e.g., `ITERATIONS=200 VAL_LOSS_EVERY=0`) to verify:
1. The model constructs and compiles correctly on CUDA.
2. The optimizer groups are populated as expected (check log output).
3. The export path produces a valid compressed artifact.
4. The artifact round-trips through dequantize and evaluates without error.

Then run a full training job and compare val_bpb and artifact size against the baseline.

# RunPod Readiness Standard

This repo is the reference implementation for what "RunPod ready" should mean for other Parameter Golf experiment repos.

The point of this standard is to separate **experiment quality** from **operational readiness**.

- Experiment quality asks: is this idea actually good?
- Operational readiness asks: is this safe to spend money on?

An experiment can be weak scientifically and still be operationally ready. Gimlet-Hetero is useful as a reference because the workflow is now much more stable and auditable than when the project started.

## Required Standard

### 1. Exact-step behavior

- `MAX_WALLCLOCK_SECONDS=0` by default, or an equally explicit exact-step mode
- no silent wallclock truncation during proof or paid runs

### 2. Cheap proof-run support

- `VAL_MAX_TOKENS` or an equivalent validation cap
- a practical way to run short proof jobs without waiting forever on full final eval

### 3. End-of-run phase visibility

The trainer should log clearly when it enters the post-training stages:

- `phase:training_complete`
- `phase:serialization_start`
- `phase:quantization_start`
- `phase:roundtrip_eval_start`
- `phase:done`

### 4. Machine-readable outputs

The trainer should write:

- `final_summary.json`
- `final_summary.md`

These should contain enough information to recover the final result without manually scraping the log.

### 5. Artifact path proven

The end-to-end export flow must actually work:

- `final_model.pt`
- `final_model.int8.ptz`
- roundtrip validation

Do not call a repo "ready" if the training loop works but export is still unproven.

### 6. Preflight

Each experiment repo should have a fast-fail script similar to:

- `preflight_h100.sh`

At minimum it should verify:

- required files exist
- tokenizer path exists
- data shards exist
- Python syntax is valid
- visible GPU count matches expectation
- GPU name roughly matches the intended hardware

### 7. Launch script

Each repo should have a launch script similar to:

- `launch_h100.sh`

It should make the important environment explicit and call preflight before `torchrun`.

### 8. Clean proof runbook

Each repo should have a cleaned notebook or runbook for proof runs.

The goal is not to preserve every debugging detour. The goal is to preserve the clean path that actually works.

### 9. Saved records

Proof notebooks and result summaries should be saved under `records/` so evidence does not get stranded in ephemeral notebook sessions or downloads folders.

### 10. Spend discipline

Each repo should document a cheap gate before a serious paid run.

At minimum:

- 1xGPU smoke first
- only then a larger paid run

## Practical Test

Before calling a repo "RunPod ready", we should be able to answer "yes" to all of these:

1. Can it complete an exact-step proof run without surprise truncation?
2. Can it produce the quantized artifact end-to-end?
3. Can we tell where it is if it appears to stall?
4. Can we recover final metrics from summary files?
5. Can we fail fast on missing paths or bad hardware setup?
6. Do we have a clean proof notebook and saved evidence?

If any of those answers is "no", the repo is not ready for paid spend yet.

## How To Use This

For future experiment repos:

1. bring them up to this operational standard
2. keep proof evidence in `records/`
3. only then judge whether the experiment itself deserves paid compute

This keeps us from confusing "interesting idea" with "safe to spend money on."

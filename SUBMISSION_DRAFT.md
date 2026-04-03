# Gimlet-Hetero Non-Record Submission Draft

## Summary

Gimlet-Hetero is a non-record Parameter Golf submission that explores **layer-wise heterogeneous width and export precision** rather than a uniform budget across all transformer blocks. The core idea is to allocate more capacity to the middle layers while preserving tighter higher-precision boundary layers:

- Early layers: `mlp_mult=3.0`, Int6 export
- Middle layers: `mlp_mult=4.5`, Int4 export
- Late layers: `mlp_mult=3.0`, Int6 export
- Attention projections remain Int6 throughout
- Muon is restricted to middle-layer MLP matrices, with Adam elsewhere

This is intended as an interesting architectural submission rather than a claim of state-of-the-art performance.

## 600-Step Proof Run

The strongest completed proof run so far is a Colab Tesla T4 run with:

- `600/600` steps completed
- `TRAIN_SEQ_LEN=128`
- `TRAIN_BATCH_TOKENS=8192`
- `NO_COMPILE=1`
- capped validation with `VAL_MAX_TOKENS=65536`

### Results

- Capped-val loss at step 600: `3.5956`
- Capped-val BPB at step 600: `2.1259`
- Quantized roundtrip val_loss: `4.61575699`
- Quantized roundtrip val_bpb: `2.72911466`
- `final_model.int8.ptz`: `3,920,619` bytes
- `train_gpt.py`: `56,631` bytes
- Total submission size: `3,977,250` bytes

This is comfortably below the `16,000,000`-byte submission limit.

## Why This Is Interesting

- It demonstrates a viable **non-uniform parameter budget** across the depth of the network.
- It keeps the submission artifact far below the size limit while still supporting a wider middle “engine.”
- It explores a mixed optimizer routing strategy instead of applying the same update rule uniformly to all matrix parameters.

## Caveats

- The 600-step proof run used a capped validation slice for Colab/T4 practicality, so it should be described as a proof-of-concept result rather than a final full-validation benchmark.
- The current result demonstrates viability, not optimality.
- A larger paid run may still improve quality, but the experiment is now clearly stable enough to justify that next step.

## Evidence

- 600-step run notebook: [records/colab_600_step_run/colab_gimlet_runbook_600_step_run.ipynb](/Users/jmoncayopursuit.org/Desktop/parameter-golf-gimlet-hetero/records/colab_600_step_run/colab_gimlet_runbook_600_step_run.ipynb)
- 600-step run summary: [records/colab_600_step_run/README.md](/Users/jmoncayopursuit.org/Desktop/parameter-golf-gimlet-hetero/records/colab_600_step_run/README.md)

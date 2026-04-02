# Gimlet-Hetero: Layer-wise Heterogeneous Width + Precision

**Non-record submission**

**Idea**: Named after Gimlet Labs Inc. (authors of "Efficient and Scalable Agentic AI with Heterogeneous Systems"). I conceptually reapplied their systems-level heterogeneous methodology to a small-parameter network: instead of uniform mixed precision, I allocate parameters intelligently across layers:
- Early (layers 0-2) and Late (8-10): `mlp_mult=3.0` + Int6
- Middle (layers 3-7): `mlp_mult=4.5` + Int4 (wide "engine")
- All attention stays Int6
- Muon optimizer only on middle MLP matrices, Adam elsewhere

**Results** (300 steps, seed 123):

- Final artifact size: **~0.049 MB** (15.95 MB headroom under 16 MB limit)
- Train loss: 4.1060
- Mini val BPB: 2.4852

This demonstrates that heterogeneous layer budgeting is viable and keeps the model extremely small while allowing aggressive widening in the middle layers where capacity matters most.

Future work: Longer training + sliding-window BPB + combining with Bayesian/TT adapter.

**Repo**: https://github.com/jmoncayo-pursuit/parameter-golf-gimlet-hetero

## Non-Record Submission Justification

Per the OpenAI Parameter Golf rules: _"Submissions are also open to unique and interesting approaches that might not beat the existing SOTA... we strongly encourage participants to submit implementations for weird or out-of-the-box ideas, in-progress or unoptimized solutions."_

This project leverages "layer-wise heterogeneous budgeting" to precisely fit the constraints of the 16MB artifact limit while exploring unique architectural ideas, strongly aligning with these non-record submission guidelines.

Specifically:
- **Novel Architecture:** Rather than uniform quantization, I selectively dedicate broader widths (MLP multiplier 4.5) and lower precision (Int4) to the middle "engine" of the network, maintaining Int6 on the outer layers.
- **Massive Headroom Showcase:** By producing a `~0.049 MB` artifact, this serves as a baseline proof-of-concept for how aggressively I can widen the middle layers before exhausting the 16MB limit.
- **Micro-Targeted Optimizers:** I implement layer-specific routing for optimization (e.g., restricting Muon specifically to the middle MLPs where the network is widest).
- **Proven Viability:** Smooth, downward trending train loss (dropping to `4.1060` by step 300) and functional localized evaluation (`2.4852` BPB) empirically validate that the approach is fundamentally sound.

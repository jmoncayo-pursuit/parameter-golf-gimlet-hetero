# Implementation plan — Gimlet Heterogeneous Precision Width Decoder

As-built reference for `parameter-golf-gimlet-hetero`: architecture, training, and export configuration.

## 1. Repository purpose
Decoder with per-group MLP width and export precision (e.g. wider middle at Int4 export, boundaries at Int6). Hypothesis: that allocation can match or beat a uniform baseline within the 16MB artifact constraint.

## 2. Model Architecture: 11-Layer Heterogeneous Decoder
The model uses 11 transformer blocks to support a symmetrical 3/5/3 split.

| Layer Group | Blocks | Width (`mlp_mult`) | Export Precision |
| :--- | :--- | :--- | :--- |
| **Early** | 0-2 | 3.0x | Int6 (`clip_val=31`) |
| **Middle** | 3-7 | 4.5x | Int4 (`clip_val=7`) |
| **Late** | 8-10 | 3.0x | Int6 (`clip_val=31`) |

- **Attention Projections:** All attention matrices (`c_q`, `c_k`, `c_v`, `proj`) use Int6 (`clip_val=31`) across all layers.
- **Hidden Dim Calculation:** `hidden = int(mlp_mult * model_dim)`.

## 3. Precision Strategy: PTQ-Only v1
Precision heterogeneity is applied **only at the post-training export step**.
- **Training:** Standard full-precision (bf16/fp32) using the official baseline's `CastedLinear`. No fake quantization or QAT is performed in this version.
- **Export Clipping:** The `quantize_state_dict_int8` function is modified to accept a `clip_val_map`, modulating the effective bit-depth per tensor during serialization.

## 4. Optimizer Partitioning
The parameters are split into specific optimizer groups to handle different learning roles:

| Parameter Group | Optimizer | Notes |
| :--- | :--- | :--- |
| **Middle MLP Matrices** | Muon | Specifically `fc` and `proj` weights for blocks 3-7. |
| **Other Matrices** | Adam | Early/late MLP matrices and all attention projections. |
| **Embeddings & Head** | Adam | Token embeddings and output head (if untied). |
| **Scalars & Control** | Adam | Norms, scales, biases, and skip weights. |

## 5. Key Files
- `train_gpt.py`: Core training script with `[HETERO]` modifications.
- `ARCHITECTURE.md`: Technical details and evidence-ladder status.
- `README.md`: High-level purpose and systems-level inspiration.
- `launch_h100.sh`: 8xH100 execution script.

## 6. Open Risks / Unknowns
- **Artifact Size:** The 11-layer model with 4.5x middle MLPs has significantly more parameters than the baseline. Its ability to fit in 16MB depends on the compressibility of Int4 middle layers.
- **PTQ Degradation:** Quantizing middle layers to 15 levels (Int4) without QAT is aggressive and may cause accuracy loss.
- **Learning Rate Balance:** The relative learning rates between Muon and Adam for the different matrix groups have not been tuned.

## 7. Verification Steps
- **Syntax Check:** Python syntax verified via `ast.parse`.
- **Logic Check:** Layer config mapping (3/5/3) verified via internal unit test.
- **Import Check:** Standard baseline imports maintained.
- **Next Step:** A 1xH100 smoke test to verify OOM safety and export validity.

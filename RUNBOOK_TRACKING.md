# Colab runbooks — tracking

Homogenized runbooks share **`progress.csv`** columns: `tag`, `status`, `last_step`, `total_steps`, `last_loss`, `step_avg_ms`, `ckpt_bytes`, `notes`. Staging checks: **steps match tag** (`last_step` = `total_steps` = requested iters), **loss stays healthy when you train longer** (seed 42: 100→200→300, each `last_loss` ≤ the previous), **same `ckpt_bytes` on every OK run** for the same architecture. Plus aggregate line + mini val where the notebook has them.

**Column key (narrow headers):** **Colab** = done? · **Jobs** = all planned runs `OK` in CSV (**Pass · n/m**) · **Step(A)** = steps match tag (Stage A) · **Loss(A)** = loss ok when extending runs (Stage A) · **Ckpt** = checkpoint byte size consistent · **Agg** = aggregate signal string · **MiniV** = mini val · **RP** / **RP res** = Runpod ready / Runpod result.

**Legend:** **Pass** = feasibility check passed · **—** = not run / N/A. **`n/m`** = `n` rows with `status=OK` out of `m` planned jobs. **RP Yes** only after Colab on the **current** notebook revision looks good.

| Exp | Notebook · repo | Colab | Jobs | Step(A) | Loss(A) | Ckpt | Agg | MiniV | RP? | RP res |
|:---|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| Gimlet hetero | `colab_gimlet_runbook.ipynb` · **this repo** | Yes | Pass · 7/7 | Pass | Pass | Pass · 120728183 B ×7 | `BASELINE_CHECKPOINT_SIGNAL_STRONG: YES` | ~2.49 bpb | Yes | |
| QAT Int4, Int6 GPS, and MLP | `colab_int6_gps_int4_mlp_train.ipynb` · `parameter-golf` | No | — | — | — | — | — | — | No — Colab first | |
| QAT staged train (legacy name) | `colab_turboquant_mse_surrogate_quant_probe.ipynb` · `parameter-golf` | No | — | — | — | — | — | — | No — Colab first | |
| Noisy QAT Bayesian | `colab_noisy_qat_bayesian_runbook.ipynb` · `parameter-golf-noisy-qat-bayesian` | No | — | — | — | — | — | — | No — Colab first | |
| TT adapter eval | `colab_bayesian_backoff_cache_tt_adapter_launcher.ipynb` · `parameter-golf` | No | — | — | — | — | — | — | No — Colab first · needs baseline ckpt | |

_Update when you finish each Colab pass; fill **RP res** after paid runs._

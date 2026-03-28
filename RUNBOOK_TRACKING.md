# Colab runbooks — tracking

Homogenized runbooks share **`progress.csv`** columns: `tag`, `status`, `last_step`, `total_steps`, `last_loss`, `step_avg_ms`, `ckpt_bytes`, `notes`. Staging gates use **step completion** (`last_step` = `total_steps` = requested iters), **train-loss trend** (100→200→300 for Stage A), and (where present) **aggregate signal** + **mini val**.

**Runpod:** mark **Yes** only after **this** Colab runbook has been executed on the **current** notebook revision and you are satisfied with the row. Until then use **No — Colab first**.

| Experiment | Notebook · repo | Colab done? | `progress` OK rows | Steps complete | Loss trend (A) | `ckpt_bytes` | Aggregate signal | Mini val | Runpod ready | Runpod result |
|:---|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| Gimlet hetero | `colab_gimlet_runbook.ipynb` · **this repo** | Yes | 7 | Y | Y | stable (~120.7M) | `BASELINE_CHECKPOINT_SIGNAL_STRONG: YES` | ~2.49 bpb | Yes | |
| QAT Int4, Int6 GPS, and MLP | `colab_int6_gps_int4_mlp_train.ipynb` · `parameter-golf` | No | — | — | — | — | — | — | No — Colab first | |
| QAT staged train (legacy name) | `colab_turboquant_mse_surrogate_quant_probe.ipynb` · `parameter-golf` | No | — | — | — | — | — | — | No — Colab first | |
| Noisy QAT Bayesian | `colab_noisy_qat_bayesian_runbook.ipynb` · `parameter-golf-noisy-qat-bayesian` | No | — | — | — | — | — | — | No — Colab first | |
| TT adapter eval | `colab_bayesian_backoff_cache_tt_adapter_launcher.ipynb` · `parameter-golf` | No | — | — | — | — | — | — | No — Colab first · needs baseline ckpt | |

_Update this file when you finish each Colab pass; fill **Runpod result** after paid runs._

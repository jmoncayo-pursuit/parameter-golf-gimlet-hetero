# Colab runbooks — tracking

Shared **`progress.csv`** fields: `tag`, `status`, `last_step`, `total_steps`, `last_loss`, `step_avg_ms`, `ckpt_bytes`, `notes`. Feasibility = jobs finish **`OK`**, **steps match** the tag, **loss does not get worse** when extending seed-42 runs (100→200→300), **`ckpt_bytes` identical** across those OK rows, plus aggregate + mini-val lines when the notebook prints them.

**Legend:** **Pass** / **Done** = good · **—** = not run. **`n/m`** = `n` OK rows vs `m` planned jobs in that runbook. **Runpod Yes** only after **this** notebook revision has a Colab pass you accept.

## Summary

| Experiment | Colab | Runpod? | Runpod result |
|:---|:---:|:---:|:---|
| Gimlet hetero | Done | Yes | |
| QAT Int4, Int6 GPS, and MLP | — | No — Colab first | |
| QAT staged train (legacy nb name) | — | No — Colab first | |
| Noisy QAT Bayesian | — | No — Colab first | |
| TT adapter eval | — | No — Colab first | |

## Runbook paths

| Experiment | Notebook · repo |
|:---|:---|
| Gimlet hetero | `colab_gimlet_runbook.ipynb` · **this repo** |
| QAT Int4, Int6 GPS, and MLP | `colab_int6_gps_int4_mlp_train.ipynb` · `parameter-golf` |
| QAT staged train | `colab_turboquant_mse_surrogate_quant_probe.ipynb` · `parameter-golf` |
| Noisy QAT Bayesian | `colab_noisy_qat_bayesian_runbook.ipynb` · `parameter-golf-noisy-qat-bayesian` |
| TT adapter eval | `colab_bayesian_backoff_cache_tt_adapter_launcher.ipynb` · `parameter-golf` (needs baseline ckpt) |

## Gimlet — Colab detail

_Add a matching **Colab detail** subsection when another experiment finishes._

| Check | Result |
|:---|:---|
| All jobs OK | Pass · **7/7** (3 Stage A + 4 Stage B) |
| Steps match tag (A) | Pass |
| Loss ok on longer runs (A) | Pass |
| Checkpoint size | Pass · **120728183** B every run |
| Aggregate line | `BASELINE_CHECKPOINT_SIGNAL_STRONG: YES` |
| Mini val | ~**2.49** bpb |

_Update summary + add a detail block per experiment; fill **Runpod result** after paid runs._

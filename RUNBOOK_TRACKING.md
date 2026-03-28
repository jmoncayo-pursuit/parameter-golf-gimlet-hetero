# Colab runbooks — tracking

Shared **`progress.csv`** fields: `tag`, `status`, `last_step`, `total_steps`, `last_loss`, `step_avg_ms`, `ckpt_bytes`, `notes`. Feasibility = jobs finish **`OK`**, **steps match** the tag, **loss does not worsen** extending seed-42 runs (100→200→300), **same `ckpt_bytes`** across OK rows, plus the notebook’s **summary gate** and **mini val** when present.

**Experiment** links = GitHub **repo / branch** the runbook targets. `.ipynb` files may live in [`parameter-golf`](https://github.com/jmoncayo-pursuit/parameter-golf) or **this repo** (Gimlet). Branches: [parameter-golf-qat-int4/branches](https://github.com/jmoncayo-pursuit/parameter-golf-qat-int4/branches).

**How to read the table**

| Column | Meaning |
|:---|:---|
| **Colab done** | Finished a Colab pass on the current notebook revision? (**✓** = yes) |
| **Jobs pass** | Count of `progress.csv` rows with `status=OK` vs planned jobs (**7/7** = every slot succeeded). *Use the fraction here, not ✓.* |
| **Stage A · steps** | For Stage A tags, `last_step` = `total_steps` = requested iters. |
| **Stage A · loss** | Loss does not get worse from 100→200→300 steps on seed 42. |
| **Ckpt stable** | Same checkpoint byte size on every OK run. *Gimlet: 120728183 B × 7.* |
| **Summary strong** | Notebook aggregate “strong signal” (Gimlet cell 5 = `BASELINE_CHECKPOINT_SIGNAL_STRONG`). |
| **Mini bpb** | Mini val bits/byte when run (**—** if skipped). |
| **Runpod ready** | OK to spend Runpod credits after Colab? (**✓** = yes; otherwise short reason). Header in main table: **Runpod** / **Ready?** on two lines. |

**Values:** **✓** = pass / yes · **—** = not run · Plain text = blocked (e.g. `No — Colab first`).

| Experiment | Colab done | Jobs pass | Stage A · steps | Stage A · loss | Ckpt stable | Summary strong | Mini bpb | Runpod<br>Ready? |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| [Gimlet hetero](https://github.com/jmoncayo-pursuit/parameter-golf-gimlet-hetero) | ✓ | 7/7 | ✓ | ✓ | ✓ | ✓ | 2.49 | ✓ |
| [QAT Int4, Int6 GPS, and MLP](https://github.com/jmoncayo-pursuit/parameter-golf-qat-int4/tree/qat-int4-int6-gps-mlp) | — | — | — | — | — | — | — | No — Colab first |
| [QAT staged train (legacy Colab name)](https://github.com/jmoncayo-pursuit/parameter-golf-qat-int4/tree/research/turboquant-probe) | — | — | — | — | — | — | — | No — Colab first |
| [Noisy QAT Bayesian](https://github.com/jmoncayo-pursuit/parameter-golf-qat-int4/tree/noisy-qat-bayesian) | — | — | — | — | — | — | — | No — Colab first |
| [TT adapter eval](https://github.com/jmoncayo-pursuit/parameter-golf-qat-int4/tree/bayesian-backoff-cache-tt-adapter) | — | — | — | — | — | — | — | No — need baseline ckpt |

_Add a one-line **Runpod run** note below the table when you have paid-run results._

_Update after each Colab pass._

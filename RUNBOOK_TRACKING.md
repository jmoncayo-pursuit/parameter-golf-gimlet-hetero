# Colab runbooks — tracking

Shared **`progress.csv`** fields: `tag`, `status`, `last_step`, `total_steps`, `last_loss`, `step_avg_ms`, `ckpt_bytes`, `notes`. Feasibility = jobs finish **`OK`**, **steps match** the tag, **loss does not worsen** extending seed-42 runs (100→200→300), **same `ckpt_bytes`** across OK rows, plus the notebook’s **summary gate** and **mini val** when present.

**Experiment** links = GitHub **repo / branch** the runbook targets. `.ipynb` files may live in [`parameter-golf`](https://github.com/jmoncayo-pursuit/parameter-golf) or **this repo** (Gimlet). Branches: [parameter-golf-qat-int4/branches](https://github.com/jmoncayo-pursuit/parameter-golf-qat-int4/branches).

**Local folders (mirror GitHub):** Keep **one** clone of [`parameter-golf-qat-int4`](https://github.com/jmoncayo-pursuit/parameter-golf-qat-int4) (e.g. `~/Desktop/parameter-golf-qat-int4`) and use **`git checkout` / worktrees** for the three lines that share that remote: **`qat-int4-int6-gps-mlp`**, **`turboquant-experiment`**, **`bayesian-backoff-cache-tt-adapter`**. Keep **two** separate repo folders for the standalone experiments: **this repo** ([`parameter-golf-gimlet-hetero`](https://github.com/jmoncayo-pursuit/parameter-golf-gimlet-hetero)) and [`parameter-golf-noisy-qat-bayesian`](https://github.com/jmoncayo-pursuit/parameter-golf-noisy-qat-bayesian) (architecture + runbooks + tests live there). Shared Colab drivers may still sit under a local [`parameter-golf`](https://github.com/openai/parameter-golf) tree; that is not a third “experiment home” in the same sense.

**How to read the table**

| Column | Meaning |
|:---|:---|
| **Colab done** | Finished a Colab pass on the current notebook revision? (**✓** = yes) |
| **Jobs pass** | Count of `progress.csv` rows with `status=OK` vs planned jobs (**7/7** = every slot succeeded). *Use the fraction here, not ✓.* |
| **Stage A** | Stage A tags: steps match (`last_step` = `total_steps`), and seed-42 loss does not worsen 100→200→300. |
| **Ckpt stable** | Same checkpoint byte size on every OK run. *Gimlet: 120728183 B × 7.* |
| **Summary strong** | Notebook aggregate “strong signal” (Gimlet cell 5 = `BASELINE_CHECKPOINT_SIGNAL_STRONG`). |
| **Mini bpb** | Mini val bits/byte when run (**—** if skipped). |
| **Runpod** | **✓** = OK to spend credits after Colab; else short reason (e.g. `No — Colab first`). |

**Values:** **✓** = pass / yes · **—** = not run · Plain text = blocked (e.g. `No — Colab first`).

| Experiment | Colab done | Jobs pass | Stage A | Ckpt stable | Summary strong | Mini bpb | Runpod |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| [Gimlet hetero](https://github.com/jmoncayo-pursuit/parameter-golf-gimlet-hetero) | ✓ | 7/7 | ✓ | ✓ | ✓ | 2.49 | ✓ |
| [Noisy QAT Bayesian](https://github.com/jmoncayo-pursuit/parameter-golf-noisy-qat-bayesian) | — | — | — | — | — | — | No — Colab first |
| [TurboQuant](https://github.com/jmoncayo-pursuit/parameter-golf-qat-int4/tree/turboquant-experiment) | — | — | — | — | — | — | No — Colab first |
| [Bayesian backoff cache + TT adapter](https://github.com/jmoncayo-pursuit/parameter-golf-qat-int4/tree/bayesian-backoff-cache-tt-adapter) | — | — | — | — | — | — | No — need baseline ckpt |
| [QAT Int4, Int6 GPS, and MLP](https://github.com/jmoncayo-pursuit/parameter-golf-qat-int4/tree/qat-int4-int6-gps-mlp) | — | — | — | — | — | — | No — Colab first |

_Add a one-line **Runpod run** note below the table when you have paid-run results._

_Update after each Colab pass._

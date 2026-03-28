# Colab runbooks — tracking

Homogenized runbooks share **`progress.csv`** columns: `tag`, `status`, `last_step`, `total_steps`, `last_loss`, `step_avg_ms`, `ckpt_bytes`, `notes`. Staging checks: **steps match tag** (`last_step` = `total_steps` = requested iters), **loss stays healthy when you train longer** (seed 42: 100→200→300, each `last_loss` ≤ the previous), **same `ckpt_bytes` on every OK run** for the same architecture. Plus aggregate line + mini val where the notebook has them.

**Column key:** **Colab** = done? · **Jobs** = all planned runs `OK` in CSV (**Pass · n/m**) · **Step(A)** = steps match tag (Stage A) · **Loss(A)** = loss ok when extending runs (Stage A) · **Ckpt** = checkpoint byte size consistent · **Agg** = aggregate signal string · **MiniV** = mini val · **RP?** / **RP res** = Runpod ready / result.

**Legend:** **Pass** = feasibility check passed · **—** = not run / N/A. **`n/m`** = `n` rows with `status=OK` out of `m` planned jobs. **RP Yes** only after Colab on the **current** notebook revision looks good.

**Experiment** names link to the GitHub **repo / branch** the runbook targets. Colab `.ipynb` files may live in [`parameter-golf`](https://github.com/jmoncayo-pursuit/parameter-golf) or **this repo** (Gimlet).

| Exp | Colab | Jobs | Step(A) | Loss(A) | Ckpt | Agg | MiniV | RP? | RP res |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| [Gimlet hetero](https://github.com/jmoncayo-pursuit/parameter-golf-gimlet-hetero) | Yes | Pass · 7/7 | Pass | Pass | Pass · 120728183 B ×7 | `BASELINE_CHECKPOINT_SIGNAL_STRONG: YES` | ~2.49 bpb | Yes | |
| [QAT Int4, Int6 GPS, and MLP](https://github.com/jmoncayo-pursuit/parameter-golf-qat-int4/tree/qat-int4-int6-gps-mlp) | No | — | — | — | — | — | — | No — Colab first | |
| [QAT staged train (legacy Colab name)](https://github.com/jmoncayo-pursuit/parameter-golf-qat-int4/tree/research/turboquant-probe) | No | — | — | — | — | — | — | No — Colab first | |
| [Noisy QAT Bayesian](https://github.com/jmoncayo-pursuit/parameter-golf-qat-int4/tree/noisy-qat-bayesian) | No | — | — | — | — | — | — | No — Colab first | |
| [TT adapter eval](https://github.com/jmoncayo-pursuit/parameter-golf-qat-int4/tree/bayesian-backoff-cache-tt-adapter) | No | — | — | — | — | — | — | No — Colab first · needs baseline ckpt | |

Branches for `parameter-golf-qat-int4`: [github.com/jmoncayo-pursuit/parameter-golf-qat-int4/branches](https://github.com/jmoncayo-pursuit/parameter-golf-qat-int4/branches).

_Update when you finish each Colab pass; fill **RP res** after paid runs._

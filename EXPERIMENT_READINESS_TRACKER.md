# Experiment Readiness Tracker

This tracker is an inventory of Parameter Golf experiments and their **canonical working locations**.

It is intentionally about **operational readiness**, not leaderboard quality.

Use [RUNPOD_READINESS_STANDARD.md](/Users/jmoncayopursuit.org/Desktop/parameter-golf-gimlet-hetero/RUNPOD_READINESS_STANDARD.md) as the rubric when bringing a repo up to Gimlet-level readiness.

## Key

- **Full Repo** = standalone repository with its own history
- **Branch** = experiment lives inside a larger repo
- **Operational Gold Standard** = already at the Gimlet-Hetero level of readiness
- **Needs Readiness Pass** = should be brought up to the Gimlet standard before paid spend
- **Partial** = some evidence exists, but readiness has not been audited end-to-end

## Tracker

| Experiment Name | Canonical Location | Type | Readiness Status | Notes |
|:---|:---|:---:|:---|:---|
| Gimlet-Hetero | [parameter-golf-gimlet-hetero](/Users/jmoncayopursuit.org/Desktop/parameter-golf-gimlet-hetero) | Full Repo | Operational Gold Standard | Clean workflow, phase markers, summaries, preflight, Colab proof, Kaggle proof |
| Uniform Int4@4.0 | `parameter-golf-qat-int4` -> `qat-int4-int6-gps-mlp` | Branch | Needs Readiness Pass | Highest-priority model experiment to bring up to Gimlet standard next |
| Bayesian Backoff + TT Adapter | `parameter-golf-qat-int4` -> `bayesian-backoff-cache-tt-adapter` | Branch | Needs Readiness Pass | Strong secondary candidate |
| Noisy QAT Bayesian | [parameter-golf-noisy-qat-bayesian](/Users/jmoncayopursuit.org/Desktop/parameter-golf-noisy-qat-bayesian) | Full Repo | Partial | Canonical home is the standalone repo; original lineage also exists as `parameter-golf-qat-int4` -> `noisy-qat-bayesian` |
| TurboQuant | [parameter-golf-qat-turboquant](/Users/jmoncayopursuit.org/Desktop/parameter-golf-qat-turboquant) | Full Repo | Partial | Canonical home is the standalone repo; original lineage also exists as `parameter-golf-qat-int4` -> `turboquant-experiment` |

## How to use this

When starting work on another experiment:

1. open the conversation in the experiment's canonical location
2. use the Gimlet repo as the operational reference
3. focus first on readiness gaps, not model-quality debate
4. only consider paid spend after the repo reaches the same standard

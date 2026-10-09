# Local Laya feedback grouping POC

The **Laya POC** dashboard tab evaluates generated Discord, Slack, email, forms, and support feedback with [Laya](https://github.com/NandhaKishorM/laya). No OpenRouter, Jev, Hugging Face token, or paid API key is required. The integration cards are sample sources, not live connectors.

## Run locally

Laya runs separately from Serverpod, bound to `127.0.0.1:8093`. On this Mac it uses the Apple GPU (MPS); Docker is unnecessary. Existing Flutter, Dart, Serverpod, authentication, PostgreSQL, and cache setup are unchanged. Python packages live only in `tools/laya/.venv`; model downloads and caches stay ignored.

From the repository root, first-time setup:

```sh
cd feedback_aggregator
sh tools/laya/setup.sh
```

Requires `uv` and Python 3.12. To select an existing interpreter, set `LAYA_PYTHON=/absolute/path/to/python3` before setup. On this machine the compatible interpreter is `/Users/maheshshekokar/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3`. Setup skips an already installed Laya 0.4.1 environment and refuses to change a different or incomplete existing environment. `requirements.lock` records the packages installed on this Apple Silicon Mac; dependencies on other operating systems may differ.

Start the model service in its own terminal:

```sh
cd feedback_aggregator
sh tools/laya/run.sh
```

The first run downloads public weights. Leave the service running while testing; stop it with Ctrl+C. The script pins checkpoint revision `7b928d828b7b0e022f929d9bd2e44165aa270148`, so subsequent starts do not silently switch weights. `/health` reports the actual device, loaded model, revision, and CPU fallback count. Runtime downloads require network access; inference is local once weights are cached. API fees are zero; compute still uses your machine.

Start Serverpod yourself in another terminal, preserving the existing environment:

```sh
cd feedback_aggregator/feedback_aggregator_server
set -a
. ./.env
set +a
serverpod start
```

The runner generates endpoint registration/client code and reloads the app. No migration is needed. Sign in, select a workspace, open **Laya POC**, and click **Run Laya grouping**. If the model was started after opening the panel, click **Refresh team results**.

The default model URL needs no configuration. Optional server environment:

```sh
LAYA_URL='http://127.0.0.1:8093/v1/systemone'
```

For an authenticated model service, set `LAYA_API_KEY` in its terminal and the matching `SERVERPOD_PASSWORD_layaApiKey` in the Serverpod terminal. This optional local token never enters Flutter. Keep the service on loopback for this POC; remote hosting needs its own authenticated deployment. Offline/provider errors do not fabricate groups or fall back to canned results.

## Matching flow

The general English Laya checkpoint is used. Its specialized `typed-decisions` checkpoint is trained for four particular workflows; feedback clustering is outside those workflows.

1. A choice question classifies the message as bug, feature, noise, or unclear; a separate score question estimates severity.
2. Bug/feature answers need at least 0.60 answer confidence before duplicate checks.
3. The server retrieves up to seven existing issues by lexical similarity, then batches binary questions comparing the incoming report with each issue's first report. There are no predeclared gold groups.
4. Exactly one candidate with duplicate probability at least 0.80 is merged. Multiple qualifying candidates go to review. If every candidate is at most 0.50, a new issue is created; the intermediate range goes to review.

These are development policy thresholds, not an accuracy guarantee. Choice/score gating uses Laya's `answer_confidence`, not entropy-based `confidence`. Binary matching uses `noul`, the probability of true, rather than the confidence in either answer. Requests that lose state tokens or collapse options are rejected. The checkpoint warns about its 11+ choice calibration bucket; this flow uses four choice options and binary duplicate checks.

Gold labels are used only after decisions for evaluation and are never sent to the model. Original text and source evidence remain available. Titles come from the first report, since Laya is a classifier and does not write summaries.

## Measured result and limitations

The fixed development fixture contains 34 English reports: six issues paraphrased across five channels, two chatter messages, and two vague reports. CSV timeouts versus empty filtered CSVs and Google-login loops versus missing reset emails test nearby but distinct issues. Four distinct people report each issue; one repeats it on a fifth channel.

Four local retest runs captured on 2026-10-09 used Laya 0.4.1, the same pinned English checkpoint, and Apple MPS. Each evaluated all 34 reports with unchanged prompts and thresholds:

| Run | Issues | Merged reports | Review | Pair precision | Duplicate recall |
| --- | ---: | ---: | ---: | ---: | ---: |
| Ordered 1 | 10 | 5 | 19 | 83.3% | 8.3% |
| Ordered 2 | 10 | 5 | 19 | 83.3% | 8.3% |
| Shuffled seed 7 | 9 | 11 | 14 | 91.7% | 36.7% |
| Shuffled seed 42 | 10 | 11 | 13 | 100.0% | 31.7% |

The ordered runs reproduced identical decisions and groups. Arrival order materially changed recall. API fees were $0; accumulated inference request times ranged from 5.408 to 19.936 seconds, excluding startup, RPC, and rendering. These timings were not collected under controlled machine load.

Open the [architecture and results report](artifacts/laya-poc-20261009-231155/report.html), [Markdown document](artifacts/laya-poc-20261009-231155/report.md), or [shareable evidence bundle](artifacts/laya-poc-20261009-231155/laya-poc-evidence.zip). They include all four captures, candidate probabilities, groups, priority components, and a reproducible engine snapshot. The HTML report has an offline evidence explorer.

The incorrect ordered merge put a dark-theme request into the filtered CSV issue. Duplicate fragmentation also produced competing candidates that went to review. Neither chatter report was confidently classified as noise. This model/prompt combination is **not suitable for unattended customer-feedback merging** based on these results. The POC deliberately makes those failures inspectable. It does not offer manual reassignment/merge/split yet. All 51 backend/Flutter tests passed; live app navigation was not confirmed, as recorded separately in the report.

An earlier direct match/new/uncertain prompt sent all 34 reports to review (0% recall), which motivated separate triage and pairwise questions. These experiments use the same synthetic development fixture, not an independent holdout; do not treat the figures as general accuracy. Evaluate independently labeled real reports and a stronger local model before enabling automatic grouping.

To repeat the same engine without starting Serverpod or touching the database, leave Laya running and execute:

```sh
cd feedback_aggregator/feedback_aggregator_server
dart run tool/benchmark_laya.dart ../tools/laya/.runtime/benchmark.json
```

Pairwise merge precision is correct same-issue pairs divided by all merged pairs. Duplicate recall is recovered pairs divided by expected duplicate pairs. Reviews/unmerged duplicates count as misses; vague unlabeled reports are excluded. Metrics are provisional during evaluation and absent when a denominator is zero. Local automated tests use explicit doubles and validate software behavior, not model accuracy.

## Team UI, priority, and isolation

Admins and Editors can run/resume the POC and update issue status. Viewers can inspect results. Each method checks workspace membership/role; results are shared only within the selected workspace. Source selection, search, channel/status filters, original reports, raw decisions, and a review queue are available.

Priority is a product rule out of 100: severity up to 40, identified reporters up to 30 (cap ten), last-24-hour reports up to 20 (cap five), and channel breadth up to 10. Components are rounded. A confidently critical incident receives at least 95; uncertain severity is flagged. Model errors can affect the score, so inspect the evidence. Cross-channel sample identities are explicitly linked; real connectors will need an identity strategy.

Results/statuses live in bounded workspace-scoped memory, clear on backend restart, and do not modify live tickets. This is a single-backend-instance POC. Each member may start five runs per workspace per hour; retries are bounded, and a successful step is idempotent at its processed index. Keep `.venv`, model caches, runtime output, and credentials out of Git. Never hand-edit generated Serverpod files.

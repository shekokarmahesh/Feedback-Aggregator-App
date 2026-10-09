#!/bin/sh
set -eu
cd "$(dirname "$0")"
if [ ! -x .venv/bin/laya-serve ]; then
  echo 'Run sh setup.sh first.' >&2
  exit 1
fi
# Local-only model service. Serverpod remains the authenticated app API.
export HF_HOME="$PWD/.cache/huggingface"
export LAYA_HOST=127.0.0.1
export LAYA_PORT="${LAYA_PORT:-8093}"
export LAYA_PRELOAD=1
export LAYA_MODELS=english
# Pin the measured public weights; restarting must not silently update the model.
export LAYA_REVISION=7b928d828b7b0e022f929d9bd2e44165aa270148
export LAYA_MAX_LOADED=1
export LAYA_THREADS="${LAYA_THREADS:-4}"
export LAYA_MAX_CONCURRENT=2
export LAYA_MAX_TOKEN_BUDGET=2048
export LAYA_IDLE_UNLOAD_SECONDS=0
export LAYA_LOG_LEVEL=warning
exec .venv/bin/laya-serve

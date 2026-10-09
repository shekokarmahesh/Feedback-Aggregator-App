#!/bin/sh
set -eu
cd "$(dirname "$0")"
if ! command -v uv >/dev/null 2>&1; then
  echo 'Install uv or create a Python >=3.10 virtual environment and install requirements.txt.' >&2
  exit 1
fi
export UV_CACHE_DIR="$PWD/.cache/uv"
created=false
if [ ! -x .venv/bin/python ]; then
  uv venv --python "${LAYA_PYTHON:-3.12}" .venv
  created=true
fi
if .venv/bin/python -c 'from importlib.metadata import version; assert version("laya") == "0.4.1"; import fastapi, uvicorn' >/dev/null 2>&1; then
  echo 'Laya 0.4.1 serving dependencies are already installed.'
  exit 0
fi
if [ "$created" = false ]; then
  echo 'An existing incomplete or different environment was found. Inspect it before changing installed packages.' >&2
  exit 1
fi
uv pip install --python .venv/bin/python -r requirements.lock

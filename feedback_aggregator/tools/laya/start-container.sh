#!/bin/sh
set -eu
: "${LAYA_API_KEY:?Set LAYA_API_KEY to protect the hosted inference API.}"
export LAYA_PORT="${PORT:-8093}"
exec laya-serve

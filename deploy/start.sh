#!/usr/bin/env bash
set -euo pipefail

fail() { echo "Deployment configuration error: $1" >&2; exit 1; }
[[ ${PORT:-} =~ ^[0-9]+$ ]] && (( PORT > 0 && PORT < 65536 )) || fail 'PORT must be 1–65535.'
PUBLIC_ORIGIN="${APP_PUBLIC_URL:-${RENDER_EXTERNAL_URL:-}}"
PUBLIC_ORIGIN="${PUBLIC_ORIGIN%/}"
[[ "$PUBLIC_ORIGIN" =~ ^(https?)://([a-zA-Z0-9.-]+)(:([0-9]+))?$ ]] \
  || fail 'Set APP_PUBLIC_URL to an HTTP(S) origin, or use Render RENDER_EXTERNAL_URL.'
scheme="${BASH_REMATCH[1]}"
host="${BASH_REMATCH[2]}"
public_port="${BASH_REMATCH[4]:-}"
if [[ -z "$public_port" ]]; then
  if [[ "$scheme" == https ]]; then public_port=443; else public_port=80; fi
fi
(( public_port > 0 && public_port < 65536 )) || fail 'Public URL port must be 1–65535.'
export PUBLIC_ORIGIN

for key in SERVERPOD_DATABASE_HOST SERVERPOD_DATABASE_NAME SERVERPOD_DATABASE_USER \
  SERVERPOD_PASSWORD_database SERVERPOD_PASSWORD_serviceSecret \
  SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey \
  SERVERPOD_PASSWORD_emailSecretHashPepper; do
  [[ -n "${!key:-}" ]] || fail "Missing $key."
done
[[ -z ${SERVERPOD_DATABASE_DATA_PATH:-} ]] || fail 'Use external PostgreSQL in production; remove SERVERPOD_DATABASE_DATA_PATH.'

export SERVERPOD_API_SERVER_PORT=8080 SERVERPOD_WEB_SERVER_PORT=8082
export SERVERPOD_API_SERVER_PUBLIC_HOST="$host" SERVERPOD_WEB_SERVER_PUBLIC_HOST="$host"
export SERVERPOD_API_SERVER_PUBLIC_SCHEME="$scheme" SERVERPOD_WEB_SERVER_PUBLIC_SCHEME="$scheme"
export SERVERPOD_API_SERVER_PUBLIC_PORT="$public_port" SERVERPOD_WEB_SERVER_PUBLIC_PORT="$public_port"
export SERVERPOD_ALLOWED_ORIGINS="$PUBLIC_ORIGIN" SERVERPOD_REDIS_ENABLED=false
export SERVERPOD_SERVER_ID="${SERVERPOD_SERVER_ID:-${RENDER_INSTANCE_ID:-default}}"
if [[ -n ${LAYA_SERVICE_HOST:-} ]]; then
  [[ "$LAYA_SERVICE_HOST" =~ ^[a-zA-Z0-9.-]+$ ]] || fail 'Invalid LAYA_SERVICE_HOST.'
  export LAYA_URL="http://${LAYA_SERVICE_HOST}:${LAYA_SERVICE_PORT:-8093}/v1/systemone"
fi

backend_pid='' proxy_pid=''
shutdown() {
  trap - EXIT INT TERM
  for pid in "$backend_pid" "$proxy_pid"; do
    [[ -z "$pid" ]] || kill -TERM "$pid" 2>/dev/null || true
  done
  wait 2>/dev/null || true
}
trap shutdown EXIT
trap 'exit 143' TERM
trap 'exit 130' INT

/app/bin/main --mode=production --apply-migrations "$@" &
backend_pid=$!
# Render's default TCP probe must not see Caddy before the backend is ready.
ready=false
for (( attempt=0; attempt<180; attempt++ )); do
  if curl --fail --silent --max-time 2 http://127.0.0.1:8080/readyz >/dev/null; then
    ready=true
    break
  fi
  kill -0 "$backend_pid" 2>/dev/null || fail 'Serverpod exited during startup.'
  sleep 1
done
[[ "$ready" == true ]] || fail 'Serverpod did not become ready within three minutes.'
caddy run --config /app/deploy/Caddyfile --adapter caddyfile &
proxy_pid=$!

set +e
wait -n "$backend_pid" "$proxy_pid"
result=$?
set -e
# A component exiting unexpectedly should make the orchestrator restart us.
(( result != 0 )) || result=1
exit "$result"

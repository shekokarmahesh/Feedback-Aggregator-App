# syntax=docker/dockerfile:1
FROM ghcr.io/astral-sh/uv:0.12.21 AS uv
FROM python:3.12.14-slim-bookworm
COPY --from=uv /uv /usr/local/bin/uv
RUN groupadd --gid 10001 app && useradd --uid 10001 --gid app --no-create-home app
WORKDIR /app
COPY feedback_aggregator/tools/laya/requirements.lock /app/requirements.lock
# CPU wheels avoid installing CUDA libraries on Render's CPU instances.
RUN uv pip install --system --no-cache --torch-backend=cpu -r requirements.lock
ENV HF_HOME=/app/models LAYA_HOST=0.0.0.0 LAYA_DEVICE=cpu \
    LAYA_MODELS=english LAYA_PRELOAD=1 LAYA_MAX_LOADED=1 \
    LAYA_REVISION=7b928d828b7b0e022f929d9bd2e44165aa270148 \
    LAYA_THREADS=1 LAYA_MAX_CONCURRENT=2 LAYA_MAX_TOKEN_BUDGET=2048 \
    LAYA_MAX_BATCH_TOKENS=2048 LAYA_IDLE_UNLOAD_SECONDS=0 LAYA_LOG_LEVEL=warning \
    PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 PORT=8093
# Pin and cache the checkpoint at build time so startup needs no model download.
RUN python -c "from laya.serve import build_router; build_router()" \
    && chown -R app:app /app
COPY --chown=app:app feedback_aggregator/tools/laya/start-container.sh /app/start-container.sh
USER app
EXPOSE 8093
HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 \
    CMD python -c "import os, urllib.request; urllib.request.urlopen('http://127.0.0.1:'+os.environ['PORT']+'/health', timeout=4)" || exit 1
ENTRYPOINT ["/bin/sh", "/app/start-container.sh"]

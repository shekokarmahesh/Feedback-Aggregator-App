# syntax=docker/dockerfile:1
# BuildKit fetches and verifies the exact asset before the Dart hook runs.
FROM scratch AS sqlite-asset
ADD --checksum=sha256:0f947ebe629e8d9d02d7f408bef36e056bfc63ea47e02e0d45a7bae454f04ace \
    https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.7.0/libsqlite3.x64.linux.so /native/libsqlite3.so

# Build with the same Flutter/Dart release used by this repository.
FROM debian:bookworm-slim AS build
ARG FLUTTER_VERSION=3.47.6
ARG FLUTTER_REVISION=5fc346839b5d0eef006ed8404392afb4dfae428d
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git /opt/flutter \
    && test "$(git -C /opt/flutter rev-parse HEAD)" = "$FLUTTER_REVISION"
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}" \
    CI=true FLUTTER_SUPPRESS_ANALYTICS=true
RUN flutter config --no-analytics && flutter precache --web
WORKDIR /src
COPY feedback_aggregator/pubspec.yaml feedback_aggregator/pubspec.lock ./
COPY feedback_aggregator/feedback_aggregator_client/pubspec.yaml feedback_aggregator_client/pubspec.yaml
COPY feedback_aggregator/feedback_aggregator_server/pubspec.yaml feedback_aggregator_server/pubspec.yaml
COPY feedback_aggregator/feedback_aggregator_flutter/pubspec.yaml feedback_aggregator_flutter/pubspec.yaml
RUN flutter pub get --enforce-lockfile
COPY feedback_aggregator/feedback_aggregator_client/ feedback_aggregator_client/
COPY feedback_aggregator/feedback_aggregator_server/ feedback_aggregator_server/
COPY feedback_aggregator/feedback_aggregator_flutter/ feedback_aggregator_flutter/
# This client ID is public. Private OAuth JSON and API keys are runtime env vars.
ARG GOOGLE_CLIENT_ID=""
RUN cd feedback_aggregator_flutter && flutter build web --release --no-pub \
    --base-href / --dart-define=GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" \
    --dart-define=API_TIMEOUT_SECONDS=120 \
    --output=/out/web
# Seed sqlite3 3.7.0's verified hook cache with BuildKit's verified asset.
# The package also checks this SHA-256 before reusing the cached native asset.
COPY --from=sqlite-asset /native/libsqlite3.so .dart_tool/hooks_runner/shared/sqlite3/build/download-0f947ebe/libsqlite3.so
RUN test -d /root/.pub-cache/hosted/pub.dev/sqlite3-3.7.0 \
    && echo '0f947ebe629e8d9d02d7f408bef36e056bfc63ea47e02e0d45a7bae454f04ace  .dart_tool/hooks_runner/shared/sqlite3/build/download-0f947ebe/libsqlite3.so' | sha256sum --check \
    && cd feedback_aggregator_server && dart build cli --target=bin/main.dart --output=/out/server

FROM caddy:2.10-alpine AS proxy
FROM debian:bookworm-slim AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl tini libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 10001 app && useradd --uid 10001 --gid app --no-create-home app
WORKDIR /app
COPY --from=proxy /usr/bin/caddy /usr/bin/caddy
COPY --from=build --chown=app:app /out/server/bundle/ ./
COPY --from=build --chown=app:app /out/web/ web/app/
COPY --chown=app:app feedback_aggregator/feedback_aggregator_server/config/production.yaml config/production.yaml
COPY --chown=app:app feedback_aggregator/feedback_aggregator_server/config/generator.yaml config/generator.yaml
COPY --chown=app:app feedback_aggregator/feedback_aggregator_server/migrations/ migrations/
COPY --chown=app:app feedback_aggregator/feedback_aggregator_server/web/static/ web/static/
COPY --chown=app:app deploy/start.sh deploy/Caddyfile deploy/
ENV PORT=10000 LAYA_REQUEST_TIMEOUT_SECONDS=45 \
    XDG_CONFIG_HOME=/tmp/caddy/config XDG_DATA_HOME=/tmp/caddy/data
USER app
EXPOSE 10000
HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=3 \
    CMD curl --fail --silent "http://127.0.0.1:${PORT}/healthz" >/dev/null || exit 1
ENTRYPOINT ["/usr/bin/tini", "--", "/bin/bash", "/app/deploy/start.sh"]

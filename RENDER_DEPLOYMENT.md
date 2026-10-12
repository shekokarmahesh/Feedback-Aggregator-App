# Render deployment

The deployment packages the Flutter website, compiled Serverpod backend, and Caddy proxy in one Linux AMD64 image. PostgreSQL runs as a separate managed database. The Laya POC runs in a second CPU-only container with bearer authentication. Redis and Docker Compose are unnecessary. Local development continues using Serverpod-managed PostgreSQL.

## Traffic and storage

```
Browser -> HTTPS Render URL -> Caddy :10000
                               /api/* -> Serverpod API :8080 (prefix stripped)
                               /auth/callback and website -> Serverpod web :8082
                               /healthz -> Serverpod readiness probe
Serverpod -> managed PostgreSQL (accounts, workspaces, tickets)
Serverpod -> authenticated Laya service (pinned English model, CPU)
```

Render terminates HTTPS. `deploy/start.sh` derives public URLs from `RENDER_EXTERNAL_URL` (or an explicit `APP_PUBLIC_URL` origin), applies committed migrations, waits for backend readiness, and starts Caddy. If either process exits, the container exits. SIGTERM shuts down both processes. The runtime uses an unprivileged user and includes the native libraries packaged by `dart build cli`.

The `/assets/assets/config.json` response supplies the deployed `/api/` URL at runtime, replacing the localhost asset. The existing Google callback stays on the same website origin. Insights is not exposed. Database files and application credentials are excluded from the Docker build. No local accounts or tickets are copied to Render automatically.

Workspace feedback persists in managed PostgreSQL. Serverpod memory caches and Laya POC groups/statuses clear on app restart, as before. Laya is still an experimental classifier with the quality limitations documented in `feedback_aggregator/LAYA_POC.md`.

## Build and test

From the repository root, using the existing Docker installation:

```sh
# GOOGLE_CLIENT_ID is the public ID of the existing Google web OAuth client.
docker build --platform linux/amd64 --build-arg GOOGLE_CLIENT_ID \
  -t feedback-aggregator:render-test .
docker build --platform linux/amd64 \
  -f feedback_aggregator/tools/laya/Dockerfile \
  -t feedback-laya:render-test .
python3 deploy/smoke_test.py --laya-image feedback-laya:render-test
```

The smoke test creates its own randomly named network, disposable PostgreSQL, and two app containers. It uses newly generated test secrets and synthetic accounts, makes no email requests, and removes only its own containers, anonymous database volume, and network. It checks HTTP routes, password signup/login, tenant isolation, Viewer restrictions, invitation URLs, real model inference, restart persistence, and missing bundled credential files. By default, Laya gets a 2 GiB/1 CPU limit; the app gets 512 MiB/0.5 CPU. For slow AMD64 emulation on Apple Silicon, add `--laya-cpus 4`. This changes only local test allocation; native Render inference must be verified on the actual 1 CPU instance before claiming that plan is sufficient.

Flutter is pinned to the repository's existing 3.47.6 release and exact Git revision, with bundled Dart. Package resolution enforces `pubspec.lock`. Laya is pinned to 0.4.1, its dependency lock, and checkpoint revision `7b928d828b7b0e022f929d9bd2e44165aa270148`. CPU PyTorch wheels and cached weights are included in the Laya image. No host SDK upgrade is required.

BuildKit downloads sqlite3 3.7.0's Linux native asset, verifies the package's published SHA-256, and seeds its build-hook cache. This avoids TLS failures in Dart's downloader while retaining the exact locked library. Update this pin and checksum together if the sqlite3 dependency is deliberately changed later.

On this Mac, Docker's network could not reach GitHub's release-asset host, although macOS could. Local testing used Docker's supported `--build-context sqlite-asset=<directory>` override with the identical downloaded library at `<directory>/native/libsqlite3.so`. The builder verifies its SHA-256 again, including when overridden. Render uses the default official GitHub download; its clean network build still needs cloud verification.

The deployed backend allows 45 seconds per Laya HTTP request (`LAYA_REQUEST_TIMEOUT_SECONDS`, bounded to 1–90). A report can need two requests. The Docker-built Flutter client allows 120 seconds per API call; local development retains its existing defaults. Laya's batch token budget is 2048 to bound inference memory.

## Render configuration

`render.yaml` describes the app, Laya, and PostgreSQL in Singapore. The same Dockerfiles can be deployed through the Render plugin. Use the current Git branch containing the deployment files. Confirm the target Render workspace before creating resources, and reuse existing project resources if present.

Runtime configuration for the app:

| Variable | Source |
| --- | --- |
| `SERVERPOD_DATABASE_HOST`, `SERVERPOD_DATABASE_PORT`, `SERVERPOD_DATABASE_NAME`, `SERVERPOD_DATABASE_USER` | Render database connection properties |
| `SERVERPOD_PASSWORD_database` | Render database password |
| `SERVERPOD_DATABASE_REQUIRE_SSL` | `true` for the Render connection |
| `SERVERPOD_PASSWORD_serviceSecret` | New random production secret |
| `SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper` | New random production secret |
| `SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey` | New key generated from at least 64 random bytes |
| `SERVERPOD_PASSWORD_emailSecretHashPepper` | Different random production secret |
| `GOOGLE_CLIENT_ID` | Public client ID; also used as Docker build argument |
| `SERVERPOD_PASSWORD_googleClientSecret` | Complete existing Google web OAuth JSON, kept private |
| `SERVERPOD_PASSWORD_resendApiKey`, `SERVERPOD_PASSWORD_resendFromEmail` | Existing Resend credentials/sender |
| `LAYA_SERVICE_HOST`, `LAYA_SERVICE_PORT` | Laya's private Render hostname and port `8093` |
| `SERVERPOD_PASSWORD_layaApiKey` | Same newly generated secret as Laya's `LAYA_API_KEY` |

The Laya process accepts `PORT` and binds to `0.0.0.0`. `/health` exposes minimal unauthenticated liveness; inference requires the secret bearer token. The main app communicates over Render's private network. Do not put real keys in Dockerfile arguments, images, Git, documentation, or logs.

## Google login and email delivery

In the existing Google Cloud Web OAuth client, add the final deployed HTTPS origin to **Authorized JavaScript origins** and the exact `https://<app>.onrender.com/auth/callback` to **Authorized redirect URIs**. Keep the localhost entries for development. While Google OAuth is in Testing, intended users must be added as test users. Changing JSON on the backend does not change Google's allow-list. End-to-end Google login needs a browser check after the allowed URL is saved.

Resend's `onboarding@resend.dev` sender remains limited to the Resend account owner's inbox. Deploying to Render does not remove that provider restriction. Sending reset/invitation emails to other people requires a verified sender domain; copyable invitation links and password signup/login do not require email delivery.

## Budget and verification

Local verification on 12 October 2026 passed `dart analyze`, 34 server tests, 18 Flutter tests, and the full production-container smoke test. See [the recorded results](deploy/docker-verification.json). All 34 reports completed through authenticated Serverpod RPC in 334.7 seconds under AMD64 emulation; the slowest report took 20.91 seconds. Password login, workspace isolation, Viewer permissions, invitation URLs, migrations, restart persistence, graceful shutdown, and unprivileged execution passed. The temporary containers and database volume were removed afterward.

The model merged 5 reports and sent 19 for review. Pairwise precision was 83.3%, with 8.3% recall, 1 false merge, and 55 missed duplicate pairs. The low recall means most repeated issues still need review. The emulated model reached its 2 GiB RAM limit and used approximately 345 MiB of swap during inference. Native Render inference and memory usage remain unverified; this local run does not establish that the proposed 2 GiB cloud instance is sufficient.

At Render's checked pricing on 12 October 2026, the proposed app plan (`0.5c-512mb`) is $7/month, Laya (`1c-2g`) is $25/month, and PostgreSQL (`0.1c-256mb`) is $6/month. Base compute is approximately $38/month, plus any billable storage or usage. The Blueprint selects only 1 GB of database storage. See [Render pricing](https://render.com/pricing).

$50 in credits covers roughly five weeks at that base rate. Credits do not automatically impose a spending cap or stop services; suspend/delete resources before credit exhaustion if ongoing charges are unwanted. No workspace-plan upgrade or autoscaling is required.

After deployment, verify `/healthz`, website assets, runtime API config, password login, workspace isolation, and an authenticated Laya run. Inspect Render deploy status and logs. Validate Google login separately after updating the OAuth allow-list, and confirm email sender readiness before testing password-reset delivery.

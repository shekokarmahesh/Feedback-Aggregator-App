# Render deployment

The deployment packages the Flutter website, compiled Serverpod backend, and Caddy proxy in one Linux AMD64 image. PostgreSQL runs as a separate managed database. The Laya POC runs in a second CPU-only container with bearer authentication. Redis and Docker Compose are unnecessary. Local development continues using Serverpod-managed PostgreSQL.

## Live deployment — 12 October 2026

Open **[Feedback Aggregator](https://feedback-aggregator-ak6p.onrender.com)**. The Flutter website and Serverpod backend, Laya, and PostgreSQL are running in Singapore in **Feedback Aggregator's workspace**.

| Resource | Dashboard | Plan | Base/month |
| --- | --- | --- | --- |
| Flutter + Serverpod | [feedback-aggregator](https://dashboard.render.com/web/srv-db6gtvvf3r2c73c7ufj0) | `0.5c-512mb` | $7 |
| Laya CPU inference | [feedback-laya](https://dashboard.render.com/web/srv-db6ecc7avr4c73b61lpg) | `1c-2g` | $25 |
| PostgreSQL 16 | [feedback-aggregator-db](https://dashboard.render.com/d/dpg-db6ea1nlk1mc73cusfl0-a) | `0.1c-256mb`, 1 GB | $6 |

Both web services deployed commit `9c5c1f0f82164c2fbbedd90db20db8f2a23491d5` from `add-postbot-mascot`. The main app's HTTP health check is `/healthz`. Database migrations applied successfully with SSL required. PostgreSQL's external IP allowlist remains empty; public database access has not been enabled. The backend reaches Laya privately at `feedback-laya:8093` with bearer authentication.

Hosted password registration/login without OTP, tenant isolation, Viewer write restrictions, copyable invitation acceptance, website assets, runtime API configuration, and authenticated Laya RPC all passed. Browser checks also passed for password login, the persisted workspace ticket, and Google login after the user updated the existing OAuth client's allowed URLs. Google's consent request initially encountered a browser transport error; retrying completed the callback and showed the authenticated workspace screen. See the [Google login proof](deploy/render-google-login.jpg) and [hosted dashboard](deploy/render-live-dashboard.jpg). The synthetic test session was signed out afterward.

All **34 synthetic reports** completed through deployed Serverpod RPC and the private Laya connection in **211.74 seconds**; the slowest report took **12.99 seconds**. The results were 5 merged reports, 19 reports for review, 83.3% pairwise precision, 8.3% recall, 1 false merge pair, and 55 missed duplicate pairs. Low recall means most repeated issues still need review.

An earlier direct authenticated HTTPS test against hosted Laya completed the same 34 reports in **210.46 seconds**, with a slowest report of **9.23 seconds** and the same grouping metrics. Its public health route returned 200, unauthenticated inference returned 401, and authenticated health confirmed the pinned English checkpoint on CPU.

During the app RPC run, Render's 30-second samples reached **81,309,700 bytes (77.5 MiB)** for the app and **2,075,230,200 bytes (1.93 GiB)** for Laya, with no recorded failure/restart events during verification. Laya is close to the 2 GiB limit; sampled metrics are not an exact peak, and these sequential runs do not establish capacity for concurrent use. See [the cloud evidence](deploy/render-verification.json).

To try the deployment:

1. Open the app and use **Sign up** for email/password or **Continue with Google** from the login page. Local accounts were not copied to Render.
2. Create a workspace, then use **Add feedback** to add a ticket and test the inbox filters.
3. Open **Team**, create a Viewer or Editor invitation link, and share it with a teammate who signs in using the invited email address. Email invitations remain subject to the sender restriction below.
4. Open **Laya POC**, select the mock sources, and run the demo. The source cards represent synthetic integrations, not live Slack/Discord/email connectors. Allow several minutes for all 34 reports.

The new app stack costs about **$38/month** in base compute. An existing Discord bot worker adds about $7/month, bringing workspace base compute to about **$45/month**, plus storage and usage. The existing worker was left unchanged and was not functionally tested.

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

The smoke test creates its own randomly named network, disposable PostgreSQL, and app/model containers. It uses newly generated test secrets and synthetic accounts, makes no email requests, and removes only its own containers, anonymous database volume, and network. It checks HTTP routes, password signup/login, tenant isolation, Viewer restrictions, invitation URLs, real model inference, restart persistence, and missing bundled credential files. The app runs with all Linux capabilities dropped and `no-new-privileges`. By default, Laya gets a 2 GiB/1 CPU limit; the app gets 512 MiB/0.5 CPU. For slow AMD64 emulation on Apple Silicon, add `--laya-cpus 4`. This changes only local test allocation; the native Render run above verifies sequential operation on the actual 1 CPU instance.

Flutter is pinned to the repository's existing 3.47.6 release and exact Git revision, with bundled Dart. Package resolution enforces `pubspec.lock`. Laya is pinned to 0.4.1, its dependency lock, and checkpoint revision `7b928d828b7b0e022f929d9bd2e44165aa270148`. CPU PyTorch wheels and cached weights are included in the Laya image. No host SDK upgrade is required.

BuildKit downloads sqlite3 3.7.0's Linux native asset, verifies the package's published SHA-256, and seeds its build-hook cache. This avoids TLS failures in Dart's downloader while retaining the exact locked library. Update this pin and checksum together if the sqlite3 dependency is deliberately changed later.

On this Mac, Docker's network could not reach GitHub's release-asset host, although macOS could. Local testing used Docker's supported `--build-context sqlite-asset=<directory>` override with the identical downloaded library at `<directory>/native/libsqlite3.so`. The builder verifies its SHA-256 again, including when overridden. Render's clean network build successfully used the default official GitHub download.

Two Render-specific failures were fixed and retested: Flutter archive extraction now uses `TAR_OPTIONS=--no-same-owner` in the build stage, and the runtime recreates Caddy's executable without its upstream file capability. Caddy binds port 10000 and needs no privileged capability. The final Docker smoke test passed with all capabilities disabled, and the cloud deployment is live.

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

The existing Google Cloud Web OAuth client now allows `https://feedback-aggregator-ak6p.onrender.com` as a JavaScript origin and `https://feedback-aggregator-ak6p.onrender.com/auth/callback` as a redirect URI, retaining localhost entries. End-to-end Google browser login passed after propagation. If the OAuth app remains in Testing, add intended users as test users. Changing backend JSON alone does not change Google's allow-list.

Resend's `onboarding@resend.dev` sender remains limited to the Resend account owner's inbox. Deploying to Render does not remove that provider restriction. Sending reset/invitation emails to other people requires a verified sender domain; copyable invitation links and password signup/login do not require email delivery.

## Budget and verification

Local verification on 12 October 2026 passed `dart analyze`, 34 server tests, 18 Flutter tests, and the full production-container smoke test. See [the recorded results](deploy/docker-verification.json). All 34 reports completed through authenticated Serverpod RPC in 334.7 seconds under AMD64 emulation; the slowest report took 20.91 seconds. Password login, workspace isolation, Viewer permissions, invitation URLs, migrations, restart persistence, graceful shutdown, and unprivileged execution passed. The temporary containers and database volume were removed afterward.

The model merged 5 reports and sent 19 for review. Pairwise precision was 83.3%, with 8.3% recall, 1 false merge, and 55 missed duplicate pairs. The low recall means most repeated issues still need review. The emulated model reached its 2 GiB RAM limit and used approximately 345 MiB of swap during inference. The native Render result is recorded above; memory headroom remains limited.

At Render's checked pricing on 12 October 2026, the deployed app plan (`0.5c-512mb`) is $7/month, Laya (`1c-2g`) is $25/month, and PostgreSQL (`0.1c-256mb`) is $6/month. Base compute is approximately $38/month, plus any billable storage or usage. The database has 1 GB of storage. See [Render pricing](https://render.com/pricing).

$50 in starting credits covers roughly one month of the $45/month workspace base compute, before storage, usage, or credits already consumed. Credits do not automatically impose a spending cap or stop services; suspend/delete resources before credit exhaustion if ongoing charges are unwanted. No workspace-plan upgrade or autoscaling is required.

The cloud checks above passed. External Resend delivery, concurrent model load, and a deliberate cloud restart were not tested; graceful restart and persisted tickets passed locally. Synthetic verification accounts, a labeled workspace, and one test ticket were created in the hosted database. Local smoke containers and volumes were removed.

Pushes to `add-postbot-mascot` automatically deploy both web services. Documentation-only evidence commits use `[skip render]` to avoid rebuilding unchanged images; see [Render's deploy controls](https://render.com/docs/deploys#skipping-an-auto-deploy).

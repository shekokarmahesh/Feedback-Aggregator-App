# Collaborator environment setup

For a separate local database, each developer generates their own database, Redis, service, JWT, and email hash secrets. Share the Google OAuth JSON and Resend API key privately only if you are using the same team provider accounts. Never commit real credentials, paste them into issues, or send them in a public chat.

When two servers use the same database and authentication records, use the same JWT keys and hash peppers for that environment. Changing `emailSecretHashPepper` can invalidate stored email/password credentials. Keep existing authentication secrets when updating an existing installation.

## Complete variable list

These six variables are required for the configured development backend. The database and Redis values must match their respective services:

```sh
export SERVERPOD_PASSWORD_database='<local-database-password>'
export SERVERPOD_PASSWORD_redis='<local-redis-password>'
export SERVERPOD_PASSWORD_serviceSecret='<random-secret-at-least-20-characters>'
export SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper='<random-secret>'
export SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey='<random-key-from-at-least-64-random-bytes>'
export SERVERPOD_PASSWORD_emailSecretHashPepper='<different-random-secret>'
```

Password-reset email and emailed workspace invitations additionally need:

```sh
export SERVERPOD_PASSWORD_resendApiKey='<resend-api-key>'
export SERVERPOD_PASSWORD_resendFromEmail='Feedback Aggregator <onboarding@resend.dev>'
```

You currently have no verified domain. This default sender can deliver to the Resend account owner's inbox; it cannot email arbitrary teammates. Sending a code instead of a link does not change that restriction. Workspace Admins can use **Team → Create share link** and send the link themselves, without Resend or a purchased domain. See [Resend's restriction](https://resend.com/docs/knowledge-base/403-error-resend-dev-domain). Password reset for other users still needs a sender that can deliver to their inbox.

Google login needs the **complete downloaded web OAuth JSON**, including its `web` object, plus the public client ID in the Flutter build:

```sh
export SERVERPOD_PASSWORD_googleClientSecret="$(cat /private/path/google-oauth.json)"
export GOOGLE_CLIENT_ID='<client-id>.apps.googleusercontent.com'
```

The OAuth JSON contains a private secret and stays on the backend. `GOOGLE_CLIENT_ID` is public, but exporting it alone does not enable Google in Flutter; pass it through `--dart-define` in the build command below. Add your friend's Google email to the OAuth project's test-user list while the app is in Testing. For this local setup, allow origin `http://localhost:8082` and redirect URI `http://localhost:8082/auth/callback` in that web OAuth client. See [Google setup](GOOGLE_AUTH_SETUP.md).

`POSTGRES_TEST_PASSWORD` and `REDIS_TEST_PASSWORD` are separate local values used only by the optional Docker test services. They are included by the setup script because Compose validates all service variables. The normal `dart test` suite uses embedded PostgreSQL and disables Redis; it does not require Docker test services.

No Clerk, MongoDB, or additional auth provider variables are used.

## Fresh clone: generate and run

Check `flutter --version`, `dart --version`, and `serverpod version` first. The project uses Serverpod 4.0.3 and requires Dart 3.12.2 or newer; use Dart bundled with Flutter. This setup does not install or upgrade tools.

From the repository root:

```sh
cd feedback_aggregator
flutter pub get
cd feedback_aggregator_server
python3 scripts/create_local_env.py
```

The script writes a Git-ignored `.env` with independent random credentials and restrictive file permissions. It never prints secrets or overwrites an existing `.env` or `config/passwords.yaml`. Add the optional provider variables privately to `.env` if needed. The `.env.example` file contains placeholders only.

Load the variables into the terminal before starting the services:

```sh
set -a
. ./.env
set +a
docker compose --env-file .env up -d --no-deps --pull never redis
```

`--pull never` uses the installed Docker image. If `redis:6.2.6` is absent on your friend's machine, they can explicitly pull that version first. Compose reads `.env` for container credentials; Serverpod reads exported environment variables or the ignored `config/passwords.yaml`. Serverpod does not automatically load this `.env` file. Source it in every terminal that starts the backend, including non-interactive shell scripts.

Build the website with the public Google client ID:

```sh
cd ../feedback_aggregator_flutter
flutter build web --base-href / --output ../feedback_aggregator_server/web/app \
  --dart-define=GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID"
cd ../feedback_aggregator_server
serverpod start --no-flutter
```

Open `http://localhost:8082/`. Without Google credentials, omit the build define and use email/password. PostgreSQL is managed by Serverpod's `database.dataPath`; only Redis needs the Compose container. Starting the server applies committed migrations. Keep the terminal's env loaded while the runner is active.

For tests, from the server directory with `.env` loaded:

```sh
dart test
```

## Existing installation

Keep `config/passwords.yaml` and the existing authentication/provider secrets. In an ignored `.env`, set the six backend variables from that file's active run-mode section, add independent Docker test passwords, and add any provider variables you need. Environment variables override `config/passwords.yaml` for every run mode. Changing a file does not update values already exported in a running terminal: source the updated `.env` and restart the runner from that terminal.

Changing Compose's PostgreSQL password only initializes a new Docker volume; it does not rotate an existing database role. Existing databases require an `ALTER ROLE` password change while preserving their data. Do not delete volumes to change a password.

## Redis secret exposure

The original repository included hardcoded development and test database/Redis passwords in Compose, and repeated credentials in CI/IDE configuration. Those literals have been removed, local development and test credentials rotated, and Compose database/Redis ports restricted to localhost. `.env`, `config/passwords.yaml`, and OAuth JSON stay ignored. CI creates fresh credentials for each run.

The old commit still contains the exposed values. Rotation makes them unusable for these local services; a new commit cannot erase Git history. Anyone running an older checkout or deployment must rotate its copies as well. After all affected instances have been updated, resolve the GitGuardian incident as revoked. Removing old history requires coordinated rewriting and a force-push, and does not revoke credentials on its own. See [GitHub's remediation guidance](https://docs.github.com/en/code-security/tutorials/remediate-leaked-secrets/remediating-a-leaked-secret).

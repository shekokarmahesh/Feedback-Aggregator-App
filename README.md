# Feedback Aggregator App

Flutter web frontend and Serverpod backend for aggregating and grouping user feedback.

The project lives in `feedback_aggregator/` and includes:

- `feedback_aggregator_flutter`: Flutter frontend with Serverpod email/password sign-in.
- `feedback_aggregator_server`: Serverpod backend, PostgreSQL, Redis, and authentication.
- `feedback_aggregator_client`: generated Dart client.

## Local development

Open `feedback_aggregator/` as the project folder in Codex to load its `AGENTS.md`, MCP configuration, and agent skills.

With Docker Desktop running, start Redis and then the development stack:

```sh
cd feedback_aggregator
docker compose -f feedback_aggregator_server/docker-compose.yaml up -d redis
serverpod start
```

The default development PostgreSQL database is managed by Serverpod using the configured `database.dataPath`. The Compose file also includes PostgreSQL services if you later choose Docker-based databases.

Serverpod starts the backend and configured Flutter web app. Email/password sign-up creates an account immediately without an OTP. Password resets send an expiring, single-use code through Resend; codes are not printed in server logs. See [email delivery setup](feedback_aggregator/EMAIL_AUTH_SETUP.md).

The app supports email/password sign-up, sign-in, password reset, session restoration, and sign-out. Google web sign-in uses Serverpod's OAuth2 PKCE flow. Configure its free OAuth credentials following [Google authentication setup](feedback_aggregator/GOOGLE_AUTH_SETUP.md).

After sign-in, the dashboard shows a sample feedback inbox with grouped request counts, search, status/source/priority filters, sorting, and ticket details. Top navigation includes the inbox, planned sources, and sample activity. The account menu loads your real Serverpod profile and offers account-security information and sign-out.

The greeting endpoint requires an authenticated Serverpod session. Tickets and activity are currently demo data. Live feedback sources, AI grouping, persisted tickets, and team roles still need implementation.

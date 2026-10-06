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

Serverpod starts the backend and configured Flutter web app. During development, authentication verification codes are printed in the server console. Production email delivery uses Serverpod Cloud's email service by default.

The scaffold currently contains the default greeting example behind sign-in. Feedback sources, AI grouping, the dashboard, and team roles still need implementation.

# Feedback Aggregator App

Flutter web frontend and Serverpod backend for aggregating and grouping user feedback.

The project lives in `feedback_aggregator/` and includes:

- `feedback_aggregator_flutter`: Flutter frontend with Serverpod email/password sign-in.
- `feedback_aggregator_server`: Serverpod backend, PostgreSQL, built-in memory caching, and authentication.
- `feedback_aggregator_client`: generated Dart client.

## Local development

Open `feedback_aggregator/` as the project folder in Codex to load its `AGENTS.md`, MCP configuration, and agent skills.

For a fresh clone, follow [collaborator setup](feedback_aggregator/COLLABORATOR_SETUP.md) to generate local secrets and configure Google/Resend. With an ignored `.env` configured, load it before starting the development stack:

```sh
cd feedback_aggregator/feedback_aggregator_server
set -a
. ./.env
set +a
serverpod start
```

Serverpod manages the development and test PostgreSQL databases using `database.dataPath`. Docker and Redis are not required. Caching uses Serverpod's built-in process memory; see [storage setup](feedback_aggregator/STORAGE_RESEARCH.md) for persistence and production considerations.

Serverpod starts the backend and configured Flutter web app. Email/password sign-up creates an account immediately without an OTP. Password resets send an expiring, single-use code through Resend; codes are not printed in server logs. See [email delivery setup](feedback_aggregator/EMAIL_AUTH_SETUP.md).

The app supports email/password sign-up, sign-in, password reset, session restoration, and sign-out. Google web sign-in uses Serverpod's OAuth2 PKCE flow. Configure its free OAuth credentials following [Google authentication setup](feedback_aggregator/GOOGLE_AUTH_SETUP.md).

After sign-in, the dashboard shows the selected workspace's persisted feedback with search, status/source/priority filters, sorting, and ticket details. New workspaces start empty; Admins and Editors can add feedback and change its status. The account menu loads your real Serverpod profile and offers account-security information and sign-out.

The public landing preview uses sample data. Live feedback connectors and AI grouping still need implementation.

Workspaces isolate each organization's feedback and team. Create a workspace after signing in, invite teammates through **Team**, and assign **Admin**, **Editor**, or **Viewer** access. **Create share link** works without an email provider or purchased domain. See [workspace setup and permissions](feedback_aggregator/WORKSPACES.md) for Resend delivery and access rules.

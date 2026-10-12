# Feedback webhook

`POST /webhooks/feedback` receives external form submissions on the Serverpod
web server (locally `http://localhost:8082`). It saves one Feedback row per valid
request. The dashboard still displays demo tickets.

## Setup

Use Dart 3.12.2 or newer compatible with the project's SDK constraint and
Serverpod CLI 4.0.3. Resolve workspace dependencies with `flutter pub get`.
The Feedback, Team, and FeedbackWebhookKey models and endpoint client must be
generated and their database migration created and
applied before this route can run. Use the project's Serverpod MCP workflow
for migration creation and application. Do not manually edit generated files.

After signing in, use the generated Serverpod client to provision your team and
generate an ingestion key:

```dart
final team = await client.feedbackIngestion.createTeam('My team');
final key = await client.feedbackIngestion.generateKey(team.id!);
// Keep key on the integrating backend. It is returned only once.
// To disable it:
await client.feedbackIngestion.revokeKey(team.id!, key);
```

These APIs require a signed-in Serverpod session. Key generation and revocation
require ownership of the selected team. A solo user can create a personal team.
Memberships, invitations, and shared administration are not yet implemented.

Each team can have multiple keys (for separate sources or rotation). Only SHA-256
hashes are stored in the separate `feedback_webhook_key` table, with `teamId`,
creator ID, creation time, and optional revocation time. The raw 256-bit key is
never saved. There is no longer a global `feedbackWebhookSecret` setting.
Missing, invalid, or revoked keys return 401; a database lookup failure returns 503.

## Submit feedback

Send the key as `X-Feedback-Webhook-Key`. All four fields are required strings:

| Field | Maximum characters |
| --- | --- |
| title | 200 |
| body | 20,000 |
| source | 100 |
| userEmail | 254; must have an email address format |

Values are trimmed; email is lowercased. `source` is a free-text channel name.
Email is contact information, not proof of ownership or an authorization role.
Client-supplied IDs, timestamps, `teamId`, and `team_id` are ignored. The webhook
always sets Feedback.teamId from the matching active key's teamId. Foreign keys
link feedback and ingestion keys to the team table.

```sh
curl -X POST http://localhost:8082/webhooks/feedback \
  -H 'X-Feedback-Webhook-Key: <key-returned-by-generateKey>' \
  -H 'Content-Type: application/json' \
  --data '{"title":"CSV export","body":"Please add export to CSV.","source":"website-support","userEmail":"user@example.com"}'
```

URL-encoded submissions (`application/x-www-form-urlencoded`) are also supported
using the same field names. Multipart uploads are not supported.

Successful writes return HTTP 201 with `id` and `createdAt`. Invalid input returns
400, bodies over 64 KiB return 413, unsupported content types return 415, and
database failures return 500 without exposing internal details.

Forward browser form submissions through your website's backend; keep the key
there. This route is intended for server-to-server calls and does not enable
cross-origin browser submissions. Use HTTPS for deployed integrations.

Each accepted call creates a new row; repeated deliveries currently create
duplicates. There is no source-specific payload mapping: external form providers
must send this field format or use an adapter on their backend.

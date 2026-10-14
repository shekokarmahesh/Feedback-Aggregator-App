# Source integrations and automatic issue grouping

Admins connect Email and Slack from **Sources**. Forms, Support, and App reviews have **Configure** dialogs containing the current website's `/webhooks/feedback` address, `Content-Type: application/json`, `X-Feedback-Webhook-Key: your-webhook-key`, a JSON example, and **Your webhook key**. Enter any nonempty key up to 128 characters to connect the current sample feed. The key is not saved or used to authorize real external webhook requests.

Initial connections import five reports. **Sync now** imports up to three additional reports, and the open workspace automatically syncs every 30 seconds. Feed sizes are Email 12, Slack 20, Forms 8, Support 15, and App reviews 9: 64 reports altogether. These providers use sample data; the existing Discord bot/guild flow remains live.

## Normal inbox

The separate Laya POC screen and endpoint have been removed. Imports, manually created feedback, existing workspace reports, and Discord webhook submissions enter the normal persistent grouping pipeline. Laya runs through the existing authenticated private service; no OpenRouter key or new provider credential is needed.

Serverpod future calls process reports independently of the browser. `app_grouping_job` stores a workspace's queue state, authorized requesting member, expiring worker lease, retry timing, and errors. `app_issue_group` stores persistent issue identity and team status. Each `app_workspace_ticket` remains an original report linked to its group, with model severity, confidence, and grouping state. The additive `20261014134312019-automatic-grouping` migration preserves existing tickets and authentication data.

Each worker rechecks the requesting member's workspace permission before inference and before committing results. It processes three reports per invocation, outside database transactions during model inference. Workspace locks and leases prevent concurrent workers from creating duplicate groups. Model failures preserve ungrouped reports, show a waiting state, and retry with backoff up to five minutes. Admins and Editors can use **Retry grouping**; Viewers only read results.

Candidate retrieval uses lexical overlap within the same workspace to shortlist three existing issues. Laya evaluates both title pairs and report-body pairs. A merge requires model probability at least 0.75, a margin of 0.08 over competing groups, and no strong contradiction between the two views. This is an operational policy, not an accuracy guarantee. Ambiguous matches become separate **Needs review** issues; no keyword-only or fabricated model result is used. The first issue also calls Laya for severity.

The inbox displays one row per issue, report counts, contributing platforms, grouping state, and a 0–100 priority score. Opening it shows the original source reports and available match confidence. Source filters match every contributing platform. Updating the row's status updates the persistent shared issue. The score combines up to 25 severity points (`25 × maximum model severity / 4`), 45 frequency points (`5 × visible report count`), and 30 platform points (`6 × visible platform count`). The default sort is **Priority score**.

## Disconnect and isolation

Disconnect hides all reports carrying that source label, including manual or previously stored reports. Group evidence, request counts, sources, titles, descriptions, confidence, and score derive from the remaining visible reports. An issue disappears when it has no visible reports. The card resets to Connect/Configure. Reload cannot restore hidden platform reports; reconnect restores the existing records without duplicates or lost team status.

Every endpoint verifies workspace membership. Group reads and model candidates include the workspace ID. Background jobs retain and revalidate their authorized actor. Hidden reports are not processed until reconnect, and model results cannot commit after that source disconnects or the actor loses write access. Local UI revision guards prevent stale requests from replacing the active workspace.

## Webhooks and limitations

Discord submissions are persisted as workspace reports and queued for grouping. The generic form/support webhook still requires a real team ingestion key and stores separate `Feedback` rows; bridging that real store into workspace reports remains follow-up work. The Configure flows described here simulate provider imports into the workspace inbox.

The pinned English Laya model can miss duplicates or produce uncertain matches. Original evidence remains available for team review. Inference runs sequentially on the existing Render CPU plan. Large backlogs take time; the inbox updates every 30 seconds while open. The current workspace query is bounded to 500 reports and the shortlist to three candidate groups; larger ingestion volumes need pagination and retrieval work.

No host development server was started. Use `serverpod start` yourself for local development. Render applies the committed migration on startup and runs durable grouping through Serverpod's built-in PostgreSQL-backed future-call scheduler, without Redis.

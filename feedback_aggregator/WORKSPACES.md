# Workspaces and organization isolation

A workspace is the organization's tenant. Accounts may belong to multiple workspaces, with a different role in each. The workspace creator becomes its first Admin.

| Role | Read feedback/team | Add feedback/update status | Invite/manage members |
| --- | --- | --- | --- |
| Admin | Yes | Yes | Yes |
| Editor | Yes | Yes | No |
| Viewer | Yes | No | No |

Sign in, choose **Create workspace**, then open **Team** to invite people. New invitations default to Viewer. Choose **Send invitation** for Resend delivery or **Create share link** to copy a link and share it directly with the addressed teammate without sending an email. Admins can change roles, remove other members, revoke pending invitations, and issue a replacement invitation. The last Admin cannot be removed or demoted. Role changes take effect on the next server request; refreshing the workspace updates the visible controls.

Feedback is now persisted in PostgreSQL for its workspace. The public landing preview still uses sample data. New workspaces start empty; Admins and Editors can use **Add feedback** and update a ticket's status from its detail panel. Sources are manually labeled; connectors and automated grouping are still planned. The inbox currently loads the latest 500 tickets, and the invitation history loads the latest 100 entries.

## Isolation boundary

`WorkspaceEndpoint` requires authentication. `WorkspaceService` checks the session's auth-user ID against membership on each tenant request. All feedback and membership lookups include the workspace ID, including ticket and member mutations. Client-supplied roles are never accepted as authorization. Invitations and internal membership rows are server-only models; invitation hashes never reach the client.

The tables share a PostgreSQL schema with workspace foreign keys and a unique membership per workspace/auth user. This is application-enforced tenant isolation, not separate databases or PostgreSQL row-level security. Every future tenant endpoint must use the same membership and role checks, including feedback connectors, jobs, storage, search, and caches. Never expose a tenant table directly or cache data without its workspace ID.

Workspace writes and member/invitation changes acquire a workspace row lock in a transaction. This protects the last-Admin rule and single-use acceptance under concurrent requests. Membership removal invalidates authorization on subsequent calls without waiting for the user's authentication token to expire.

## Invitations and Resend

Invitations use the existing `resendApiKey` and `resendFromEmail` passwords. The email includes a styled HTML button and a plain-text link. Its URL comes from `webServer.publicScheme`, `publicHost`, and `publicPort` in the active Serverpod config. Set these to the deployed app's public address before inviting remote teammates. A localhost invitation only works on the machine running the app.

Resend's default `onboarding@resend.dev` sender is restricted to the account owner's inbox. To invite arbitrary teammates, verify a sending domain in Resend and set `resendFromEmail` to an address on that domain. A rejected delivery returns an error and revokes the undelivered invitation; the UI does not claim success. Delivery accepted by Resend is not a guarantee of inbox delivery.

The URL uses `/#/invite?token=...`, so the token is kept out of the HTTP page path. Tokens are 32 random bytes, stored only as a SHA-256 hash, expire after seven days, and can be accepted once. Reissuing an invitation to an email revokes its older pending links. Only Admins can see invitation history; only creation returns a shareable URL. Share the URL only with its addressed recipient.

Recipients sign in or register with the invited email, then explicitly choose **Join workspace**. Email signup remains without an OTP: possession of the invitation link plus the matching signed-in profile is required to join. Google and password identities are not automatically merged because they share an email. Accepting an invite never overwrites an existing member's role.

## Verification

`test/integration/workspace_test.dart` covers cross-tenant access, role enforcement, invitation identity and expiry, revocation, single-use/concurrent acceptance, removal, mail failure, and concurrent last-Admin protection. `auth_email_test.dart` checks the Resend request and email template. Flutter tests check that a real workspace never renders the global sample inbox and that Editor controls act on the current ticket.

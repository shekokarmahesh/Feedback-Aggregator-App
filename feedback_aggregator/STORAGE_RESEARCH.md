# Runtime storage and caching

The project uses Serverpod **4.0.3**, embedded PostgreSQL for local development/tests, and Serverpod's built-in memory caches. Redis settings, Docker Compose, the backend Dockerfile, and container credentials have been removed. No database schema or authentication change is required.

## PostgreSQL

Development keeps `database.dataPath: .serverpod/development/pgdata`; tests keep `.serverpod/test/pgdata`. Serverpod starts and stops the real PostgreSQL process and reuses its cached binaries. Database files persist between restarts. Keep `.serverpod/` out of Git and preserve it when updating the app. [Embedded PostgreSQL](https://docs.serverpod.dev/concepts/data-and-the-database/database/embedded-postgres).

Users, workspaces, memberships, invitations, and tickets remain in PostgreSQL. Each developer has an independent local database. To share the same app data, connect both frontends to a single shared backend; sharing API keys or the repository does not synchronize databases.

Staging and production configurations use external PostgreSQL. Provision a durable database with backups and configure its host, database name, user, and password before deployment. The embedded setup is intended for development and tests. [Database connection](https://docs.serverpod.dev/concepts/data-and-the-database/database/connection).

## Built-in memory caches

| API | Purpose |
| --- | --- |
| `session.caches.local` | Application values in the current backend's RAM |
| `session.caches.localPrio` | A separate RAM cache for frequently used values |
| `session.caches.query` | Framework-managed cacheable database queries |

Serverpod creates these caches automatically. The current workspace endpoints read PostgreSQL directly; removing the external cache requires no additional ticket caching. Add application caching only when measured repeated work justifies it.

Use expiry and invalidate affected entries after writes. For tenant data, check membership before accessing the cache and include the workspace ID in every key. A cached response must not bypass current role checks. Memory caches disappear when the backend restarts; PostgreSQL remains the durable source of data. [Caching API](https://docs.serverpod.dev/concepts/endpoints-and-apis/caching).

No Redis service is configured in any run mode. Serverpod's `global` cache API therefore uses a separate local memory fallback, not a distributed cache. Messages and authentication-revocation notifications remain within the current process. Run one backend instance for this architecture; multiple instances would require a deliberate design for cross-instance cache invalidation and event delivery. [Cache scope](https://docs.serverpod.dev/concepts/endpoints-and-apis/caching), [server events](https://docs.serverpod.dev/concepts/endpoints-and-apis/server-events).

## Start and verify

Follow [collaborator setup](COLLABORATOR_SETUP.md) to generate/load the five core backend secrets and the optional Google/Resend credentials. Start `serverpod start` from the server directory. No container runtime or cache password is required.

Existing installations retain their database directories and authentication secrets. Remove old `SERVERPOD_REDIS_*` environment overrides before restarting the runner. Run `dart analyze` and `dart test`, then check live authentication, password recovery, workspace roles/invitations, and ticket operations after restart.

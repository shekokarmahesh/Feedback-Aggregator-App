# feedback_aggregator_server

Serverpod backend with embedded PostgreSQL for development/tests and built-in memory caching. No external cache service or container runtime is required.

From the repository root, load your configured local environment and start the server:

    cd feedback_aggregator/feedback_aggregator_server
    set -a
    . ./.env
    set +a
    serverpod start

For a fresh clone, generate `.env` first with `python3 scripts/create_local_env.py`. See [collaborator setup](../COLLABORATOR_SETUP.md) for Google and Resend credentials.

When you are finished, you can shut down the running server with `Q`.

#!/usr/bin/env python3
"""Create independent local credentials without printing or overwriting secrets."""

import os
from pathlib import Path
import secrets


def main():
    server_dir = Path(__file__).resolve().parent.parent
    env_path = server_dir / ".env"
    if env_path.exists():
        raise SystemExit(".env already exists; keeping your credentials unchanged.")
    if (server_dir / "config/passwords.yaml").exists():
        raise SystemExit(
            "config/passwords.yaml already exists. Keep its credentials and follow "
            "COLLABORATOR_SETUP.md to configure matching Compose values."
        )

    keys = {
        "SERVERPOD_PASSWORD_database": secrets.token_hex(32),
        "SERVERPOD_PASSWORD_redis": secrets.token_hex(32),
        "SERVERPOD_PASSWORD_serviceSecret": secrets.token_hex(32),
        "SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper": secrets.token_hex(32),
        "SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey": secrets.token_urlsafe(64),
        "SERVERPOD_PASSWORD_emailSecretHashPepper": secrets.token_hex(32),
        "POSTGRES_TEST_PASSWORD": secrets.token_hex(32),
        "REDIS_TEST_PASSWORD": secrets.token_hex(32),
    }
    contents = "# Local credentials; never commit or share this file publicly.\n"
    contents += "".join(f"{key}='{value}'\n" for key, value in keys.items())
    contents += (
        "\n# Add shared provider credentials privately if you need these features.\n"
        "# SERVERPOD_PASSWORD_resendApiKey='<resend-api-key>'\n"
        "# SERVERPOD_PASSWORD_resendFromEmail='Feedback Aggregator <onboarding@resend.dev>'\n"
        "# SERVERPOD_PASSWORD_googleClientSecret='<complete-google-oauth-json>'\n"
        "# GOOGLE_CLIENT_ID='<public-client-id>.apps.googleusercontent.com'\n"
    )
    fd = os.open(env_path, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    with os.fdopen(fd, "w") as env_file:
        env_file.write(contents)
    print("Created feedback_aggregator_server/.env with independent local secrets.")
    print("Load it before starting Serverpod: set -a; . ./.env; set +a")


if __name__ == "__main__":
    main()

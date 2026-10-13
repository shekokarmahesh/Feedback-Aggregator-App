BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_discord_guild" (
    "id" bigserial PRIMARY KEY,
    "workspaceId" bigint NOT NULL,
    "guildId" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "discord_guild_unique" ON "app_discord_guild" USING btree ("guildId");
CREATE UNIQUE INDEX "discord_workspace_unique" ON "app_discord_guild" USING btree ("workspaceId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_discord_guild"
    ADD CONSTRAINT "app_discord_guild_fk_0"
    FOREIGN KEY("workspaceId")
    REFERENCES "app_workspace"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR feedback_aggregator
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('feedback_aggregator', '20261012182322938-discord-guild', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261012182322938-discord-guild', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;

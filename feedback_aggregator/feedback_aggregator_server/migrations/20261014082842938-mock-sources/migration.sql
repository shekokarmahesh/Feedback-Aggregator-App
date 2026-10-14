BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_mock_source_connection" (
    "id" bigserial PRIMARY KEY,
    "workspaceId" bigint NOT NULL,
    "source" text NOT NULL,
    "connected" boolean NOT NULL DEFAULT false,
    "connectedAt" timestamp without time zone,
    "lastSyncedAt" timestamp without time zone,
    "syncedCount" bigint NOT NULL DEFAULT 0,
    "availableCount" bigint NOT NULL DEFAULT 0
);

-- Indexes
CREATE UNIQUE INDEX "mock_source_workspace_unique" ON "app_mock_source_connection" USING btree ("workspaceId", "source");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "app_workspace_ticket" ADD COLUMN "isMock" boolean NOT NULL DEFAULT false;
ALTER TABLE "app_workspace_ticket" ADD COLUMN "externalId" text;
CREATE UNIQUE INDEX "workspace_ticket_external_unique" ON "app_workspace_ticket" USING btree ("workspaceId", "source", "externalId");
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_mock_source_connection"
    ADD CONSTRAINT "app_mock_source_connection_fk_0"
    FOREIGN KEY("workspaceId")
    REFERENCES "app_workspace"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR feedback_aggregator
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('feedback_aggregator', '20261014082842938-mock-sources', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261014082842938-mock-sources', "timestamp" = now();

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

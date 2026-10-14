BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_grouping_job" (
    "id" bigserial PRIMARY KEY,
    "workspaceId" bigint NOT NULL,
    "requestedBy" uuid NOT NULL,
    "status" text NOT NULL DEFAULT 'idle'::text,
    "scheduledAt" timestamp without time zone,
    "leaseToken" text,
    "leaseUntil" timestamp without time zone,
    "retryAt" timestamp without time zone,
    "failures" bigint NOT NULL DEFAULT 0,
    "lastError" text
);

-- Indexes
CREATE UNIQUE INDEX "grouping_job_workspace" ON "app_grouping_job" USING btree ("workspaceId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_issue_group" (
    "id" bigserial PRIMARY KEY,
    "workspaceId" bigint NOT NULL,
    "status" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "issue_group_workspace" ON "app_issue_group" USING btree ("workspaceId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "app_workspace_ticket" ADD COLUMN "issueGroupId" bigint;
ALTER TABLE "app_workspace_ticket" ADD COLUMN "groupingState" text NOT NULL DEFAULT 'pending'::text;
ALTER TABLE "app_workspace_ticket" ADD COLUMN "groupingConfidence" double precision;
ALTER TABLE "app_workspace_ticket" ADD COLUMN "severity" double precision;
CREATE INDEX "workspace_ticket_grouping" ON "app_workspace_ticket" USING btree ("workspaceId", "issueGroupId");
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_grouping_job"
    ADD CONSTRAINT "app_grouping_job_fk_0"
    FOREIGN KEY("workspaceId")
    REFERENCES "app_workspace"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_issue_group"
    ADD CONSTRAINT "app_issue_group_fk_0"
    FOREIGN KEY("workspaceId")
    REFERENCES "app_workspace"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_workspace_ticket"
    ADD CONSTRAINT "app_workspace_ticket_fk_1"
    FOREIGN KEY("issueGroupId")
    REFERENCES "app_issue_group"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- MIGRATION VERSION FOR feedback_aggregator
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('feedback_aggregator', '20261014134312019-automatic-grouping', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261014134312019-automatic-grouping', "timestamp" = now();

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

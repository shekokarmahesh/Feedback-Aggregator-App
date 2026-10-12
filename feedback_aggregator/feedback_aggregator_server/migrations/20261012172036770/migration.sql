BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "feedback" (
    "id" bigserial PRIMARY KEY,
    "team_id" bigint NOT NULL,
    "title" text NOT NULL,
    "body" text NOT NULL,
    "source" text NOT NULL,
    "userEmail" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "feedback_team_created_idx" ON "feedback" USING btree ("team_id", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "feedback_team" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "ownerUserId" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "feedback_team_owner_idx" ON "feedback_team" USING btree ("ownerUserId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "feedback_webhook_key" (
    "id" bigserial PRIMARY KEY,
    "team_id" bigint NOT NULL,
    "keyHash" text NOT NULL,
    "createdByUserId" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "revokedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "feedback_webhook_key_hash_idx" ON "feedback_webhook_key" USING btree ("keyHash");
CREATE INDEX "feedback_webhook_key_team_idx" ON "feedback_webhook_key" USING btree ("team_id");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "feedback"
    ADD CONSTRAINT "feedback_fk_0"
    FOREIGN KEY("team_id")
    REFERENCES "feedback_team"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "feedback_webhook_key"
    ADD CONSTRAINT "feedback_webhook_key_fk_0"
    FOREIGN KEY("team_id")
    REFERENCES "feedback_team"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR feedback_aggregator
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('feedback_aggregator', '20261012172036770', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261012172036770', "timestamp" = now();

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

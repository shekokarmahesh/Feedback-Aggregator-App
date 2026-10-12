BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_workspace" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_workspace_invitation" (
    "id" bigserial PRIMARY KEY,
    "workspaceId" bigint NOT NULL,
    "email" text NOT NULL,
    "role" text NOT NULL,
    "tokenHash" text NOT NULL,
    "createdBy" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" timestamp without time zone NOT NULL,
    "acceptedAt" timestamp without time zone,
    "revokedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "workspace_invite_token_unique" ON "app_workspace_invitation" USING btree ("tokenHash");
CREATE INDEX "workspace_invites_lookup" ON "app_workspace_invitation" USING btree ("workspaceId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_workspace_member" (
    "id" bigserial PRIMARY KEY,
    "workspaceId" bigint NOT NULL,
    "authUserId" uuid NOT NULL,
    "email" text NOT NULL,
    "name" text NOT NULL,
    "role" text NOT NULL,
    "joinedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "workspace_user_unique" ON "app_workspace_member" USING btree ("workspaceId", "authUserId");
CREATE INDEX "workspace_user_lookup" ON "app_workspace_member" USING btree ("authUserId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_workspace_ticket" (
    "id" bigserial PRIMARY KEY,
    "workspaceId" bigint NOT NULL,
    "title" text NOT NULL,
    "description" text NOT NULL,
    "source" text NOT NULL,
    "status" text NOT NULL,
    "priority" text NOT NULL,
    "supporters" bigint NOT NULL,
    "requester" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "workspace_ticket_lookup" ON "app_workspace_ticket" USING btree ("workspaceId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_workspace_invitation"
    ADD CONSTRAINT "app_workspace_invitation_fk_0"
    FOREIGN KEY("workspaceId")
    REFERENCES "app_workspace"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_workspace_member"
    ADD CONSTRAINT "app_workspace_member_fk_0"
    FOREIGN KEY("workspaceId")
    REFERENCES "app_workspace"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_workspace_ticket"
    ADD CONSTRAINT "app_workspace_ticket_fk_0"
    FOREIGN KEY("workspaceId")
    REFERENCES "app_workspace"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR feedback_aggregator
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('feedback_aggregator', '20261006122214354-workspaces', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261006122214354-workspaces', "timestamp" = now();

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

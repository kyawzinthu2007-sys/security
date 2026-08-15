-- ============================================================
-- TalentShowoff Mail — Supabase schema (SEPARATE project from the job board)
-- Run this in this mail project's SQL Editor -> New query -> Run
-- ============================================================

create extension if not exists "pgcrypto";

-- ---------- Mailboxes ----------
-- One row per job-board user who opted in to create a mailbox.
-- owner_username links back to the job board's username (no foreign key,
-- since it lives in a different database/project).
create table if not exists mailboxes (
    id              uuid primary key default gen_random_uuid(),
    owner_username  text not null unique,               -- job board username, lowercase
    local_part      text not null unique,                -- e.g. "jane.doe" (the part before @)
    address         text generated always as (local_part || '@talentshowoff.com') stored unique,
    display_name    text not null default '',
    is_active       boolean not null default true,
    quota_mb        integer not null default 2048,
    created_at      timestamptz not null default now(),
    updated_at      timestamptz not null default now()
);

create index if not exists idx_mailboxes_owner on mailboxes (lower(owner_username));
create index if not exists idx_mailboxes_local_part on mailboxes (lower(local_part));

-- ---------- Folders (per-mailbox; system folders auto-created) ----------
create table if not exists folders (
    id              uuid primary key default gen_random_uuid(),
    mailbox_id      uuid not null references mailboxes(id) on delete cascade,
    name            text not null,                        -- 'Inbox','Sent','Drafts','Spam','Trash', or custom
    is_system       boolean not null default false,
    created_at      timestamptz not null default now(),
    unique (mailbox_id, name)
);

-- ---------- Messages ----------
create table if not exists messages (
    id              uuid primary key default gen_random_uuid(),
    mailbox_id      uuid not null references mailboxes(id) on delete cascade,
    folder_id       uuid not null references folders(id) on delete cascade,

    message_uid     text,                    -- Resend/email Message-ID header, for threading
    in_reply_to     text,                    -- Message-ID this replies to
    thread_id       uuid,                    -- groups a conversation together

    from_address    text not null,
    from_name       text not null default '',
    to_addresses    text[] not null default '{}',
    cc_addresses    text[] not null default '{}',
    bcc_addresses   text[] not null default '{}',

    subject         text not null default '(no subject)',
    body_text       text not null default '',
    body_html       text,

    is_read         boolean not null default false,
    is_starred      boolean not null default false,
    is_draft        boolean not null default false,

    search_vector   tsvector generated always as (
                        to_tsvector('english',
                            coalesce(subject,'') || ' ' ||
                            coalesce(from_address,'') || ' ' ||
                            coalesce(body_text,''))
                    ) stored,

    created_at      timestamptz not null default now(),
    sent_at         timestamptz
);

create index if not exists idx_messages_mailbox_folder on messages (mailbox_id, folder_id, created_at desc);
create index if not exists idx_messages_search on messages using gin (search_vector);
create index if not exists idx_messages_thread on messages (thread_id);

-- ---------- Helper: create the standard system folders for a new mailbox ----------
create or replace function create_system_folders(p_mailbox_id uuid)
returns void as $$
begin
    insert into folders (mailbox_id, name, is_system)
    values
        (p_mailbox_id, 'Inbox', true),
        (p_mailbox_id, 'Sent', true),
        (p_mailbox_id, 'Drafts', true),
        (p_mailbox_id, 'Spam', true),
        (p_mailbox_id, 'Trash', true)
    on conflict (mailbox_id, name) do nothing;
end;
$$ language plpgsql;

-- Auto-create system folders whenever a mailbox is inserted
create or replace function trg_mailbox_after_insert()
returns trigger as $$
begin
    perform create_system_folders(new.id);
    return new;
end;
$$ language plpgsql;

drop trigger if exists mailbox_created on mailboxes;
create trigger mailbox_created
    after insert on mailboxes
    for each row execute function trg_mailbox_after_insert();

-- ---------- updated_at bump ----------
create or replace function trg_touch_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

drop trigger if exists mailboxes_touch on mailboxes;
create trigger mailboxes_touch
    before update on mailboxes
    for each row execute function trg_touch_updated_at();

-- ============================================================
-- Row Level Security
-- The job board backend uses the SERVICE ROLE key server-side (bypasses
-- RLS by design), so these policies mainly protect against any future
-- direct client access.
-- ============================================================
alter table mailboxes enable row level security;
alter table folders enable row level security;
alter table messages enable row level security;

-- No public policies are defined: with RLS enabled and zero policies,
-- the anon/public key can read or write NOTHING. Only the service role
-- key (used exclusively by the backend) can access these tables.


-- Compatibility fixes for existing Mail Supabase databases.
-- The current Flask application does not use mailbox password_hash.
ALTER TABLE public.mailboxes
  ADD COLUMN IF NOT EXISTS owner_username TEXT;

ALTER TABLE public.mailboxes
  DROP COLUMN IF EXISTS password_hash;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mailboxes_owner_username_lower
  ON public.mailboxes (lower(owner_username));

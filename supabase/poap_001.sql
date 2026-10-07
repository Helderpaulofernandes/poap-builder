-- PoaP Builder (team beta): shared programmes on Supabase
-- Runs in the SAME Supabase project as StageMap and reuses its access list
-- (allowed_emails, is_allowed(), the "before user created" hook). Run StageMap's schema.sql first
-- (already done if StageMap works), then paste this into SQL Editor → New query → Run. Safe to re-run.
-- Nothing here changes a StageMap table or function: everything PoaP adds starts with poap_.
--
-- Model: a programme is a set of elements stored one row each: kind 'item' (bars, milestones,
-- curtains, summaries), 'lane' and 'style' (bar/milestone/curtain types), plus project-wide settings
-- (title block, page, timeline, branding, progress and logic options). People only collide when they
-- edit the same element at the same moment (the later save wins).

-- ---------------------------------------------------------------- tables
create table if not exists public.poap_projects (
  id          text primary key,
  name        text not null default 'New programme',
  settings    jsonb not null default '{}'::jsonb,
  created_by  uuid not null default auth.uid() references auth.users(id),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table if not exists public.poap_members (
  project_id  text not null references public.poap_projects(id) on delete cascade,
  user_id     uuid not null references auth.users(id) on delete cascade,
  email       text not null,
  role        text not null check (role in ('owner', 'editor', 'viewer')),
  added_at    timestamptz not null default now(),
  primary key (project_id, user_id)
);

create table if not exists public.poap_invites (
  project_id  text not null references public.poap_projects(id) on delete cascade,
  email       text not null,
  role        text not null check (role in ('owner', 'editor', 'viewer')),
  invited_by  uuid default auth.uid(),
  created_at  timestamptz not null default now(),
  primary key (project_id, email)
);

create table if not exists public.poap_entities (
  project_id  text not null references public.poap_projects(id) on delete cascade,
  kind        text not null check (kind in ('item', 'lane', 'style')),
  id          text not null,
  data        jsonb,
  deleted     boolean not null default false,
  client_id   text,                                    -- the browser window that wrote it (it skips its own echo)
  updated_at  timestamptz not null default now(),
  updated_by  uuid default auth.uid(),
  primary key (project_id, kind, id)
);
create index if not exists poap_entities_project on public.poap_entities(project_id);

-- ---------------------------------------------------------------- membership lookups
create or replace function public.poap_role(p text) returns text
language sql stable security definer set search_path = public as $$
  select role from poap_members where project_id = p and user_id = auth.uid()
$$;

create or replace function public.poap_can_edit(p text) returns boolean
language sql stable security definer set search_path = public as $$
  select public.is_allowed() and coalesce(public.poap_role(p) in ('owner', 'editor'), false)
$$;

-- ---------------------------------------------------------------- row level security
alter table public.poap_projects enable row level security;
alter table public.poap_members  enable row level security;
alter table public.poap_invites  enable row level security;
alter table public.poap_entities enable row level security;

drop policy if exists poap_projects_read   on public.poap_projects;
drop policy if exists poap_projects_insert on public.poap_projects;
drop policy if exists poap_projects_update on public.poap_projects;
drop policy if exists poap_projects_delete on public.poap_projects;
create policy poap_projects_read   on public.poap_projects for select using (is_allowed() and poap_role(id) is not null);
create policy poap_projects_insert on public.poap_projects for insert with check (is_allowed() and created_by = auth.uid());
create policy poap_projects_update on public.poap_projects for update using (poap_can_edit(id)) with check (poap_can_edit(id));
create policy poap_projects_delete on public.poap_projects for delete using (is_allowed() and poap_role(id) = 'owner');

drop policy if exists poap_members_read   on public.poap_members;
drop policy if exists poap_members_manage on public.poap_members;
create policy poap_members_read   on public.poap_members for select using (is_allowed() and poap_role(project_id) is not null);
create policy poap_members_manage on public.poap_members for all using (is_allowed() and poap_role(project_id) = 'owner')
  with check (is_allowed() and poap_role(project_id) = 'owner');

drop policy if exists poap_invites_read   on public.poap_invites;
drop policy if exists poap_invites_manage on public.poap_invites;
create policy poap_invites_read   on public.poap_invites for select
  using (is_allowed() and (poap_role(project_id) = 'owner' or lower(email) = lower(auth.jwt() ->> 'email')));
create policy poap_invites_manage on public.poap_invites for all using (is_allowed() and poap_role(project_id) = 'owner')
  with check (is_allowed() and poap_role(project_id) = 'owner');

drop policy if exists poap_entities_read   on public.poap_entities;
drop policy if exists poap_entities_insert on public.poap_entities;
drop policy if exists poap_entities_update on public.poap_entities;
create policy poap_entities_read   on public.poap_entities for select using (is_allowed() and poap_role(project_id) is not null);
create policy poap_entities_insert on public.poap_entities for insert with check (poap_can_edit(project_id));
create policy poap_entities_update on public.poap_entities for update using (poap_can_edit(project_id)) with check (poap_can_edit(project_id));
-- elements are soft-deleted (deleted = true) so everyone's live view hears about it

-- ---------------------------------------------------------------- creating programmes, invites
create or replace function public.poap_on_project_created() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into poap_members(project_id, user_id, email, role)
  values (new.id, new.created_by, lower(coalesce(auth.jwt() ->> 'email', '')), 'owner')
  on conflict do nothing;
  return new;
end $$;
drop trigger if exists poap_project_owner on public.poap_projects;
create trigger poap_project_owner after insert on public.poap_projects for each row execute function public.poap_on_project_created();

-- Called after sign-in: turn PoaP invites for my email into memberships.
create or replace function public.poap_claim_invites() returns integer
language plpgsql security definer set search_path = public as $$
declare n integer;
begin
  if not public.is_allowed() then return 0; end if;
  insert into poap_members(project_id, user_id, email, role)
  select i.project_id, auth.uid(), lower(i.email), i.role
  from poap_invites i where lower(i.email) = lower(auth.jwt() ->> 'email')
  on conflict (project_id, user_id) do update set role = excluded.role;
  get diagnostics n = row_count;
  delete from poap_invites where lower(email) = lower(auth.jwt() ->> 'email');
  return n;
end $$;
grant execute on function public.poap_claim_invites() to authenticated;

-- invited addresses are kept in lower case, however they're typed
create or replace function public.poap_lower_invite() returns trigger language plpgsql as $$
begin new.email := lower(trim(new.email)); return new; end $$;
drop trigger if exists poap_invites_lower on public.poap_invites;
create trigger poap_invites_lower before insert or update on public.poap_invites for each row execute function public.poap_lower_invite();

-- ---------------------------------------------------------------- timestamps
create or replace function public.poap_touch() returns trigger language plpgsql as $$
begin new.updated_at := now(); new.updated_by := auth.uid(); return new; end $$;
drop trigger if exists poap_entities_touch on public.poap_entities;
create trigger poap_entities_touch before insert or update on public.poap_entities for each row execute function public.poap_touch();
create or replace function public.poap_touch_project() returns trigger language plpgsql as $$
begin new.updated_at := now(); return new; end $$;
drop trigger if exists poap_projects_touch on public.poap_projects;
create trigger poap_projects_touch before update on public.poap_projects for each row execute function public.poap_touch_project();

-- ---------------------------------------------------------------- history: every saved version of every element
create table if not exists public.poap_entity_history (
  seq         bigint generated always as identity primary key,
  project_id  text not null references public.poap_projects(id) on delete cascade,
  kind        text not null,
  id          text not null,
  data        jsonb,
  deleted     boolean not null default false,
  changed_at  timestamptz not null default now(),
  changed_by  uuid,
  changed_by_email text
);
create index if not exists poap_entity_history_lookup on public.poap_entity_history(project_id, kind, id, seq desc);

create or replace function public.poap_record_history() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'UPDATE' and old.data is not distinct from new.data and old.deleted = new.deleted then
    return null;   -- nothing really changed
  end if;
  insert into poap_entity_history(project_id, kind, id, data, deleted, changed_by, changed_by_email)
  values (new.project_id, new.kind, new.id, new.data, new.deleted, auth.uid(), auth.jwt() ->> 'email');
  return null;
end $$;
drop trigger if exists poap_entities_history on public.poap_entities;
create trigger poap_entities_history after insert or update on public.poap_entities
  for each row execute function public.poap_record_history();

alter table public.poap_entity_history enable row level security;
drop policy if exists poap_history_read on public.poap_entity_history;
create policy poap_history_read on public.poap_entity_history for select
  using (public.is_allowed() and public.poap_role(project_id) is not null);

-- ---------------------------------------------------------------- live updates
do $$ begin
  alter publication supabase_realtime add table public.poap_entities;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.poap_projects;
exception when duplicate_object then null; end $$;

notify pgrst, 'reload schema';

-- ---------------------------------------------------------------- check it worked
-- select table_name from information_schema.tables where table_name like 'poap_%' order by 1;
--   → poap_entities, poap_entity_history, poap_invites, poap_members, poap_projects

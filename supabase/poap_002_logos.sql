-- PoaP Builder: the team's client logo library (pick a logo instead of importing it every time)
-- Run once in Supabase: SQL Editor -> New query -> paste -> Run. Safe to re-run.
-- Needs poap_001.sql and StageMap's schema.sql (for is_allowed(), the access list) already run.
-- Anyone on the access list can see, add, rename and remove logos; nothing here touches another table.

create table if not exists public.poap_logos (
  id          text primary key,                         -- from the original image, so the same logo is stored once
  name        text not null default 'Client logo',
  logo        text not null,                            -- the logo as it prints (data URL, already cropped)
  src         text,                                     -- the original image, so it can be adjusted again
  crop        jsonb,                                    -- the crop and colour settings used
  created_by  uuid default auth.uid() references auth.users(id),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

alter table public.poap_logos enable row level security;

drop policy if exists poap_logos_read   on public.poap_logos;
drop policy if exists poap_logos_insert on public.poap_logos;
drop policy if exists poap_logos_update on public.poap_logos;
drop policy if exists poap_logos_delete on public.poap_logos;
create policy poap_logos_read   on public.poap_logos for select using (public.is_allowed());
create policy poap_logos_insert on public.poap_logos for insert with check (public.is_allowed());
create policy poap_logos_update on public.poap_logos for update using (public.is_allowed()) with check (public.is_allowed());
create policy poap_logos_delete on public.poap_logos for delete using (public.is_allowed());

grant select, insert, update, delete on public.poap_logos to authenticated;

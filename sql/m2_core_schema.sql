create extension if not exists pgcrypto;

-- Drop problematic elements to ensure a clean re-creation
DROP TABLE IF EXISTS organisations CASCADE;
DROP TABLE IF EXISTS organisation_members CASCADE;
DROP FUNCTION IF EXISTS is_member(uuid) CASCADE;
DROP POLICY IF EXISTS org_select ON organisations; -- Added
DROP POLICY IF EXISTS org_write ON organisations;
DROP POLICY IF EXISTS org_update ON organisations;
DROP POLICY IF EXISTS org_delete ON organisations;
DROP POLICY IF EXISTS members_select_own ON organisation_members;
DROP POLICY IF EXISTS members_insert_own_owner ON organisation_members;
DROP POLICY IF EXISTS members_update_own ON organisation_members;
DROP POLICY IF EXISTS members_delete_own ON organisation_members;

create table if not exists organisations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  owner_id uuid references auth.users(id) not null,
  created_at timestamptz default now()
);
-- Grant base permissions to authenticated role
GRANT SELECT, INSERT, UPDATE, DELETE ON public.organisations TO authenticated;

create table if not exists organisation_members (
  organisation_id uuid not null references organisations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'editor' check (role in ('owner','admin','editor')),
  primary key (organisation_id, user_id)
);
-- Grant base permissions to authenticated role
GRANT SELECT, INSERT, UPDATE, DELETE ON public.organisation_members TO authenticated;

create table if not exists properties (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references organisations(id) on delete cascade,
  name text not null,
  address text,
  created_at timestamptz default now()
);
-- Grant base permissions to authenticated role
GRANT SELECT, INSERT, UPDATE, DELETE ON public.properties TO authenticated;

create table if not exists guides (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references properties(id) on delete cascade,
  title text not null,
  theme_json jsonb default '{}'::jsonb,
  status text default 'draft' check (status in ('draft','published')),
  updated_at timestamptz default now()
);
-- Grant base permissions to authenticated role
GRANT SELECT, INSERT, UPDATE, DELETE ON public.guides TO authenticated;

create table if not exists guide_pages (
  id uuid primary key default gen_random_uuid(),
  guide_id uuid not null references guides(id) on delete cascade,
  title text not null,
  position int not null
);
-- Grant base permissions to authenticated role
GRANT SELECT, INSERT, UPDATE, DELETE ON public.guide_pages TO authenticated;

create table if not exists guide_sections (
  id uuid primary key default gen_random_uuid(),
  page_id uuid not null references guide_pages(id) on delete cascade,
  title text,
  position int not null
);
-- Grant base permissions to authenticated role
GRANT SELECT, INSERT, UPDATE, DELETE ON public.guide_sections TO authenticated;

create table if not exists guide_blocks (
  id uuid primary key default gen_random_uuid(),
  section_id uuid not null references guide_sections(id) on delete cascade,
  type text not null,          -- 'heading'|'text'|'list'|'image'|...
  value_json jsonb not null,   -- block payload
  position int not null
);
-- Grant base permissions to authenticated role
GRANT SELECT, INSERT, UPDATE, DELETE ON public.guide_blocks TO authenticated;

alter table organisations enable row level security;
alter table organisation_members enable row level security;
alter table properties enable row level security;
alter table guides enable row level security;
alter table guide_pages enable row level security;
alter table guide_sections enable row level security;
alter table guide_blocks enable row level security;

-- Now, re-create the is_member function (which depends on organisation_members)
create or replace function is_member(org_id uuid)
returns boolean language sql stable as $$
  select exists (
    select 1 from organisation_members
    where organisation_id = org_id and user_id = auth.uid()
  );
$$;

-- organisations policies
create policy org_select on organisations for select using (owner_id = auth.uid());
create policy org_write on organisations for insert with check (auth.role() = 'authenticated');
create policy org_update on organisations for update using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy org_delete on organisations for delete using (owner_id = auth.uid());

-- organisation_members policies
-- Policy to allow a user to select their own member record
create policy "members_select_own" on organisation_members for select
using (
  auth.uid() = user_id
);

-- Policy to allow authenticated users to insert a new member record for themselves as an owner when creating a new org.
create policy "members_insert_own_owner" on organisation_members for insert
with check (
  auth.uid() = user_id AND role = 'owner'
);

-- Policy to allow a user to update their own role
create policy "members_update_own" on organisation_members for update
using (
  auth.uid() = user_id
) with check (
  auth.uid() = user_id
);

-- Policy to allow a user to delete their own member record
create policy "members_delete_own" on organisation_members for delete
using (
  auth.uid() = user_id
);

-- properties policies
create policy props_select on properties for select using (is_member(organisation_id));
create policy props_write on properties for all using (is_member(organisation_id)) with check (is_member(organisation_id));

-- guides policies
create policy guides_select on guides for select using (exists (
  select 1 from properties p
  join organisation_members m on m.organisation_id = p.organisation_id
  where p.id = guides.property_id and m.user_id = auth.uid()
));
create policy guides_write on guides for all using (exists (
  select 1 from properties p
  join organisation_members m on m.organisation_id = p.organisation_id
  where p.id = guides.property_id and m.user_id = auth.uid()
)) with check (exists (
  select 1 from properties p
  join organisation_members m on m.organisation_id = p.organisation_id
  where p.id = guides.property_id and m.user_id = auth.uid()
));

-- pages policies
create policy pages_select on guide_pages for select using (exists (
  select 1 from guides g
  join properties p on p.id = g.property_id
  join organisation_members m on m.organisation_id = p.organisation_id
  where g.id = guide_pages.guide_id and m.user_id = auth.uid()
));
create policy pages_write on guide_pages for all using (exists (
  select 1 from guides g
  join properties p on p.id = g.property_id
  join organisation_members m on m.organisation_id = p.organisation_id
  where g.id = guide_pages.guide_id and m.user_id = auth.uid()
)) with check (exists (
  select 1 from guides g
  join properties p on p.id = g.property_id
  join organisation_members m on m.organisation_id = p.organisation_id
  where g.id = guide_pages.guide_id and m.user_id = auth.uid()
));

-- sections policies
create policy sections_select on guide_sections for select using (exists (
  select 1 from guide_pages gp
  join guides g on g.id = gp.guide_id
  join properties p on p.id = g.property_id
  join organisation_members m on m.organisation_id = p.organisation_id
  where gp.id = guide_sections.page_id and m.user_id = auth.uid()
));
create policy sections_write on guide_sections for all using (exists (
  select 1 from guide_pages gp
  join guides g on g.id = gp.guide_id
  join properties p on p.id = g.property_id
  join organisation_members m on m.organisation_id = p.organisation_id
  where gp.id = guide_sections.page_id and m.user_id = auth.uid()
)) with check (exists (
  select 1 from guide_pages gp
  join guides g on g.id = gp.guide_id
  join properties p on p.id = g.property_id
  join organisation_members m on m.organisation_id = p.organisation_id
  where gp.id = guide_sections.page_id and m.user_id = auth.uid()
));

-- blocks policies
create policy blocks_select on guide_blocks for select using (exists (
  select 1 from guide_sections gs
  join guide_pages gp on gp.id = gs.page_id
  join guides g on g.id = gp.guide_id
  join properties p on p.id = g.property_id
  join organisation_members m on m.organisation_id = p.organisation_id
  where gs.id = guide_blocks.section_id and m.user_id = auth.uid()
));
create policy blocks_write on guide_blocks for all using (exists (
  select 1 from guide_sections gs
  join guide_pages gp on gp.id = gs.page_id
  join guides g on g.id = gp.guide_id
  join properties p on p.id = g.property_id
  join organisation_members m on m.organisation_id = p.organisation_id
  where gs.id = guide_blocks.section_id and m.user_id = auth.uid()
)) with check (exists (
  select 1 from guide_sections gs
  join guide_pages gp on gp.id = gs.page_id
  join guides g on g.id = gp.guide_id
  join properties p on p.id = g.property_id
  join organisation_members m on m.organisation_id = p.organisation_id
  where gs.id = guide_blocks.section_id and m.user_id = auth.uid()
));

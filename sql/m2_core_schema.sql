create extension if not exists pgcrypto;

create table if not exists organisations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz default now()
);

create table if not exists organisation_members (
  organisation_id uuid not null references organisations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'editor' check (role in ('owner','admin','editor')),
  primary key (organisation_id, user_id)
);

create table if not exists properties (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references organisations(id) on delete cascade,
  name text not null,
  address text,
  created_at timestamptz default now()
);

create table if not exists guides (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references properties(id) on delete cascade,
  title text not null,
  theme_json jsonb default '{}'::jsonb,
  status text default 'draft' check (status in ('draft','published')),
  updated_at timestamptz default now()
);

create table if not exists guide_pages (
  id uuid primary key default gen_random_uuid(),
  guide_id uuid not null references guides(id) on delete cascade,
  title text not null,
  position int not null
);

create table if not exists guide_sections (
  id uuid primary key default gen_random_uuid(),
  page_id uuid not null references guide_pages(id) on delete cascade,
  title text,
  position int not null
);

create table if not exists guide_blocks (
  id uuid primary key default gen_random_uuid(),
  section_id uuid not null references guide_sections(id) on delete cascade,
  type text not null,          -- 'heading'|'text'|'list'|'image'|...
  value_json jsonb not null,   -- block payload
  position int not null
);

alter table organisations enable row level security;
alter table organisation_members enable row level security;
alter table properties enable row level security;
alter table guides enable row level security;
alter table guide_pages enable row level security;
alter table guide_sections enable row level security;
alter table guide_blocks enable row level security;

create or replace function is_member(org_id uuid)
returns boolean language sql stable as $$
  select exists (
    select 1 from organisation_members
    where organisation_id = org_id and user_id = auth.uid()
  );
$$;

-- organisations
create policy org_select on organisations for select using (is_member(id));
create policy org_write  on organisations for all using (is_member(id)) with check (true);

-- organisation_members (view own row; admins manage)
create policy members_select on organisation_members for select
using (
  auth.uid() = user_id or exists (
    select 1 from organisation_members om
    where om.organisation_id = organisation_members.organisation_id
      and om.user_id = auth.uid() and om.role in ('owner','admin')
  )
);
create policy members_write on organisation_members for all
using (
  exists (
    select 1 from organisation_members om
    where om.organisation_id = organisation_members.organisation_id
      and om.user_id = auth.uid() and om.role in ('owner','admin')
  )
) with check (
  exists (
    select 1 from organisation_members om
    where om.organisation_id = organisation_members.organisation_id
      and om.user_id = auth.uid() and om.role in ('owner','admin')
  )
);

-- properties
create policy props_select on properties for select using (is_member(organisation_id));
create policy props_write  on properties for all using (is_member(organisation_id)) with check (is_member(organisation_id));

-- guides
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

-- pages
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

-- sections
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

-- blocks
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


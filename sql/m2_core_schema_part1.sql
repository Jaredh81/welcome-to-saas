create extension if not exists pgcrypto;

-- Drop problematic elements to ensure a clean re-creation
DROP TABLE IF EXISTS organisation_members CASCADE;
DROP TABLE IF EXISTS organisations CASCADE;
DROP TABLE IF EXISTS properties CASCADE;
DROP TABLE IF EXISTS guides CASCADE;
DROP TABLE IF EXISTS guide_pages CASCADE;
DROP TABLE IF EXISTS guide_sections CASCADE;
DROP TABLE IF EXISTS guide_blocks CASCADE;


create table if not exists organisations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
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

create table if not exists published_guides (
  guide_id uuid primary key,
  slug text unique not null,
  snapshot_json jsonb not null,
  published_at timestamptz default now()
);
alter table published_guides enable row level security;
create policy "public read published" on published_guides
for select using (true);



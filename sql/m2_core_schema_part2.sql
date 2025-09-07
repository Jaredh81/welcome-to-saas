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

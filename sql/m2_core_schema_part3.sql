-- organisations policies
create policy org_select on organisations for select using (is_member(id));
create policy org_write on organisations for insert with check (auth.role() = 'authenticated');
create policy org_update on organisations for update using (is_member(id)) with check (is_member(id));
create policy org_delete on organisations for delete using (is_member(id));

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

alter table storage.objects enable row level security;
create policy "public read assets"
  on storage.objects for select using (bucket_id = 'assets');
create policy "members write assets"
  on storage.objects for insert with check (bucket_id = 'assets');
create policy "members update/delete assets"
  on storage.objects for update using (bucket_id = 'assets') with check (bucket_id = 'assets');


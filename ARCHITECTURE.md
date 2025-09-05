# System Architecture

## 1. High-Level Architecture Diagram

```
+----------------+          +-------------------+          +-------------------+
|                |          |                   |          |                   |
|  Guest Client  |<-------->|     Netlify       |<-------->|      Supabase     |
|  (React/Vite)  |          | (Static Hosting,  |          | (Auth, Postgres,  |
|                |          |   Edge Functions) |          |  Storage, RLS)    |
+----------------+          +-------------------+          |                   |
                                                           |   +-------------+   |
                                                           |   |  Postgres   |   |
                                                           |   |   Database  |   |
                                                           |   +-------------+   |
                                                           |         |         |
                                                           |   +-------------+   |
                                                           |   |   Storage   |   |
                                                           |   +-------------+   |
                                                           |         |         |
                                                           |   +-------------+   |
                                                           |   |    Auth     |   |
                                                           |   +-------------+   |
                                                           +-------------------+
```

## 2. Data Model: Tables and Relationships

### Core Entities

| Table                | Description                                                | Relationships                                     | RLS Policy                                            |
|----------------------|------------------------------------------------------------|---------------------------------------------------|-------------------------------------------------------|
| `organisations`      | Top-level tenant, e.g., a hotel chain                      | `organisation_members` (1:N)                      | Members see only their organization's rows            |
| `organisation_members` | Links users to organisations with roles                  | `organisations` (N:1), `auth.users` (N:1)         | Members see their own, admins see all in org          |
| `properties`         | Physical locations within an organization                  | `organisations` (N:1)                             | Members see properties of their organization          |
| `guides`             | Editable guides (drafts or published)                      | `properties` (N:1), `published_guides` (1:1)      | Members see guides of their organization's properties |
| `guide_pages`        | Pages within a guide                                       | `guides` (N:1)                                    | Members see pages of their organization's guides      |
| `guide_sections`     | Sections within a guide page                               | `guide_pages` (N:1)                               | Members see sections of their organization's pages    |
| `guide_blocks`       | Individual content blocks within a section                 | `guide_sections` (N:1)                            | Members see blocks of their organization's sections   |
| `published_guides`   | Denormalized, read-only snapshot of published guides       | `guides` (1:1)                                    | Public read-only                                      |
| `storage.objects`    | Supabase Storage for assets (M4)                           | N/A                                               | Public read; members write own assets (M4)            |

## 3. Row-Level Security (RLS) Model

Supabase RLS is central to multi-tenancy and data segregation.

- **`published_guides`**:
    - Policy: `public read published`
    - Logic: `for select using (true)`
    - Explanation: Anyone can read published guide snapshots.

- **`organisations`**:
    - Policy: `org_select`, `org_write`
    - Logic: `using (is_member(id))` and `with check (is_member(id))`
    - Explanation: Only authenticated users who are members of an organization can view or modify its details.

- **`organisation_members`**:
    - Policy: `members_select`, `members_write`
    - Logic: `using (auth.uid() = user_id or is_admin_of_org(organisation_id))` and `with check (is_admin_of_org(organisation_id))` (simplified)
    - Explanation: Members can view their own membership; organization owners/admins can view and manage all members within their organization.

- **`properties`, `guides`, `guide_pages`, `guide_sections`, `guide_blocks`**:
    - Policy: `[table]_select`, `[table]_write`
    - Logic: Chained `is_member` checks through foreign keys up to the `organisations` table.
    - Explanation: Data access is restricted to members of the organization that owns the parent property/guide/page/section/block, ensuring multi-tenant isolation.
    - `is_member` function is used for this purpose:
        ```sql
        create or replace function is_member(org_id uuid)
        returns boolean language sql stable as $$
          select exists (
            select 1 from organisation_members
            where organisation_id = org_id and user_id = auth.uid()
          );
        $$;
        ```


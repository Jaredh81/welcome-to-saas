# Project Milestones

This document outlines the project milestones with their respective acceptance criteria. Each milestone is designed to be small, shippable, and deliver tangible value.

## M1 — Guest View (Public)

**Goal:** Enable public, read-only access to published guides via a unique slug, matching the visual specification.

### Acceptance Criteria:

- React app scaffolded in `/apps/guest` using Vite.
- `app.css` ported from `/reference` to `/apps/guest/src/styles/app.css`.
- Dependencies (`react`, `react-dom`, `react-router-dom`, `@supabase/supabase-js`) installed.
- Supabase client configured to read `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` from environment variables.
- Route `/g/:slug` correctly fetches `published_guides.snapshot_json` from Supabase.
- The fetched data is rendered as a grid of cards (with emoji + title), visually matching the live spec (
    https://cosmic-bavarois-a43022.netlify.app/).
- Client-side search functionality is implemented for instant filtering of cards.
- Existing class names (`top`, `brand`, `logo`, `chip`, `shell`, `content`, `content-top`, `avatar`, `search`, `share`, `grid`, `card`, `ico`, `ttl`, `bottom`, `tab`) are preserved.
- Basic accessibility (a11y) considerations implemented: semantic HTML (`<header>`, `<main>`), focus rings, and keyboard-navigable cards.
- Netlify deployment configured to use environment variables.
- Only `published_guides` table is publicly accessible via RLS.
- No console errors or warnings in the browser.
- Lighthouse report shows no severe accessibility or best-practice issues.
- `README.md` updated with instructions for running and deploying the guest application.
- A short demo video (<2 min) is attached to the PR.

## M2 — Auth + Org/Property Setup (Private)

**Goal:** Implement user authentication and allow authenticated members to set up organizations and properties.

### Acceptance Criteria:

- Supabase authentication (magic link) is integrated.
- Users can sign in and sign out.
- Authenticated members can create a new organization.
- Authenticated members can create properties within their organization.
- Row-Level Security (RLS) is active, ensuring members can only see data belonging to their organization.
- Demo shows a user signing in, creating an organization and a property, and then viewing the listed organization/property.

## M3 — Guide Editor (Draft) + Publish Snapshot

**Goal:** Provide an administrative interface for creating and editing guides, with the ability to publish a guide as a read-only snapshot for public viewing.

### Acceptance Criteria:

- A minimal React admin editor is implemented (for pages, sections, and blocks).
- Core editor components are developed and refined to support: Section, Image, Accordion, Info Block, Feature Grid, HTML, Wi-Fi QR Code, Tile Set, List, Status Box, Heading, and Rich Text blocks.
- The editor writes data to the relational tables (`guides`, `guide_pages`, `guide_sections`, `guide_blocks`).
- A "Publish" feature is implemented that denormalizes the current guide content into a `snapshot_json` in the `published_guides` table.
- Publishing a guide updates the corresponding public guest page (`/g/:slug`).
- Demo shows editing a guide in the admin editor, publishing it, and then verifying the changes on the public guest view.

## M4 — Storage & Images

**Goal:** Integrate Supabase Storage for image management within the guide editor, allowing images to be uploaded and displayed.

### Acceptance Criteria:

- Supabase Storage bucket named `assets` is configured with public read and member write policies.
- The guide editor allows uploading images to the `assets` bucket.
- Image blocks in the editor use the uploaded image URLs.
- Images in published guides are lazy-loaded for performance.
- Demo shows uploading an image, adding it to a guide, publishing the guide, and then verifying the image displays correctly and lazy-loads on the public guest view.
havee a strong backround in ui and nd 
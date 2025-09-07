# Project Risks and Mitigations

This document outlines the top 5 identified risks for the project and their proposed mitigations.

## 1. Supabase RLS Complexity & Misconfiguration

- **Description:** Incorrectly configured Row-Level Security (RLS) policies in Supabase could lead to unauthorized data access or data leakage across tenants. This is a critical security risk for a multi-tenant SaaS application.
- **Mitigation:**
    - Thorough review of all RLS policies by at least two developers.
    - Automated testing of RLS policies for each table to ensure correct data isolation.
    - Implement a `is_member` function (as defined in `m2_core_schema.sql`) for consistent and reusable RLS logic.
    - Regular security audits and penetration testing.

## 2. Visual Parity with Reference Spec

- **Description:** Achieving exact visual parity with the provided live reference and `app.css` without using a UI kit can be time-consuming and prone to minor inconsistencies across browsers/devices.
- **Mitigation:**
    - Utilize existing `app.css` classes as much as possible.
    - Implement a robust component structure that encapsulates styling.
    - Cross-browser and cross-device testing using tools like BrowserStack or similar services.
    - Regular visual regressions testing (manual for M1, automated later if necessary).
    - Prioritize key visual elements for strict adherence and allow minor deviations for less critical components if development time becomes a constraint.

## 3. Performance for Large Guides / Client-Side Search

- **Description:** For very large guides with many pages/sections/blocks, fetching the entire `snapshot_json` for client-side search could lead to performance bottlenecks and slow initial load times for the guest view.
- **Mitigation:**
    - Optimize `snapshot_json` structure to include only necessary data for display and search.
    - Implement debouncing for the search input to reduce re-renders.
    - Consider client-side virtualization or pagination for very long lists of search results.
    - If client-side search becomes a significant bottleneck, explore server-side search capabilities (e.g., Supabase full-text search) in future milestones as a trade-off for increased backend complexity.

## 4. Supabase Vendor Lock-in / Migration Complexity

- **Description:** Relying heavily on Supabase-specific features (Auth, RLS, Storage, Postgres extensions) could make future migration to a different backend provider challenging and costly.
- **Mitigation:**
    - Abstract Supabase client interactions behind a `lib/supabase.ts` module to centralize API calls.
    - Design data models to be as generic as possible, minimizing reliance on Supabase-specific Postgres extensions where alternatives exist.
    - Document Supabase-specific implementations clearly to aid in potential future refactoring.
    - Prioritize business logic separation from data access layers.

## 5. Development Velocity with Documentation Overhead

- **Description:** Maintaining comprehensive documentation (Architecture, Milestones, Folder Structure, Risks) alongside development can sometimes slow down the initial development velocity, especially for a small team.
- **Mitigation:**
    - Keep documentation concise and high-level, focusing on essential information.
    - Integrate documentation updates into the regular development workflow and treat them as first-class citizens in pull requests.
    - Utilize templates (like the PR template) to standardize and streamline documentation efforts.
    - Leverage AI assistance for initial drafting and formatting of documentation.


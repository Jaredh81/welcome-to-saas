# Folder Structure

This document describes the target folder structure for the project, facilitating organization and maintainability.

```
/
  /reference                          # Existing visual spec and code references
  /apps
    /guest                            # React guest application (M1)
      index.html                      # Main HTML file for the app
      vite.config.ts                  # Vite configuration for the guest app
      package.json                    # Project dependencies and scripts for guest app
      /src
        main.tsx                      # Entry point for the React app
        App.tsx                       # Main application component
        /components                   # Reusable React components
          TopBar.tsx
          SearchBar.tsx
          CardGrid.tsx
          Card.tsx
        /lib                          # Utility functions and Supabase client
          supabase.ts                 # Supabase client initialization
          types.ts                    # TypeScript type definitions
        /styles                       # Application-specific styles
          app.css                     # Ported from /reference/app.css
  /sql                                # SQL migration scripts and RLS policies
    m1_published.sql                  # SQL for published_guides table and RLS
    m2_core_schema.sql                # SQL for core multi-tenant schema and RLS
    storage_policies.sql              # SQL for Supabase Storage RLS policies (M4)
  /.github                            # GitHub specific configurations
    pull_request_template.md          # Template for pull requests
```

## Required Environment Variables

These environment variables are necessary for the application to function correctly, both locally and when deployed on Netlify.

- `VITE_SUPABASE_URL`: The URL of your Supabase project API.
- `VITE_SUPABASE_ANON_KEY`: The public `anon` key for your Supabase project. This is safe to expose in client-side code.

*(Future additions for M4+ will include Stripe-related keys for Netlify Functions, e.g., `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`)*


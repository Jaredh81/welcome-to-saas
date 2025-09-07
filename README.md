# welcome-to-saas

This repository contains the codebase for a multi-tenant SaaS application, starting with a public guest view.

## M1: Guest View (Public) - Setup and Run Instructions

This section outlines how to set up and run the `/apps/guest` application locally and deploy it.

### 1. Prerequisites

*   Node.js (LTS version recommended) and npm installed.
*   A Supabase project created and configured.

### 2. Environment Variables Setup

The guest application requires Supabase API keys to fetch data. These are loaded from a `.env` file.

1.  **Obtain Supabase Keys:** From your Supabase project dashboard, navigate to **Project Settings -> API**.
    *   Copy your `Project URL` (e.g., `https://<your-project-id>.supabase.co`).
    *   Copy your `anon (public)` key.
2.  **Create `.env` file:** In the `apps/guest` directory, create a file named `.env`.
3.  **Add Keys to `.env`:** Paste the copied keys into `apps/guest/.env` in the following format:

    ```
    VITE_SUPABASE_URL="YOUR_SUPABASE_PROJECT_URL"
    VITE_SUPABASE_ANON_KEY="YOUR_SUPABASE_ANON_KEY"
    ```
    *   **Important:** Ensure your keys are enclosed in double-quotes and the variables are prefixed with `VITE_`.

### 3. Install Dependencies

Navigate to the `apps/guest` directory and install the required Node.js packages:

```bash
cd apps/guest
npm install
```

### 4. Run Locally

After installing dependencies and setting up environment variables, start the development server:

```bash
cd apps/guest
npm run dev
```

The application will typically be accessible at `http://localhost:5173/`. To view a sample guide, navigate to `http://localhost:5173/g/sample-guide`.

### 5. Deployment to Netlify

To deploy the `apps/guest` application to Netlify:

1.  **Link your GitHub repository to Netlify.**
2.  **Configure Build Settings:**
    *   **Base directory:** `apps/guest`
    *   **Build command:** `npm run build`
    *   **Publish directory:** `apps/guest/dist`
3.  **Set Environment Variables:** In Netlify, go to **Site settings -> Build & deploy -> Environment**. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` with your Supabase project's values.
4.  **Deploy Site.**

## M2: Admin View (Private) - Setup and Run Instructions

This section outlines how to set up and run the `/apps/admin` application locally and deploy it.

### 1. Prerequisites

*   Node.js (LTS version recommended) and npm installed.
*   A Supabase project created and configured (same as M1, but ensure RLS is set up for admin tables).

### 2. Environment Variables Setup

The admin application requires Supabase API keys to function. These are loaded from a `.env` file.

1.  **Obtain Supabase Keys:** From your Supabase project dashboard, navigate to **Project Settings -> API**.
    *   Copy your `Project URL` (e.g., `https://<your-project-id>.supabase.co`).
    *   Copy your `anon (public)` key.
2.  **Create `.env` file:** In the `apps/admin` directory, create a file named `.env`.
3.  **Add Keys to `.env`:** Paste the copied keys into `apps/admin/.env` in the following format:

    ```
    VITE_SUPABASE_URL="YOUR_SUPABASE_PROJECT_URL"
    VITE_SUPABASE_ANON_KEY="YOUR_SUPABASE_ANON_KEY"
    ```
    *   **Important:** Ensure your keys are enclosed in double-quotes and the variables are prefixed with `VITE_`.

### 3. Install Dependencies

Navigate to the `apps/admin` directory and install the required Node.js packages:

```bash
cd apps/admin
npm install
```

### 4. Run Locally

After installing dependencies and setting up environment variables, start the development server:

```bash
cd apps/admin
npm run dev
```

The admin application will typically be accessible at `http://localhost:5173/` (or another port if the guest app is already running). You can access the authentication page at `http://localhost:5173/auth` and the account page after sign-in at `http://localhost:5173/`.

### 5. Deployment to Netlify

To deploy the `apps/admin` application to Netlify:

1.  **Link your GitHub repository to Netlify.**
2.  **Configure Build Settings:**
    *   **Base directory:** `apps/admin`
    *   **Build command:** `npm run build`
    *   **Publish directory:** `apps/admin/dist`
3.  **Set Environment Variables:** In Netlify, go to **Site settings -> Build & deploy -> Environment**. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` with your Supabase project's values.
4.  **Deploy Site.**
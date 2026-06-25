# Supabase Setup Guide — Oswego County Monument

## Step 1 — Create Your Supabase Project

1. Go to **supabase.com** and sign in (or create an account)
2. Click **New Project**
3. Fill in:
   - **Project name:** `oswego-county-monument` (or whatever you like)
   - **Database password:** Save this somewhere safe — you'll need it if you ever connect directly to Postgres
   - **Region:** `East US (N. Virginia)` — closest to New York
4. Click **Create new project** — takes about 2 minutes to spin up

---

## Step 2 — Run the Schema

1. In your project dashboard, click **SQL Editor** in the left sidebar
2. Click **New query**
3. Open `monument-schema.sql`, select all, copy
4. Paste into the SQL editor
5. Click **Run** (green button)
6. You should see "Success. No rows returned" — that means it worked

---

## Step 3 — Create Storage Buckets (for photos and design files)

1. Click **Storage** in the left sidebar
2. Click **New bucket** — create two:

   **Bucket 1:**
   - Name: `order-photos`
   - Public: **OFF** (toggle off)
   - Click Save

   **Bucket 2:**
   - Name: `design-files`
   - Public: **OFF**
   - Click Save

---

## Step 4 — Get Your API Keys

1. Click **Project Settings** (gear icon, bottom left)
2. Click **API** in the settings menu
3. You need two things — copy and save both:
   - **Project URL** — looks like `https://xxxxxxxxxxxx.supabase.co`
   - **anon/public key** — long string starting with `eyJ...`

   ⚠️ Never share your `service_role` key — only use `anon` in the app

---

## Step 5 — Add Keys to the App

In `monument-enhanced.html`, find this section near the top of the `<script>` block:

```javascript
// ── SUPABASE CONFIG ──
const SUPABASE_URL  = 'PASTE_YOUR_URL_HERE';
const SUPABASE_KEY  = 'PASTE_YOUR_ANON_KEY_HERE';
```

Replace the placeholder text with your actual URL and key. Save the file.

---

## Step 6 — Test It

1. Open `monument-enhanced.html` in Chrome or Safari
2. Log in with the default PIN: **1234**
3. Create a test order
4. Go to your Supabase dashboard → **Table Editor** → `orders`
5. You should see the order appear there within a second or two

If it shows up — you're connected. ✅

---

## What Happens With Photos

Photos and design files are stored in **Supabase Storage**, not in the database.
When you add a photo to an order:
- The image uploads to the `order-photos` bucket
- The order record saves the file path and metadata
- When viewing, the app fetches a signed URL for display

This keeps your database fast and your photo storage separate.

---

## Offline Mode

The app works offline automatically:
- On load: syncs everything from Supabase into local memory
- While offline: reads from memory, writes queue locally
- When back online: queued writes push to Supabase

If the installer has no signal at the cemetery — no problem. Photos and checklist updates save locally and sync when they're back in range.

---

## Your API Keys — Keep Them Private

The `anon` key is safe to put in the HTML file **as long as the file stays on your devices**. It's not published to the internet — you're delivering the HTML file directly to customers.

If you ever build a web-hosted version, you'll handle keys differently. For the delivered HTML file model, this approach is standard and secure.

---

## Backup

Your data is now in two places:
1. **Supabase** — the source of truth, cloud-synced
2. **Local memory/cache** — in the app while it's open

To export a full JSON backup anytime: More → Backup

To export directly from Supabase: Dashboard → Table Editor → any table → Export CSV


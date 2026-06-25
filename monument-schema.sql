-- ================================================================
-- OSWEGO COUNTY MONUMENT — Supabase Schema
-- Run this entire file in the Supabase SQL Editor
-- Dashboard → SQL Editor → New Query → Paste → Run
-- ================================================================

-- ── LOCATIONS ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS locations (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  address     TEXT,
  phone       TEXT,
  email       TEXT,
  manager     TEXT,
  color       TEXT DEFAULT '#1a5fb4',
  initials    TEXT,
  active      BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── STAFF / USERS ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS staff (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  role        TEXT NOT NULL DEFAULT 'staff',
  pin         TEXT NOT NULL,
  location_id TEXT REFERENCES locations(id) ON DELETE SET NULL,
  email       TEXT,
  phone       TEXT,
  active      BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── CLIENTS ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS clients (
  id          TEXT PRIMARY KEY,
  first_name  TEXT,
  last_name   TEXT,
  phone       TEXT,
  email       TEXT,
  address     TEXT,
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── CEMETERIES ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cemeteries (
  id                  TEXT PRIMARY KEY,
  name                TEXT NOT NULL,
  address             TEXT,
  city                TEXT,
  contact_name        TEXT,
  phone               TEXT,
  email               TEXT,
  permit_required     BOOLEAN DEFAULT FALSE,
  permit_fee          NUMERIC(10,2),
  section_lot_format  TEXT,
  installation_rules  TEXT,
  access_hours        TEXT,
  notes               TEXT,
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ── SUPPLIERS ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS suppliers (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  category    TEXT,
  contact     TEXT,
  phone       TEXT,
  email       TEXT,
  website     TEXT,
  address     TEXT,
  emoji       TEXT DEFAULT '🏭',
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── ORDERS ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
  id                    TEXT PRIMARY KEY,
  order_number          INTEGER,
  status                TEXT DEFAULT 'New Order',
  location_id           TEXT REFERENCES locations(id) ON DELETE SET NULL,
  client_id             TEXT REFERENCES clients(id) ON DELETE SET NULL,
  storage_location      TEXT,
  companion_order_id    TEXT,

  -- Decedent Record
  deceased_first        TEXT,
  deceased_last         TEXT,
  deceased_dob          DATE,
  deceased_dod          DATE,
  relationship_to_buyer TEXT,

  -- Veteran Info
  is_veteran            BOOLEAN DEFAULT FALSE,
  vet_branch            TEXT,
  vet_conflict          TEXT,
  vet_rank              TEXT,
  vet_va_claim          TEXT,
  vet_medallion_type    TEXT,

  -- Monument Details
  monument_type         TEXT,
  material              TEXT,
  color                 TEXT,
  finish                TEXT,
  dimensions            TEXT,
  base_type             TEXT,
  foundation_type       TEXT,
  inscription           TEXT,

  -- Proof Workflow
  proof_status          TEXT DEFAULT 'none',
  proof_sent_date       DATE,
  proof_approved_date   DATE,
  proof_approved_by     TEXT,
  proof_notes           TEXT,

  -- Installation
  cemetery_id           TEXT REFERENCES cemeteries(id) ON DELETE SET NULL,
  section_lot           TEXT,
  install_date          DATE,
  due_date              DATE,
  installer_id          TEXT REFERENCES staff(id) ON DELETE SET NULL,

  -- Pricing & Job Costing
  price                 NUMERIC(10,2) DEFAULT 0,
  deposit_paid          NUMERIC(10,2) DEFAULT 0,
  material_cost         NUMERIC(10,2) DEFAULT 0,
  labor_hours           NUMERIC(6,2)  DEFAULT 0,

  -- Checklists (stored as JSON arrays)
  install_checklist     JSONB DEFAULT '[]',
  qc_checklist          JSONB DEFAULT '[]',

  -- Photos stored as JSON array of {id, name, photo_type, storage_path, created_at}
  -- Actual image files live in Supabase Storage bucket "order-photos"
  photos                JSONB DEFAULT '[]',

  -- Design files as JSON array of {id, name, size, storage_path, created_at}
  -- Actual files live in Supabase Storage bucket "design-files"
  design_files          JSONB DEFAULT '[]',

  notes                 TEXT,
  created_at            TIMESTAMPTZ DEFAULT NOW(),
  updated_at            TIMESTAMPTZ DEFAULT NOW()
);

-- ── INVOICES ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS invoices (
  id          TEXT PRIMARY KEY,
  inv_number  TEXT,
  client_id   TEXT REFERENCES clients(id) ON DELETE SET NULL,
  order_id    TEXT REFERENCES orders(id)  ON DELETE SET NULL,
  location_id TEXT REFERENCES locations(id) ON DELETE SET NULL,
  amount      NUMERIC(10,2) DEFAULT 0,
  paid        NUMERIC(10,2) DEFAULT 0,
  status      TEXT DEFAULT 'Unpaid',
  due_date    DATE,
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── LEADS ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS leads (
  id            TEXT PRIMARY KEY,
  first_name    TEXT,
  last_name     TEXT,
  phone         TEXT,
  email         TEXT,
  inquiry_type  TEXT,
  stage         TEXT DEFAULT 'New Inquiry',
  value         NUMERIC(10,2),
  source        TEXT,
  notes         TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ── INVENTORY ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS inventory (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  category    TEXT,
  color       TEXT,
  qty         NUMERIC(10,2) DEFAULT 0,
  unit        TEXT DEFAULT 'pcs',
  reorder_qty NUMERIC(10,2) DEFAULT 1,
  unit_cost   NUMERIC(10,2) DEFAULT 0,
  supplier_id TEXT REFERENCES suppliers(id) ON DELETE SET NULL,
  location_id TEXT REFERENCES locations(id) ON DELETE SET NULL,
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── PRICE BOOK ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS price_book (
  id                      TEXT PRIMARY KEY,
  name                    TEXT NOT NULL,
  category                TEXT,
  material                TEXT,
  base_price              NUMERIC(10,2) DEFAULT 0,
  lettering_cost_per_char NUMERIC(6,2)  DEFAULT 3.50,
  options                 JSONB DEFAULT '[]',
  emoji                   TEXT DEFAULT '🪨',
  notes                   TEXT,
  active                  BOOLEAN DEFAULT TRUE,
  created_at              TIMESTAMPTZ DEFAULT NOW()
);

-- ── COMMUNICATION TEMPLATES ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS comm_templates (
  id         TEXT PRIMARY KEY,
  name       TEXT NOT NULL,
  category   TEXT DEFAULT 'General',
  body       TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── ACTIVITY LOG ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS activity_log (
  id         TEXT PRIMARY KEY,
  title      TEXT,
  sub        TEXT,
  order_id   TEXT,
  color      TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── APP SETTINGS (single row) ───────────────────────────────────
CREATE TABLE IF NOT EXISTS app_settings (
  id         INTEGER PRIMARY KEY DEFAULT 1,
  settings   JSONB DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
INSERT INTO app_settings (id, settings) VALUES (1, '{}')
  ON CONFLICT (id) DO NOTHING;

-- ================================================================
-- AUTO-UPDATE updated_at TIMESTAMPS
-- ================================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER leads_updated_at
  BEFORE UPDATE ON leads
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER settings_updated_at
  BEFORE UPDATE ON app_settings
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ================================================================
-- INDEXES — speeds up common queries
-- ================================================================
CREATE INDEX IF NOT EXISTS idx_orders_client     ON orders(client_id);
CREATE INDEX IF NOT EXISTS idx_orders_location   ON orders(location_id);
CREATE INDEX IF NOT EXISTS idx_orders_status     ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_install    ON orders(install_date);
CREATE INDEX IF NOT EXISTS idx_orders_updated    ON orders(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_invoices_client   ON invoices(client_id);
CREATE INDEX IF NOT EXISTS idx_invoices_status   ON invoices(status);
CREATE INDEX IF NOT EXISTS idx_activity_order    ON activity_log(order_id);
CREATE INDEX IF NOT EXISTS idx_activity_created  ON activity_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_leads_stage       ON leads(stage);

-- ================================================================
-- ROW LEVEL SECURITY
-- For your own shop: disabled (you control the anon key)
-- For resale version: enable this and add company_id to all tables
-- ================================================================
-- Disabled for now — single tenant, private anon key controls access
-- ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
-- (uncomment when building multi-tenant resale version)

-- ================================================================
-- STORAGE BUCKETS
-- After running this SQL, go to Storage → New Bucket and create:
--   1. "order-photos"  — public: false
--   2. "design-files"  — public: false
-- ================================================================


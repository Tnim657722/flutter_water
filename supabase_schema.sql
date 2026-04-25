-- ================================================================
-- AquaFlow — Supabase Schema + Seed Data
-- รันใน Supabase Dashboard > SQL Editor
-- ================================================================

-- 1. Users (custom auth, ไม่ใช้ Supabase Auth)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'customer')),
  full_name TEXT NOT NULL,
  phone TEXT DEFAULT '',
  address TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Products
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  unit TEXT NOT NULL,
  price_per_unit NUMERIC NOT NULL DEFAULT 0,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Stock Transactions
CREATE TABLE IF NOT EXISTS stock_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  product_name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('in', 'out')),
  quantity INTEGER NOT NULL,
  note TEXT,
  created_by TEXT DEFAULT 'admin',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Orders
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number TEXT UNIQUE NOT NULL,
  customer_id UUID REFERENCES users(id) ON DELETE SET NULL,
  customer_name TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','assigned','delivering','delivered','cancelled')),
  total_amount NUMERIC NOT NULL DEFAULT 0,
  delivery_address TEXT NOT NULL DEFAULT '',
  delivery_date DATE NOT NULL,
  note TEXT,
  proof_photo_url TEXT,
  delivered_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Order Items
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  product_name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  price_per_unit NUMERIC NOT NULL,
  subtotal NUMERIC NOT NULL
);

-- ================================================================
-- Disable RLS (ง่ายสำหรับ demo / ส่งครู)
-- ================================================================
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
ALTER TABLE stock_transactions DISABLE ROW LEVEL SECURITY;
ALTER TABLE orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE order_items DISABLE ROW LEVEL SECURITY;

-- ================================================================
-- Storage Bucket สำหรับรูปหลักฐานส่งของ
-- ================================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('delivery-proofs', 'delivery-proofs', true)
ON CONFLICT (id) DO NOTHING;

-- Allow public access to delivery-proofs bucket
CREATE POLICY "Public delivery proofs"
ON storage.objects FOR ALL
USING (bucket_id = 'delivery-proofs')
WITH CHECK (bucket_id = 'delivery-proofs');

-- ================================================================
-- SEED DATA — ข้อมูลตัวอย่าง
-- ================================================================

-- Users
INSERT INTO users (id, username, password, role, full_name, phone, address) VALUES
  ('00000000-0000-0000-0000-000000000001', 'admin', 'admin', 'admin',
   'ผู้ดูแลระบบ', '081-000-0000', 'โรงงาน AquaFlow กรุงเทพฯ'),
  ('00000000-0000-0000-0000-000000000002', 'somchai', '1234', 'customer',
   'สมชาย ใจดี', '081-234-5678', '123 ถ.สุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110'),
  ('00000000-0000-0000-0000-000000000003', 'malee', '1234', 'customer',
   'มาลี รักดี', '082-345-6789', '456 ถ.พระราม 9 แขวงห้วยขวาง เขตห้วยขวาง กรุงเทพฯ 10310'),
  ('00000000-0000-0000-0000-000000000004', 'wanchai', '1234', 'customer',
   'วันชัย ธุรกิจดี', '083-456-7890', '789 ถ.รัชดาภิเษก แขวงดินแดง เขตดินแดง กรุงเทพฯ 10400')
ON CONFLICT (id) DO NOTHING;

-- Products
INSERT INTO products (id, name, unit, price_per_unit) VALUES
  ('10000000-0000-0000-0000-000000000001', 'น้ำดื่ม 600ml', 'แพค (12 ขวด)', 60),
  ('10000000-0000-0000-0000-000000000002', 'น้ำดื่ม 1.5L', 'แพค (6 ขวด)', 75),
  ('10000000-0000-0000-0000-000000000003', 'น้ำดื่ม 5L', 'ถัง', 25),
  ('10000000-0000-0000-0000-000000000004', 'น้ำดื่ม 18.9L', 'ถัง', 35)
ON CONFLICT (id) DO NOTHING;

-- Stock (รับของเข้าจากโรงงาน)
INSERT INTO stock_transactions (product_id, product_name, type, quantity, note, created_by) VALUES
  ('10000000-0000-0000-0000-000000000001', 'น้ำดื่ม 600ml', 'in', 200, 'รับจากโรงงาน ABC', 'admin'),
  ('10000000-0000-0000-0000-000000000002', 'น้ำดื่ม 1.5L', 'in', 100, 'รับจากโรงงาน ABC', 'admin'),
  ('10000000-0000-0000-0000-000000000003', 'น้ำดื่ม 5L', 'in', 60, 'รับจากโรงงาน ABC', 'admin'),
  ('10000000-0000-0000-0000-000000000004', 'น้ำดื่ม 18.9L', 'in', 40, 'รับจากโรงงาน ABC', 'admin');

-- Orders + Items
DO $$
DECLARE
  o1 UUID := gen_random_uuid();
  o2 UUID := gen_random_uuid();
  o3 UUID := gen_random_uuid();
BEGIN
  INSERT INTO orders (id, order_number, customer_id, customer_name, status, total_amount,
    delivery_address, delivery_date, delivered_at) VALUES
    (o1, 'AQ-2024-001', '00000000-0000-0000-0000-000000000002', 'สมชาย ใจดี',
     'delivered', 3000, '123 ถ.สุขุมวิท กรุงเทพฯ',
     CURRENT_DATE - 1, NOW() - INTERVAL '20 hours'),
    (o2, 'AQ-2024-002', '00000000-0000-0000-0000-000000000003', 'มาลี รักดี',
     'delivering', 1500, '456 ถ.พระราม 9 กรุงเทพฯ',
     CURRENT_DATE, NULL),
    (o3, 'AQ-2024-003', '00000000-0000-0000-0000-000000000004', 'วันชัย ธุรกิจดี',
     'pending', 875, '789 ถ.รัชดาภิเษก กรุงเทพฯ',
     CURRENT_DATE + 1, NULL);

  INSERT INTO order_items (order_id, product_id, product_name, quantity, price_per_unit, subtotal) VALUES
    (o1, '10000000-0000-0000-0000-000000000001', 'น้ำดื่ม 600ml', 30, 60, 1800),
    (o1, '10000000-0000-0000-0000-000000000002', 'น้ำดื่ม 1.5L', 16, 75, 1200),
    (o2, '10000000-0000-0000-0000-000000000003', 'น้ำดื่ม 5L', 20, 25, 500),
    (o2, '10000000-0000-0000-0000-000000000004', 'น้ำดื่ม 18.9L', 20, 35, 700),
    (o2, '10000000-0000-0000-0000-000000000001', 'น้ำดื่ม 600ml', 5, 60, 300),
    (o3, '10000000-0000-0000-0000-000000000004', 'น้ำดื่ม 18.9L', 25, 35, 875);

  -- Out stock for delivered order
  INSERT INTO stock_transactions (product_id, product_name, type, quantity, note, created_by) VALUES
    ('10000000-0000-0000-0000-000000000001', 'น้ำดื่ม 600ml', 'out', 35,
     'ส่งให้ สมชาย (AQ-2024-001) + มาลี (AQ-2024-002)', 'admin'),
    ('10000000-0000-0000-0000-000000000002', 'น้ำดื่ม 1.5L', 'out', 16,
     'ส่งให้ สมชาย (AQ-2024-001)', 'admin'),
    ('10000000-0000-0000-0000-000000000003', 'น้ำดื่ม 5L', 'out', 20,
     'ส่งให้ มาลี (AQ-2024-002)', 'admin'),
    ('10000000-0000-0000-0000-000000000004', 'น้ำดื่ม 18.9L', 'out', 20,
     'ส่งให้ มาลี (AQ-2024-002)', 'admin');
END $$;

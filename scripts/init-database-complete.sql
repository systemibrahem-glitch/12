-- تهيئة قاعدة البيانات المبسطة لنظام إبراهيم للمحاسبة
-- هذا الملف يتحقق من وجود الجداول وينشئها إذا لم تكن موجودة

-- إنشاء جدول المتاجر إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS stores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  owner_name VARCHAR(255) NOT NULL,
  email VARCHAR(320) UNIQUE NOT NULL,
  phone VARCHAR(20),
  address TEXT,
  subscription_start_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  subscription_end_date TIMESTAMP WITH TIME ZONE NOT NULL,
  subscription_plan VARCHAR(20) NOT NULL CHECK (subscription_plan IN ('trial', 'monthly', '6months', 'yearly')),
  is_active BOOLEAN NOT NULL DEFAULT true,
  settings JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- إنشاء جدول المستخدمين إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(320),
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('owner', 'manager', 'accountant', 'data_entry', 'warehouse_keeper', 'employee')),
  permissions JSONB NOT NULL DEFAULT '{}',
  is_active BOOLEAN NOT NULL DEFAULT true,
  locale VARCHAR(10) NOT NULL DEFAULT 'ar-SA',
  theme VARCHAR(20) NOT NULL DEFAULT 'light',
  last_login TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES users(id)
);

-- إنشاء جدول العملات إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS currencies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  code VARCHAR(3) NOT NULL,
  name VARCHAR(100) NOT NULL,
  symbol VARCHAR(10) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(store_id, code)
);

-- إزالة القيود المعيقة
ALTER TABLE currencies DROP CONSTRAINT IF EXISTS currencies_code_check;

-- إنشاء جدول فئات الفواتير إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS invoice_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- إنشاء جدول فئات المخزون إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS inventory_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- إنشاء جدول وحدات القياس إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS units (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name VARCHAR(50) NOT NULL,
  abbreviation VARCHAR(10) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- إدراج المتجر الافتراضي
INSERT INTO stores (
  id,
  name,
  owner_name,
  email,
  phone,
  address,
  subscription_start_date,
  subscription_end_date,
  subscription_plan,
  is_active,
  settings,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  'متجر إبراهيم للمحاسبة',
  'إبراهيم أحمد',
  'ibrahim@example.com',
  '+966501234567',
  'الرياض، المملكة العربية السعودية',
  NOW(),
  NOW() + INTERVAL '1 year',
  'yearly',
  true,
  '{
    "locale": "ar-SA",
    "theme": "light",
    "default_currency": "SAR",
    "date_format": "DD/MM/YYYY",
    "time_format": "24h",
    "number_format": {
      "decimal_separator": ".",
      "thousands_separator": ",",
      "decimal_places": 2
    }
  }'::jsonb,
  NOW(),
  NOW()
) ON CONFLICT (email) DO NOTHING;

-- إدراج المستخدم المالك
INSERT INTO users (
  id,
  store_id,
  username,
  email,
  password_hash,
  full_name,
  role,
  permissions,
  is_active,
  locale,
  theme,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1),
  'ibrahim_owner',
  'ibrahim@example.com',
  '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj5J5K5K5K5K', -- كلمة السر: Ibrahim123!
  'إبراهيم أحمد',
  'owner',
  '{
    "users.create": true,
    "users.read": true,
    "users.update": true,
    "users.delete": true,
    "invoices.create": true,
    "invoices.read": true,
    "invoices.update": true,
    "invoices.delete": true,
    "inventory.create": true,
    "inventory.read": true,
    "inventory.update": true,
    "inventory.delete": true,
    "employees.create": true,
    "employees.read": true,
    "employees.update": true,
    "employees.delete": true,
    "payroll.create": true,
    "payroll.read": true,
    "payroll.update": true,
    "payroll.delete": true,
    "reports.read": true,
    "settings.update": true,
    "store.update": true,
    "partners.create": true,
    "partners.read": true,
    "partners.update": true,
    "partners.delete": true
  }'::jsonb,
  true,
  'ar-SA',
  'light',
  NOW(),
  NOW()
) ON CONFLICT (username) DO NOTHING;

-- إدراج العملات الافتراضية للمتجر
INSERT INTO currencies (store_id, code, name, symbol, is_active) VALUES
((SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'SAR', 'الريال السعودي', 'ر.س', true),
((SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'USD', 'الدولار الأمريكي', '$', true),
((SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'EUR', 'اليورو', '€', true),
((SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'AED', 'الدرهم الإماراتي', 'د.إ', true),
((SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'KWD', 'الدينار الكويتي', 'د.ك', true),
((SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'QAR', 'الريال القطري', 'ر.ق', true),
((SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'BHD', 'الدينار البحريني', 'د.ب', true),
((SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'OMR', 'الريال العماني', 'ر.ع', true),
((SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'JOD', 'الدينار الأردني', 'د.أ', true),
((SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'EGP', 'الجنيه المصري', 'ج.م', true)
ON CONFLICT (store_id, code) DO NOTHING;

-- إدراج فئات الفواتير الافتراضية
INSERT INTO invoice_categories (id, store_id, name, description, is_active, created_at, updated_at) VALUES
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'مشتريات', 'فواتير المشتريات والاستيراد', true, NOW(), NOW()),
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'مبيعات', 'فواتير المبيعات والتصدير', true, NOW(), NOW()),
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'خدمات', 'فواتير الخدمات المقدمة', true, NOW(), NOW()),
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'مصروفات', 'فواتير المصروفات التشغيلية', true, NOW(), NOW()),
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'إيرادات', 'فواتير الإيرادات الأخرى', true, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- إدراج فئات المخزون الافتراضية
INSERT INTO inventory_categories (id, store_id, name, description, is_active, created_at, updated_at) VALUES
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'إلكترونيات', 'الأجهزة الإلكترونية والحاسوبية', true, NOW(), NOW()),
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'ملابس', 'الملابس والأزياء', true, NOW(), NOW()),
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'أدوات منزلية', 'الأدوات والمعدات المنزلية', true, NOW(), NOW()),
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'كتب ومكتبة', 'الكتب والمواد التعليمية', true, NOW(), NOW()),
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'أخرى', 'فئة عامة للمنتجات الأخرى', true, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- إدراج وحدات القياس الافتراضية
INSERT INTO units (id, store_id, name, abbreviation, is_active, created_at, updated_at) VALUES
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'قطعة', 'قطعة', true, NOW(), NOW()),
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'كيلوغرام', 'كغ', true, NOW(), NOW()),
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'غرام', 'غ', true, NOW(), NOW()),
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'لتر', 'ل', true, NOW(), NOW()),
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'متر', 'م', true, NOW(), NOW()),
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'صندوق', 'صندوق', true, NOW(), NOW()),
(gen_random_uuid(), (SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'حزمة', 'حزمة', true, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- رسالة نجاح التهيئة
SELECT 'تم تهيئة قاعدة البيانات بنجاح!' as message;

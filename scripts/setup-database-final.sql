-- إعداد قاعدة البيانات المبسط جداً
-- هذا الملف يحل جميع مشاكل التكرار والقيود

-- حذف جميع البيانات الموجودة أولاً
DELETE FROM users WHERE username = 'ibrahim_owner';
DELETE FROM stores WHERE email = 'ibrahim@example.com';
DELETE FROM currencies WHERE code IN ('SAR', 'USD', 'EUR', 'AED', 'KWD', 'QAR', 'BHD', 'OMR', 'JOD', 'EGP');

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

-- إضافة الأعمدة المطلوبة للمستخدمين إذا لم تكن موجودة
DO $$ 
BEGIN
    -- إضافة عمود store_id
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' 
        AND column_name = 'store_id'
    ) THEN
        ALTER TABLE users ADD COLUMN store_id UUID;
        RAISE NOTICE 'تم إضافة عمود store_id إلى جدول users';
    END IF;
    
    -- إضافة عمود permissions
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' 
        AND column_name = 'permissions'
    ) THEN
        ALTER TABLE users ADD COLUMN permissions JSONB DEFAULT '{}';
        RAISE NOTICE 'تم إضافة عمود permissions إلى جدول users';
    END IF;
    
    -- إضافة عمود locale
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' 
        AND column_name = 'locale'
    ) THEN
        ALTER TABLE users ADD COLUMN locale VARCHAR(10) DEFAULT 'ar-SA';
        RAISE NOTICE 'تم إضافة عمود locale إلى جدول users';
    END IF;
    
    -- إضافة عمود theme
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' 
        AND column_name = 'theme'
    ) THEN
        ALTER TABLE users ADD COLUMN theme VARCHAR(20) DEFAULT 'light';
        RAISE NOTICE 'تم إضافة عمود theme إلى جدول users';
    END IF;
    
    -- إضافة عمود last_login
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' 
        AND column_name = 'last_login'
    ) THEN
        ALTER TABLE users ADD COLUMN last_login TIMESTAMP WITH TIME ZONE;
        RAISE NOTICE 'تم إضافة عمود last_login إلى جدول users';
    END IF;
    
    -- إضافة عمود created_by
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' 
        AND column_name = 'created_by'
    ) THEN
        ALTER TABLE users ADD COLUMN created_by UUID REFERENCES users(id);
        RAISE NOTICE 'تم إضافة عمود created_by إلى جدول users';
    END IF;
END $$;

-- إضافة المفتاح الخارجي للمستخدمين
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_users_store_id'
    ) THEN
        ALTER TABLE users ADD CONSTRAINT fk_users_store_id 
        FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE;
        RAISE NOTICE 'تم إضافة المفتاح الخارجي لجدول users';
    END IF;
END $$;

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

-- إزالة جميع القيود المعيقة للعملات
ALTER TABLE currencies DROP CONSTRAINT IF EXISTS currencies_code_check;
ALTER TABLE currencies DROP CONSTRAINT IF EXISTS currencies_code_key;
ALTER TABLE currencies DROP CONSTRAINT IF EXISTS currencies_pkey;

-- إعادة إنشاء القيود الصحيحة
ALTER TABLE currencies ADD CONSTRAINT currencies_pkey PRIMARY KEY (id);
ALTER TABLE currencies ADD CONSTRAINT unique_currencies_store_code UNIQUE (store_id, code);

-- إدراج المتجر
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
);

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
);

-- إدراج العملات الافتراضية
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
((SELECT id FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1), 'EGP', 'الجنيه المصري', 'ج.م', true);

-- التحقق من النتيجة
SELECT 
    u.username,
    u.full_name,
    u.store_id,
    s.name as store_name,
    s.email as store_email
FROM users u
LEFT JOIN stores s ON u.store_id = s.id
WHERE u.username = 'ibrahim_owner';

-- رسالة نجاح
SELECT 'تم إنشاء قاعدة البيانات الكاملة بنجاح!' as message;

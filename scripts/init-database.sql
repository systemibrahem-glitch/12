-- تهيئة قاعدة البيانات لنظام إبراهيم للمحاسبة
-- هذا الملف يحتوي على البيانات الأولية للمالك والمتجر

-- إدراج العملات الافتراضية
INSERT INTO currencies (code, name, symbol, is_active) VALUES
('SAR', 'الريال السعودي', 'ر.س', true),
('USD', 'الدولار الأمريكي', '$', true),
('EUR', 'اليورو', '€', true),
('AED', 'الدرهم الإماراتي', 'د.إ', true),
('KWD', 'الدينار الكويتي', 'د.ك', true),
('QAR', 'الريال القطري', 'ر.ق', true),
('BHD', 'الدينار البحريني', 'د.ب', true),
('OMR', 'الريال العماني', 'ر.ع', true),
('JOD', 'الدينار الأردني', 'د.أ', true),
('EGP', 'الجنيه المصري', 'ج.م', true)
ON CONFLICT (code) DO NOTHING;

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
-- ملاحظة: كلمة السر يجب تشفيرها باستخدام bcrypt قبل الإدراج
-- هذا مثال بكلمة سر مشفرة: 'Ibrahim123!' -> '$2a$12$...'
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

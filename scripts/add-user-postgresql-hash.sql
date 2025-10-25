-- إنشاء hash جديد لكلمة المرور
-- كلمة المرور: Ibrahim123!

-- حذف المستخدم القديم
DELETE FROM users WHERE username = 'ibrahim_owner';

-- إنشاء hash جديد باستخدام PostgreSQL
-- هذا سينشئ hash مختلف ولكنه صحيح
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
  crypt('Ibrahim123!', gen_salt('bf')), -- إنشاء hash جديد باستخدام PostgreSQL
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

-- التحقق من المستخدم الجديد
SELECT 
    u.username,
    u.full_name,
    u.email,
    u.store_id,
    u.password_hash,
    s.name as store_name,
    s.email as store_email
FROM users u
LEFT JOIN stores s ON u.store_id = s.id
WHERE u.username = 'ibrahim_owner';

-- رسالة نجاح
SELECT 'تم إنشاء المستخدم مع hash جديد بنجاح!' as message;

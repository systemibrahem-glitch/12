-- فحص البيانات الموجودة في قاعدة البيانات
-- هذا الملف يتحقق من المستخدمين والمتاجر الموجودة

-- فحص المستخدمين
SELECT 
    id,
    username,
    email,
    full_name,
    role,
    store_id,
    is_active,
    created_at
FROM users 
ORDER BY created_at DESC;

-- فحص المتاجر
SELECT 
    id,
    name,
    owner_name,
    email,
    is_active,
    created_at
FROM stores 
ORDER BY created_at DESC;

-- فحص العملات
SELECT 
    id,
    store_id,
    code,
    name,
    symbol,
    is_active
FROM currencies 
ORDER BY code;

-- فحص المستخدم المحدد
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

-- رسالة الفحص
SELECT 'تم فحص البيانات بنجاح!' as message;

-- إصلاح المستخدم الموجود وربطه بالمتجر
-- هذا الملف يربط المستخدم الموجود بالمتجر

-- أولاً، تأكد من وجود المتجر
DO $$ 
DECLARE
    store_uuid UUID;
    user_count INTEGER;
BEGIN
    -- البحث عن المتجر
    SELECT id INTO store_uuid FROM stores WHERE email = 'ibrahim@example.com' LIMIT 1;
    
    IF store_uuid IS NULL THEN
        RAISE EXCEPTION 'المتجر غير موجود. يجب تشغيل create-tables.sql أولاً';
    END IF;
    
    -- البحث عن المستخدم
    SELECT COUNT(*) INTO user_count FROM users WHERE username = 'ibrahim_owner';
    
    IF user_count = 0 THEN
        RAISE EXCEPTION 'المستخدم ibrahim_owner غير موجود';
    END IF;
    
    -- ربط المستخدم بالمتجر
    UPDATE users 
    SET 
        store_id = store_uuid,
        updated_at = NOW()
    WHERE username = 'ibrahim_owner';
    
    RAISE NOTICE 'تم ربط المستخدم ibrahim_owner بالمتجر بنجاح';
END $$;

-- التحقق من النتيجة
SELECT 
    u.username,
    u.full_name,
    u.store_id,
    s.name as store_name
FROM users u
LEFT JOIN stores s ON u.store_id = s.id
WHERE u.username = 'ibrahim_owner';

-- رسالة نجاح
SELECT 'تم ربط المستخدم بالمتجر بنجاح!' as message;

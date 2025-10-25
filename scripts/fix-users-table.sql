-- إصلاح جدول المستخدمين الموجود
-- هذا الملف يضيف عمود store_id إلى جدول users الموجود

-- إضافة عمود store_id إذا لم يكن موجوداً
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' 
        AND column_name = 'store_id'
    ) THEN
        ALTER TABLE users ADD COLUMN store_id UUID;
        RAISE NOTICE 'تم إضافة عمود store_id إلى جدول users';
    ELSE
        RAISE NOTICE 'عمود store_id موجود بالفعل في جدول users';
    END IF;
END $$;

-- إضافة المفتاح الخارجي إذا كان جدول stores موجود
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'stores') THEN
        -- إضافة المفتاح الخارجي إذا لم يكن موجوداً
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.table_constraints 
            WHERE constraint_name = 'fk_users_store_id'
        ) THEN
            ALTER TABLE users ADD CONSTRAINT fk_users_store_id 
            FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE;
            RAISE NOTICE 'تم إضافة المفتاح الخارجي لجدول users';
        ELSE
            RAISE NOTICE 'المفتاح الخارجي موجود بالفعل في جدول users';
        END IF;
    ELSE
        RAISE NOTICE 'جدول stores غير موجود - سيتم إضافة المفتاح الخارجي لاحقاً';
    END IF;
END $$;

-- رسالة نجاح الإصلاح
SELECT 'تم إصلاح جدول المستخدمين بنجاح!' as message;

-- إصلاح جدول المستخدمين الموجود
-- هذا الملف يضيف جميع الأعمدة المطلوبة إلى جدول users الموجود

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
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'stores') THEN
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

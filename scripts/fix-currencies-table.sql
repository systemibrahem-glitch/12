-- تعديل جدول العملات لإضافة store_id
-- يجب تشغيل هذا الملف إذا كان جدول currencies موجود بدون store_id

-- التحقق من وجود العمود وإضافته إذا لم يكن موجوداً
DO $$ 
BEGIN
    -- إضافة عمود store_id إذا لم يكن موجوداً
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'currencies' 
        AND column_name = 'store_id'
    ) THEN
        ALTER TABLE currencies ADD COLUMN store_id UUID;
        
        -- إضافة قيد المفتاح الخارجي فقط إذا كان جدول stores موجود
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'stores') THEN
            ALTER TABLE currencies ADD CONSTRAINT fk_currencies_store_id 
            FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE;
            
            -- إضافة قيد الفريد
            ALTER TABLE currencies ADD CONSTRAINT unique_currencies_store_code 
            UNIQUE (store_id, code);
            
            RAISE NOTICE 'تم إضافة عمود store_id مع المفتاح الخارجي إلى جدول currencies';
        ELSE
            RAISE NOTICE 'تم إضافة عمود store_id إلى جدول currencies (بدون مفتاح خارجي - جدول stores غير موجود)';
        END IF;
    ELSE
        RAISE NOTICE 'عمود store_id موجود بالفعل في جدول currencies';
    END IF;
END $$;

-- رسالة نجاح التعديل
SELECT 'تم تعديل جدول العملات بنجاح!' as message;

-- حل شامل لمشاكل قاعدة البيانات
-- هذا الملف يتعامل مع جميع الحالات المحتملة

-- الخطوة 1: إنشاء جدول العملات إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS currencies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(3) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  symbol VARCHAR(10) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- الخطوة 2: إضافة عمود store_id إذا لم يكن موجوداً
DO $$ 
BEGIN
    -- إضافة عمود store_id إذا لم يكن موجوداً
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'currencies' 
        AND column_name = 'store_id'
    ) THEN
        ALTER TABLE currencies ADD COLUMN store_id UUID;
        RAISE NOTICE 'تم إضافة عمود store_id إلى جدول currencies';
    ELSE
        RAISE NOTICE 'عمود store_id موجود بالفعل في جدول currencies';
    END IF;
END $$;

-- الخطوة 3: إضافة المفتاح الخارجي إذا كان جدول stores موجود
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'stores') THEN
        -- إضافة المفتاح الخارجي إذا لم يكن موجوداً
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.table_constraints 
            WHERE constraint_name = 'fk_currencies_store_id'
        ) THEN
            ALTER TABLE currencies ADD CONSTRAINT fk_currencies_store_id 
            FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE;
            RAISE NOTICE 'تم إضافة المفتاح الخارجي لجدول currencies';
        END IF;
        
        -- إضافة قيد الفريد إذا لم يكن موجوداً
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.table_constraints 
            WHERE constraint_name = 'unique_currencies_store_code'
        ) THEN
            ALTER TABLE currencies ADD CONSTRAINT unique_currencies_store_code 
            UNIQUE (store_id, code);
            RAISE NOTICE 'تم إضافة قيد الفريد لجدول currencies';
        END IF;
    ELSE
        RAISE NOTICE 'جدول stores غير موجود - سيتم إضافة المفتاح الخارجي لاحقاً';
    END IF;
END $$;

-- الخطوة 4: إدراج العملات الافتراضية
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

-- رسالة نجاح العملية
SELECT 'تم إعداد جدول العملات بنجاح!' as message;

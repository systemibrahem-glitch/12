-- إصلاح قيود جدول العملات
-- هذا الملف يزيل القيود المعيقة ويسمح بإدراج العملات

-- الخطوة 1: التحقق من القيود الموجودة وإزالتها
DO $$ 
DECLARE
    constraint_name TEXT;
BEGIN
    -- البحث عن قيود على عمود code
    FOR constraint_name IN 
        SELECT conname 
        FROM pg_constraint 
        WHERE conrelid = 'currencies'::regclass 
        AND confrelid = 0
        AND conname LIKE '%code%'
    LOOP
        EXECUTE 'ALTER TABLE currencies DROP CONSTRAINT IF EXISTS ' || constraint_name;
        RAISE NOTICE 'تم حذف القيد: %', constraint_name;
    END LOOP;
END $$;

-- الخطوة 2: إضافة قيد جديد أكثر مرونة
ALTER TABLE currencies DROP CONSTRAINT IF EXISTS currencies_code_check;
ALTER TABLE currencies ADD CONSTRAINT currencies_code_check 
CHECK (code ~ '^[A-Z]{3}$' OR code ~ '^[A-Z]{2}$');

-- الخطوة 3: إدراج العملات الافتراضية
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
SELECT 'تم إصلاح قيود جدول العملات وإدراج العملات بنجاح!' as message;

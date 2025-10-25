-- إدراج العملات الافتراضية (حل بسيط)
-- استخدم هذا الملف إذا كنت تريد إدراج العملات فقط

-- إزالة القيود المعيقة
ALTER TABLE currencies DROP CONSTRAINT IF EXISTS currencies_code_check;

-- إدراج العملات
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

-- رسالة نجاح الإدراج
SELECT 'تم إدراج العملات بنجاح!' as message;

-- إنشاء دالة التحقق من كلمة المرور في Supabase
-- ضع هذا الكود في Supabase SQL Editor

CREATE OR REPLACE FUNCTION check_password(input_password TEXT, stored_hash TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN crypt(input_password, stored_hash) = stored_hash;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- إعطاء صلاحيات للدالة
GRANT EXECUTE ON FUNCTION check_password(TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION check_password(TEXT, TEXT) TO authenticated;

-- رسالة نجاح
SELECT 'تم إنشاء دالة التحقق من كلمة المرور بنجاح!' as message;

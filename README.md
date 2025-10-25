# نظام إبراهيم للمحاسبة - Ibrahim Accounting System

نظام محاسبة احترافي متعدد المتاجر مع دعم كامل للغة العربية (RTL) وإدارة شاملة للفواتير والمخزون والموظفين.

![Logo](./client/public/logo.png)

## 🌟 المميزات الرئيسية

### نظام متاجر متعددة (Multi-tenant)
- كل متجر له بياناته المنفصلة تماماً
- عزل كامل للبيانات على مستوى قاعدة البيانات (Row Level Security)
- إدارة مستقلة لكل متجر

### إدارة الفواتير
- **الواردات**: تسجيل فواتير المشتريات والمصروفات
- **الصادرات**: تسجيل فواتير المبيعات والإيرادات
- دعم عملات متعددة (TRY, SYP, USD)
- تصنيف وأرشفة الفواتير
- ربط مع الموردين والعملاء

### إدارة المخزون
- تتبع المنتجات والكميات
- تنبيهات المخزون المنخفض
- حركات المخزون (إدخال، إخراج، تسوية)
- ربط مع الفواتير

### إدارة الموظفين
- سجل كامل للموظفين
- الرواتب والمستحقات
- السلف والخصومات
- المكافآت والحوافز

### نظام الصلاحيات
- أدوار متعددة (مالك، مدير، محاسب، مدخل بيانات، أمين مستودع)
- صلاحيات قابلة للتخصيص
- التحكم الكامل في الوصول

### التقارير والإحصائيات
- تقارير مالية شاملة
- إحصائيات تفاعلية
- تصدير البيانات

## 🛠️ التقنيات المستخدمة

### Frontend
- **React 19** - أحدث إصدار من React
- **TypeScript** - للكتابة الآمنة
- **Tailwind CSS 4** - تصميم عصري وسريع
- **Framer Motion** - حركات وتأثيرات سلسة
- **Wouter** - توجيه خفيف الوزن
- **shadcn/ui** - مكونات UI احترافية
- **Recharts** - رسوم بيانية تفاعلية

### Backend & Database
- **Supabase** - قاعدة بيانات PostgreSQL مع RLS
- **Row Level Security** - عزل كامل للبيانات
- **Real-time subscriptions** - تحديثات فورية

### Development
- **Vite** - أداة بناء سريعة
- **pnpm** - مدير حزم فعال
- **ESLint** - فحص الكود

## 📦 التثبيت والتشغيل

### المتطلبات
- Node.js 18+ 
- pnpm (أو npm/yarn)
- حساب Supabase

### 1. استنساخ المشروع

```bash
git clone https://github.com/yourusername/ibrahim-accounting.git
cd ibrahim-accounting
```

### 2. تثبيت المكتبات

```bash
pnpm install
```

### 3. إعداد قاعدة البيانات Supabase

#### أ. إنشاء مشروع جديد
1. اذهب إلى [Supabase](https://supabase.com)
2. أنشئ مشروع جديد
3. احفظ `Project URL` و `anon public key`

#### ب. تنفيذ SQL Schema
1. افتح SQL Editor في Supabase
2. نفذ محتوى ملف `database_schema.sql` الموجود في المجلد الرئيسي

#### ج. إنشاء مستخدم أولي
```sql
-- استبدل القيم بالبيانات الفعلية
INSERT INTO stores (name, owner_name, email, phone, subscription_plan, subscription_start_date, subscription_end_date, is_active)
VALUES (
  'متجر تجريبي',
  'أحمد محمد',
  'admin@example.com',
  '+963999999999',
  'trial',
  CURRENT_DATE,
  CURRENT_DATE + INTERVAL '30 days',
  true
) RETURNING id;

-- استخدم id المتجر من الاستعلام السابق
INSERT INTO users (store_id, username, password_hash, full_name, email, role, is_active)
VALUES (
  'STORE_ID_HERE', -- ضع id المتجر هنا
  'admin',
  '$2a$10$YourHashedPasswordHere', -- استخدم bcrypt لتشفير كلمة المرور
  'المدير',
  'admin@example.com',
  'owner',
  true
);
```

### 4. إعداد المتغيرات البيئية

أنشئ ملف `.env.local` في مجلد `client`:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
VITE_APP_TITLE=نظام إبراهيم للمحاسبة
VITE_APP_LOGO=/logo.png
```

### 5. تشغيل المشروع

```bash
pnpm dev
```

سيعمل التطبيق على `http://localhost:3000`

## 🚀 النشر على Netlify

### الطريقة الأولى: عبر GitHub

1. **رفع المشروع على GitHub**
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/ibrahim-accounting.git
git push -u origin main
```

2. **ربط مع Netlify**
   - اذهب إلى [Netlify](https://netlify.com)
   - اضغط "New site from Git"
   - اختر GitHub واختر المستودع
   - إعدادات البناء:
     ```
     Build command: pnpm build
     Publish directory: client/dist
     ```

3. **إضافة المتغيرات البيئية**
   - في إعدادات الموقع → Environment variables
   - أضف جميع المتغيرات من `.env.local`

### الطريقة الثانية: عبر Netlify CLI

```bash
# تثبيت Netlify CLI
npm install -g netlify-cli

# تسجيل الدخول
netlify login

# بناء المشروع
pnpm build

# النشر
netlify deploy --prod --dir=client/dist
```

## 📝 بيانات الدخول الافتراضية

بعد إنشاء المستخدم الأولي:
- **اسم المستخدم**: admin
- **كلمة المرور**: (التي قمت بتشفيرها)

## 🔒 الأمان

- جميع كلمات المرور مشفرة باستخدام bcrypt
- Row Level Security على جميع الجداول
- عزل كامل للبيانات بين المتاجر
- التحقق من الصلاحيات على مستوى التطبيق والقاعدة

## 🌐 دعم اللغات

- العربية (الافتراضية) مع دعم كامل لـ RTL
- يمكن إضافة لغات أخرى بسهولة

## 📱 التصميم المتجاوب

- يعمل على جميع الأجهزة (Desktop, Tablet, Mobile)
- تصميم حديث وسلس
- حركات تفاعلية

## 🤝 المساهمة

المساهمات مرحب بها! يرجى:
1. Fork المشروع
2. إنشاء فرع للميزة الجديدة
3. Commit التغييرات
4. Push للفرع
5. فتح Pull Request

## 📧 الدعم

- **البريد الإلكتروني**: systemibrahem@gmail.com
- **واتساب**: +963994054027

## 📄 الترخيص

هذا المشروع مرخص تحت MIT License

## 🎯 خارطة الطريق

- [ ] تطبيق الجوال (React Native)
- [ ] تكامل مع أنظمة الدفع
- [ ] تقارير متقدمة مع AI
- [ ] نظام الإشعارات الفورية
- [ ] API للتكامل مع أنظمة خارجية
- [ ] نسخ احتياطي تلقائي

---

صُنع بـ ❤️ في سوريا


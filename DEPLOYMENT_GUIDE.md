# دليل النشر الشامل - نظام إبراهيم للمحاسبة

## 📋 المحتويات

1. [متطلبات النشر](#متطلبات-النشر)
2. [إعداد قاعدة البيانات Supabase](#إعداد-قاعدة-البيانات-supabase)
3. [النشر على GitHub](#النشر-على-github)
4. [النشر على Netlify](#النشر-على-netlify)
5. [إنشاء المستخدم الأول](#إنشاء-المستخدم-الأول)
6. [استكشاف الأخطاء](#استكشاف-الأخطاء)

---

## متطلبات النشر

### الحسابات المطلوبة

- ✅ حساب [GitHub](https://github.com) (مجاني)
- ✅ حساب [Supabase](https://supabase.com) (مجاني)
- ✅ حساب [Netlify](https://netlify.com) (مجاني)

### الأدوات المطلوبة

- Node.js 18 أو أحدث
- Git
- محرر نصوص (VS Code موصى به)

---

## إعداد قاعدة البيانات Supabase

### الخطوة 1: إنشاء مشروع جديد

1. اذهب إلى [Supabase Dashboard](https://app.supabase.com)
2. اضغط على **"New Project"**
3. املأ البيانات:
   - **Name**: ibrahim-accounting
   - **Database Password**: اختر كلمة مرور قوية (احفظها!)
   - **Region**: اختر أقرب منطقة لك
4. اضغط **"Create new project"**
5. انتظر حتى يتم إنشاء المشروع (2-3 دقائق)

### الخطوة 2: الحصول على بيانات الاتصال

1. من لوحة التحكم، اذهب إلى **Settings** → **API**
2. احفظ هذه القيم:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: مفتاح طويل يبدأ بـ `eyJ...`

### الخطوة 3: تنفيذ SQL Schema

1. من القائمة الجانبية، اذهب إلى **SQL Editor**
2. اضغط **"New query"**
3. انسخ محتوى ملف `database_schema.sql` الموجود في المجلد الرئيسي للمشروع
4. الصق المحتوى في محرر SQL
5. اضغط **"Run"** أو اضغط `Ctrl+Enter`
6. يجب أن ترى رسالة "Success"

### الخطوة 4: التحقق من الجداول

1. اذهب إلى **Table Editor** من القائمة الجانبية
2. يجب أن ترى الجداول التالية:
   - stores
   - users
   - partners
   - invoices_in
   - invoices_out
   - inventory_items
   - inventory_movements
   - employees
   - employee_transactions
   - payroll
   - alerts

---

## النشر على GitHub

### الخطوة 1: إنشاء مستودع جديد

1. اذهب إلى [GitHub](https://github.com)
2. اضغط على **"+"** → **"New repository"**
3. املأ البيانات:
   - **Repository name**: ibrahim-accounting
   - **Description**: نظام إبراهيم للمحاسبة - نظام محاسبة احترافي متعدد المتاجر
   - **Visibility**: Public أو Private (حسب رغبتك)
4. **لا تضف** README أو .gitignore أو license
5. اضغط **"Create repository"**

### الخطوة 2: رفع المشروع

افتح Terminal/Command Prompt في مجلد المشروع ونفذ:

```bash
# تهيئة Git (إذا لم يكن مهيأ)
git init

# إضافة جميع الملفات
git add .

# إنشاء أول commit
git commit -m "Initial commit: نظام إبراهيم للمحاسبة"

# ربط المستودع البعيد (استبدل USERNAME باسم المستخدم الخاص بك)
git remote add origin https://github.com/USERNAME/ibrahim-accounting.git

# رفع الملفات
git branch -M main
git push -u origin main
```

### الخطوة 3: التحقق

- افتح صفحة المستودع على GitHub
- يجب أن ترى جميع ملفات المشروع

---

## النشر على Netlify

### الطريقة 1: النشر عبر واجهة Netlify (موصى بها)

#### الخطوة 1: ربط GitHub

1. اذهب إلى [Netlify](https://app.netlify.com)
2. سجل الدخول أو أنشئ حساب جديد
3. اضغط **"Add new site"** → **"Import an existing project"**
4. اختر **"Deploy with GitHub"**
5. امنح Netlify الصلاحيات للوصول إلى GitHub
6. اختر مستودع **ibrahim-accounting**

#### الخطوة 2: إعدادات البناء

في صفحة إعدادات النشر:

- **Branch to deploy**: main
- **Build command**: `cd client && pnpm install && pnpm build`
- **Publish directory**: `client/dist`

اضغط **"Deploy site"**

#### الخطوة 3: إضافة المتغيرات البيئية

1. بعد النشر، اذهب إلى **Site settings** → **Environment variables**
2. اضغط **"Add a variable"**
3. أضف المتغيرات التالية:

| Key | Value | ملاحظات |
|-----|-------|---------|
| `VITE_SUPABASE_URL` | `https://xxxxx.supabase.co` | من Supabase Dashboard |
| `VITE_SUPABASE_ANON_KEY` | `eyJ...` | من Supabase Dashboard |
| `VITE_APP_TITLE` | `نظام إبراهيم للمحاسبة` | اختياري |
| `VITE_APP_LOGO` | `/logo.png` | اختياري |

4. اضغط **"Save"**

#### الخطوة 4: إعادة النشر

1. اذهب إلى **Deploys**
2. اضغط **"Trigger deploy"** → **"Deploy site"**
3. انتظر حتى يكتمل النشر (2-3 دقائق)

#### الخطوة 5: الحصول على الرابط

- بعد اكتمال النشر، ستحصل على رابط مثل: `https://your-site-name.netlify.app`
- يمكنك تغيير اسم الموقع من **Site settings** → **Site details** → **Change site name**

### الطريقة 2: النشر عبر Netlify CLI

```bash
# تثبيت Netlify CLI
npm install -g netlify-cli

# تسجيل الدخول
netlify login

# الانتقال لمجلد المشروع
cd ibrahim-accounting

# بناء المشروع
cd client && pnpm install && pnpm build && cd ..

# النشر
netlify deploy --prod --dir=client/dist
```

---

## إنشاء المستخدم الأول

### الخطوة 1: إنشاء متجر

1. افتح **Supabase Dashboard** → **Table Editor**
2. اختر جدول **stores**
3. اضغط **"Insert row"**
4. املأ البيانات:

```
name: متجر تجريبي
owner_name: أحمد محمد
email: admin@example.com
phone: +963999999999
subscription_plan: trial
subscription_start_date: 2024-10-25
subscription_end_date: 2024-11-24
is_active: true
settings: {"locale": "ar", "theme": "light", "default_currency": "USD"}
```

5. اضغط **"Save"**
6. **احفظ** الـ `id` الذي تم إنشاؤه (ستحتاجه في الخطوة التالية)

### الخطوة 2: تشفير كلمة المرور

استخدم أداة bcrypt لتشفير كلمة المرور. يمكنك استخدام:

- [Bcrypt Generator Online](https://bcrypt-generator.com/)
- أو استخدم هذا الكود في Node.js:

```javascript
const bcrypt = require('bcryptjs');
const password = 'admin123'; // كلمة المرور التي تريدها
const hash = bcrypt.hashSync(password, 10);
console.log(hash);
```

### الخطوة 3: إنشاء المستخدم

1. في **Table Editor**، اختر جدول **users**
2. اضغط **"Insert row"**
3. املأ البيانات:

```
store_id: [ضع id المتجر من الخطوة 1]
username: admin
password_hash: [ضع الـ hash من الخطوة 2]
full_name: المدير
email: admin@example.com
role: owner
permissions: {}
is_active: true
locale: ar
theme: light
```

4. اضغط **"Save"**

### الخطوة 4: تسجيل الدخول

1. افتح موقعك على Netlify
2. ستظهر صفحة تسجيل الدخول
3. أدخل:
   - **اسم المستخدم**: admin
   - **كلمة المرور**: admin123 (أو ما اخترته)
4. اضغط **"تسجيل الدخول"**

---

## استكشاف الأخطاء

### المشكلة: "Missing Supabase environment variables"

**الحل:**
- تأكد من إضافة `VITE_SUPABASE_URL` و `VITE_SUPABASE_ANON_KEY` في متغيرات Netlify
- أعد نشر الموقع

### المشكلة: "Invalid login credentials"

**الحل:**
- تأكد من صحة اسم المستخدم وكلمة المرور
- تحقق من أن المستخدم موجود في جدول `users`
- تأكد من أن `is_active = true`
- تحقق من أن المتجر المرتبط `is_active = true`

### المشكلة: "Subscription expired"

**الحل:**
- افتح جدول `stores` في Supabase
- حدّث `subscription_end_date` لتاريخ مستقبلي
- تأكد من أن `is_active = true`

### المشكلة: صفحة فارغة بعد النشر

**الحل:**
- افتح Console في المتصفح (F12)
- ابحث عن أخطاء
- تأكد من أن جميع المتغيرات البيئية مضافة بشكل صحيح
- تحقق من أن Build نجح في Netlify

### المشكلة: "Failed to fetch" عند تحميل البيانات

**الحل:**
- تأكد من أن قاعدة البيانات Supabase تعمل
- تحقق من صحة `VITE_SUPABASE_URL` و `VITE_SUPABASE_ANON_KEY`
- تأكد من تنفيذ SQL Schema بشكل كامل

---

## 🎉 تهانينا!

نظام إبراهيم للمحاسبة الآن جاهز ويعمل!

### الخطوات التالية:

1. **إنشاء مستخدمين إضافيين** من قسم "المستخدمين"
2. **إضافة بيانات تجريبية** للتعرف على النظام
3. **تخصيص الإعدادات** من قسم "الإعدادات"
4. **ربط نطاق مخصص** من Netlify (اختياري)

### الدعم والمساعدة:

- **البريد الإلكتروني**: systemibrahem@gmail.com
- **واتساب**: +963994054027

---

**تم إنشاء هذا الدليل بواسطة Manus AI**


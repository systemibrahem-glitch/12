import { createClient } from '@supabase/supabase-js';
import bcrypt from 'bcryptjs';

// إعدادات Supabase
const supabaseUrl = process.env.VITE_SUPABASE_URL || 'https://imuequpezaixljuxljdn.supabase.co';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY; // تحتاج إلى إضافة هذا المفتاح

if (!supabaseServiceKey) {
  console.error('❌ SUPABASE_SERVICE_ROLE_KEY is required for database initialization');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

// بيانات المالك الافتراضية
const ownerData = {
  store: {
    name: 'متجر إبراهيم للمحاسبة',
    owner_name: 'إبراهيم أحمد',
    email: 'ibrahim@example.com',
    phone: '+966501234567',
    address: 'الرياض، المملكة العربية السعودية',
    subscription_start_date: new Date().toISOString(),
    subscription_end_date: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString(), // سنة من الآن
    subscription_plan: 'yearly' as const,
    is_active: true,
    settings: {
      locale: 'ar-SA',
      theme: 'light',
      default_currency: 'SAR'
    }
  },
  owner: {
    username: 'ibrahim_owner',
    email: 'ibrahim@example.com',
    password: 'Ibrahim123!', // كلمة سر قوية
    full_name: 'إبراهيم أحمد',
    role: 'owner' as const,
    permissions: {
      // صلاحيات المالك الكاملة
      'users.create': true,
      'users.read': true,
      'users.update': true,
      'users.delete': true,
      'invoices.create': true,
      'invoices.read': true,
      'invoices.update': true,
      'invoices.delete': true,
      'inventory.create': true,
      'inventory.read': true,
      'inventory.update': true,
      'inventory.delete': true,
      'employees.create': true,
      'employees.read': true,
      'employees.update': true,
      'employees.delete': true,
      'payroll.create': true,
      'payroll.read': true,
      'payroll.update': true,
      'payroll.delete': true,
      'reports.read': true,
      'settings.update': true,
      'store.update': true
    },
    is_active: true,
    locale: 'ar-SA',
    theme: 'light'
  }
};

async function initializeDatabase() {
  try {
    console.log('🚀 بدء تهيئة قاعدة البيانات...');

    // 1. إنشاء المتجر
    console.log('📦 إنشاء المتجر...');
    const { data: store, error: storeError } = await supabase
      .from('stores')
      .insert(ownerData.store)
      .select()
      .single();

    if (storeError) {
      console.error('❌ خطأ في إنشاء المتجر:', storeError);
      return;
    }

    console.log('✅ تم إنشاء المتجر بنجاح:', store.name);

    // 2. تشفير كلمة السر
    console.log('🔐 تشفير كلمة السر...');
    const saltRounds = 12;
    const passwordHash = await bcrypt.hash(ownerData.owner.password, saltRounds);

    // 3. إنشاء المستخدم المالك
    console.log('👤 إنشاء المستخدم المالك...');
    const { data: user, error: userError } = await supabase
      .from('users')
      .insert({
        store_id: store.id,
        username: ownerData.owner.username,
        email: ownerData.owner.email,
        password_hash: passwordHash,
        full_name: ownerData.owner.full_name,
        role: ownerData.owner.role,
        permissions: ownerData.owner.permissions,
        is_active: ownerData.owner.is_active,
        locale: ownerData.owner.locale,
        theme: ownerData.owner.theme
      })
      .select()
      .single();

    if (userError) {
      console.error('❌ خطأ في إنشاء المستخدم:', userError);
      return;
    }

    console.log('✅ تم إنشاء المستخدم المالك بنجاح:', user.username);

    // 4. إضافة العملات الافتراضية
    console.log('💰 إضافة العملات الافتراضية...');
    const currencies = [
      { store_id: store.id, code: 'SAR', name: 'الريال السعودي', symbol: 'ر.س', is_active: true },
      { store_id: store.id, code: 'USD', name: 'الدولار الأمريكي', symbol: '$', is_active: true },
      { store_id: store.id, code: 'EUR', name: 'اليورو', symbol: '€', is_active: true },
      { store_id: store.id, code: 'AED', name: 'الدرهم الإماراتي', symbol: 'د.إ', is_active: true }
    ];

    const { error: currencyError } = await supabase
      .from('currencies')
      .insert(currencies);

    if (currencyError) {
      console.error('❌ خطأ في إضافة العملات:', currencyError);
    } else {
      console.log('✅ تم إضافة العملات بنجاح');
    }

    console.log('\n🎉 تم تهيئة قاعدة البيانات بنجاح!');
    console.log('\n📋 بيانات تسجيل الدخول:');
    console.log(`👤 اسم المستخدم: ${ownerData.owner.username}`);
    console.log(`🔑 كلمة السر: ${ownerData.owner.password}`);
    console.log(`📧 البريد الإلكتروني: ${ownerData.owner.email}`);
    console.log(`🏪 اسم المتجر: ${store.name}`);

  } catch (error) {
    console.error('❌ خطأ عام في تهيئة قاعدة البيانات:', error);
  }
}

// تشغيل التهيئة
initializeDatabase();

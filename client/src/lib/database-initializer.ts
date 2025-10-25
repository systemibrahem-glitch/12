import { supabase } from '../client/src/lib/supabase';
import bcrypt from 'bcryptjs';

export interface OwnerData {
  store: {
    name: string;
    owner_name: string;
    email: string;
    phone?: string;
    address?: string;
    subscription_plan: 'trial' | 'monthly' | '6months' | 'yearly';
  };
  owner: {
    username: string;
    email: string;
    password: string;
    full_name: string;
  };
}

export class DatabaseInitializer {
  /**
   * إضافة مالك جديد للمتجر
   */
  static async addOwner(ownerData: OwnerData) {
    try {
      console.log('🚀 بدء إضافة المالك الجديد...');

      // 1. التحقق من عدم وجود المستخدم مسبقاً
      const { data: existingUser } = await supabase
        .from('users')
        .select('id')
        .eq('username', ownerData.owner.username)
        .single();

      if (existingUser) {
        throw new Error('المستخدم موجود مسبقاً');
      }

      // 2. التحقق من عدم وجود المتجر مسبقاً
      const { data: existingStore } = await supabase
        .from('stores')
        .select('id')
        .eq('email', ownerData.store.email)
        .single();

      if (existingStore) {
        throw new Error('المتجر موجود مسبقاً');
      }

      // 3. إنشاء المتجر
      console.log('📦 إنشاء المتجر...');
      const storeData = {
        name: ownerData.store.name,
        owner_name: ownerData.store.owner_name,
        email: ownerData.store.email,
        phone: ownerData.store.phone || null,
        address: ownerData.store.address || null,
        subscription_start_date: new Date().toISOString(),
        subscription_end_date: this.calculateSubscriptionEndDate(ownerData.store.subscription_plan),
        subscription_plan: ownerData.store.subscription_plan,
        is_active: true,
        settings: {
          locale: 'ar-SA',
          theme: 'light',
          default_currency: 'SAR',
          date_format: 'DD/MM/YYYY',
          time_format: '24h',
          number_format: {
            decimal_separator: '.',
            thousands_separator: ',',
            decimal_places: 2
          }
        }
      };

      const { data: store, error: storeError } = await supabase
        .from('stores')
        .insert(storeData)
        .select()
        .single();

      if (storeError) {
        throw new Error(`خطأ في إنشاء المتجر: ${storeError.message}`);
      }

      console.log('✅ تم إنشاء المتجر بنجاح:', store.name);

      // 4. تشفير كلمة السر
      console.log('🔐 تشفير كلمة السر...');
      const saltRounds = 12;
      const passwordHash = await bcrypt.hash(ownerData.owner.password, saltRounds);

      // 5. إنشاء المستخدم المالك
      console.log('👤 إنشاء المستخدم المالك...');
      const userData = {
        store_id: store.id,
        username: ownerData.owner.username,
        email: ownerData.owner.email,
        password_hash: passwordHash,
        full_name: ownerData.owner.full_name,
        role: 'owner' as const,
        permissions: this.getOwnerPermissions(),
        is_active: true,
        locale: 'ar-SA',
        theme: 'light'
      };

      const { data: user, error: userError } = await supabase
        .from('users')
        .insert(userData)
        .select()
        .single();

      if (userError) {
        // في حالة فشل إنشاء المستخدم، احذف المتجر
        await supabase.from('stores').delete().eq('id', store.id);
        throw new Error(`خطأ في إنشاء المستخدم: ${userError.message}`);
      }

      console.log('✅ تم إنشاء المستخدم المالك بنجاح:', user.username);

      // 6. إضافة البيانات الافتراضية
      await this.addDefaultData(store.id);

      return {
        success: true,
        store,
        user,
        loginCredentials: {
          username: ownerData.owner.username,
          password: ownerData.owner.password,
          email: ownerData.owner.email
        }
      };

    } catch (error) {
      console.error('❌ خطأ في إضافة المالك:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'خطأ غير معروف'
      };
    }
  }

  /**
   * حساب تاريخ انتهاء الاشتراك
   */
  private static calculateSubscriptionEndDate(plan: string): string {
    const now = new Date();
    let endDate: Date;

    switch (plan) {
      case 'trial':
        endDate = new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000); // 14 يوم
        break;
      case 'monthly':
        endDate = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000); // 30 يوم
        break;
      case '6months':
        endDate = new Date(now.getTime() + 180 * 24 * 60 * 60 * 1000); // 6 أشهر
        break;
      case 'yearly':
        endDate = new Date(now.getTime() + 365 * 24 * 60 * 60 * 1000); // سنة
        break;
      default:
        endDate = new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000); // افتراضي: 14 يوم
    }

    return endDate.toISOString();
  }

  /**
   * الحصول على صلاحيات المالك الكاملة
   */
  private static getOwnerPermissions(): Record<string, boolean> {
    return {
      // إدارة المستخدمين
      'users.create': true,
      'users.read': true,
      'users.update': true,
      'users.delete': true,
      
      // إدارة الفواتير
      'invoices.create': true,
      'invoices.read': true,
      'invoices.update': true,
      'invoices.delete': true,
      
      // إدارة المخزون
      'inventory.create': true,
      'inventory.read': true,
      'inventory.update': true,
      'inventory.delete': true,
      
      // إدارة الموظفين
      'employees.create': true,
      'employees.read': true,
      'employees.update': true,
      'employees.delete': true,
      
      // إدارة الرواتب
      'payroll.create': true,
      'payroll.read': true,
      'payroll.update': true,
      'payroll.delete': true,
      
      // إدارة الشركاء
      'partners.create': true,
      'partners.read': true,
      'partners.update': true,
      'partners.delete': true,
      
      // التقارير والإعدادات
      'reports.read': true,
      'settings.update': true,
      'store.update': true,
      
      // صلاحيات إضافية
      'backup.create': true,
      'backup.restore': true,
      'analytics.read': true,
      'notifications.send': true
    };
  }

  /**
   * إضافة البيانات الافتراضية للمتجر
   */
  private static async addDefaultData(storeId: string) {
    try {
      console.log('📊 إضافة البيانات الافتراضية...');

      // إضافة العملات
      const currencies = [
        { store_id: storeId, code: 'SAR', name: 'الريال السعودي', symbol: 'ر.س', is_active: true },
        { store_id: storeId, code: 'USD', name: 'الدولار الأمريكي', symbol: '$', is_active: true },
        { store_id: storeId, code: 'EUR', name: 'اليورو', symbol: '€', is_active: true },
        { store_id: storeId, code: 'AED', name: 'الدرهم الإماراتي', symbol: 'د.إ', is_active: true }
      ];

      await supabase.from('currencies').insert(currencies);

      // إضافة فئات الفواتير
      const invoiceCategories = [
        { name: 'مشتريات', description: 'فواتير المشتريات والاستيراد' },
        { name: 'مبيعات', description: 'فواتير المبيعات والتصدير' },
        { name: 'خدمات', description: 'فواتير الخدمات المقدمة' },
        { name: 'مصروفات', description: 'فواتير المصروفات التشغيلية' },
        { name: 'إيرادات', description: 'فواتير الإيرادات الأخرى' }
      ];

      const categoryData = invoiceCategories.map(cat => ({
        store_id: storeId,
        name: cat.name,
        description: cat.description,
        is_active: true
      }));

      await supabase.from('invoice_categories').insert(categoryData);

      // إضافة فئات المخزون
      const inventoryCategories = [
        { name: 'إلكترونيات', description: 'الأجهزة الإلكترونية والحاسوبية' },
        { name: 'ملابس', description: 'الملابس والأزياء' },
        { name: 'أدوات منزلية', description: 'الأدوات والمعدات المنزلية' },
        { name: 'كتب ومكتبة', description: 'الكتب والمواد التعليمية' },
        { name: 'أخرى', description: 'فئة عامة للمنتجات الأخرى' }
      ];

      const inventoryData = inventoryCategories.map(cat => ({
        store_id: storeId,
        name: cat.name,
        description: cat.description,
        is_active: true
      }));

      await supabase.from('inventory_categories').insert(inventoryData);

      // إضافة وحدات القياس
      const units = [
        { name: 'قطعة', abbreviation: 'قطعة' },
        { name: 'كيلوغرام', abbreviation: 'كغ' },
        { name: 'غرام', abbreviation: 'غ' },
        { name: 'لتر', abbreviation: 'ل' },
        { name: 'متر', abbreviation: 'م' },
        { name: 'صندوق', abbreviation: 'صندوق' },
        { name: 'حزمة', abbreviation: 'حزمة' }
      ];

      const unitData = units.map(unit => ({
        store_id: storeId,
        name: unit.name,
        abbreviation: unit.abbreviation,
        is_active: true
      }));

      await supabase.from('units').insert(unitData);

      console.log('✅ تم إضافة البيانات الافتراضية بنجاح');

    } catch (error) {
      console.error('❌ خطأ في إضافة البيانات الافتراضية:', error);
    }
  }

  /**
   * التحقق من وجود مالك في المتجر
   */
  static async checkOwnerExists(storeId: string): Promise<boolean> {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('id')
        .eq('store_id', storeId)
        .eq('role', 'owner')
        .single();

      return !error && !!data;
    } catch {
      return false;
    }
  }
}

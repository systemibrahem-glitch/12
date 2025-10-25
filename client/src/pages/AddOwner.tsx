import { useState } from 'react';
import { DatabaseInitializer, OwnerData } from '../lib/database-initializer';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Label } from '../components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/card';
import { Alert, AlertDescription } from '../components/ui/alert';
import { Loader2, CheckCircle, XCircle } from 'lucide-react';

export default function AddOwnerPage() {
  const [formData, setFormData] = useState<OwnerData>({
    store: {
      name: 'متجر إبراهيم للمحاسبة',
      owner_name: 'إبراهيم أحمد',
      email: 'ibrahim@example.com',
      phone: '+966501234567',
      address: 'الرياض، المملكة العربية السعودية',
      subscription_plan: 'yearly'
    },
    owner: {
      username: 'ibrahim_owner',
      email: 'ibrahim@example.com',
      password: 'Ibrahim123!',
      full_name: 'إبراهيم أحمد'
    }
  });

  const [isLoading, setIsLoading] = useState(false);
  const [result, setResult] = useState<{
    success: boolean;
    message: string;
    credentials?: {
      username: string;
      password: string;
      email: string;
    };
  } | null>(null);

  const handleInputChange = (section: 'store' | 'owner', field: string, value: string) => {
    setFormData(prev => ({
      ...prev,
      [section]: {
        ...prev[section],
        [field]: value
      }
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setResult(null);

    try {
      const response = await DatabaseInitializer.addOwner(formData);
      
      if (response.success) {
        setResult({
          success: true,
          message: 'تم إنشاء المالك والمتجر بنجاح!',
          credentials: response.loginCredentials
        });
      } else {
        setResult({
          success: false,
          message: response.error || 'حدث خطأ غير متوقع'
        });
      }
    } catch (error) {
      setResult({
        success: false,
        message: error instanceof Error ? error.message : 'حدث خطأ غير متوقع'
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-4xl mx-auto px-4">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            إضافة مالك جديد للمتجر
          </h1>
          <p className="text-gray-600">
            قم بملء البيانات التالية لإنشاء متجر جديد ومستخدم مالك
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* بيانات المتجر */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <span className="text-blue-600">📦</span>
                بيانات المتجر
              </CardTitle>
              <CardDescription>
                المعلومات الأساسية للمتجر الجديد
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="store-name">اسم المتجر</Label>
                <Input
                  id="store-name"
                  value={formData.store.name}
                  onChange={(e) => handleInputChange('store', 'name', e.target.value)}
                  placeholder="مثال: متجر إبراهيم للمحاسبة"
                />
              </div>

              <div>
                <Label htmlFor="owner-name">اسم المالك</Label>
                <Input
                  id="owner-name"
                  value={formData.store.owner_name}
                  onChange={(e) => handleInputChange('store', 'owner_name', e.target.value)}
                  placeholder="مثال: إبراهيم أحمد"
                />
              </div>

              <div>
                <Label htmlFor="store-email">البريد الإلكتروني</Label>
                <Input
                  id="store-email"
                  type="email"
                  value={formData.store.email}
                  onChange={(e) => handleInputChange('store', 'email', e.target.value)}
                  placeholder="example@domain.com"
                />
              </div>

              <div>
                <Label htmlFor="store-phone">رقم الهاتف</Label>
                <Input
                  id="store-phone"
                  value={formData.store.phone}
                  onChange={(e) => handleInputChange('store', 'phone', e.target.value)}
                  placeholder="+966501234567"
                />
              </div>

              <div>
                <Label htmlFor="store-address">العنوان</Label>
                <Input
                  id="store-address"
                  value={formData.store.address}
                  onChange={(e) => handleInputChange('store', 'address', e.target.value)}
                  placeholder="الرياض، المملكة العربية السعودية"
                />
              </div>

              <div>
                <Label htmlFor="subscription-plan">خطة الاشتراك</Label>
                <select
                  id="subscription-plan"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={formData.store.subscription_plan}
                  onChange={(e) => handleInputChange('store', 'subscription_plan', e.target.value)}
                >
                  <option value="trial">تجريبي (14 يوم)</option>
                  <option value="monthly">شهري</option>
                  <option value="6months">6 أشهر</option>
                  <option value="yearly">سنوي</option>
                </select>
              </div>
            </CardContent>
          </Card>

          {/* بيانات المستخدم */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <span className="text-green-600">👤</span>
                بيانات المستخدم المالك
              </CardTitle>
              <CardDescription>
                معلومات تسجيل الدخول للمالك
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="username">اسم المستخدم</Label>
                <Input
                  id="username"
                  value={formData.owner.username}
                  onChange={(e) => handleInputChange('owner', 'username', e.target.value)}
                  placeholder="ibrahim_owner"
                />
              </div>

              <div>
                <Label htmlFor="user-email">البريد الإلكتروني</Label>
                <Input
                  id="user-email"
                  type="email"
                  value={formData.owner.email}
                  onChange={(e) => handleInputChange('owner', 'email', e.target.value)}
                  placeholder="example@domain.com"
                />
              </div>

              <div>
                <Label htmlFor="full-name">الاسم الكامل</Label>
                <Input
                  id="full-name"
                  value={formData.owner.full_name}
                  onChange={(e) => handleInputChange('owner', 'full_name', e.target.value)}
                  placeholder="إبراهيم أحمد"
                />
              </div>

              <div>
                <Label htmlFor="password">كلمة السر</Label>
                <Input
                  id="password"
                  type="password"
                  value={formData.owner.password}
                  onChange={(e) => handleInputChange('owner', 'password', e.target.value)}
                  placeholder="كلمة سر قوية"
                />
                <p className="text-sm text-gray-500 mt-1">
                  يجب أن تحتوي على 8 أحرف على الأقل مع أرقام ورموز
                </p>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* زر الإرسال */}
        <div className="mt-8 text-center">
          <Button
            onClick={handleSubmit}
            disabled={isLoading}
            size="lg"
            className="px-8"
          >
            {isLoading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                جاري الإنشاء...
              </>
            ) : (
              'إنشاء المالك والمتجر'
            )}
          </Button>
        </div>

        {/* عرض النتيجة */}
        {result && (
          <div className="mt-8">
            <Alert className={result.success ? 'border-green-200 bg-green-50' : 'border-red-200 bg-red-50'}>
              <div className="flex items-center gap-2">
                {result.success ? (
                  <CheckCircle className="h-4 w-4 text-green-600" />
                ) : (
                  <XCircle className="h-4 w-4 text-red-600" />
                )}
                <AlertDescription className={result.success ? 'text-green-800' : 'text-red-800'}>
                  {result.message}
                </AlertDescription>
              </div>
            </Alert>

            {result.success && result.credentials && (
              <Card className="mt-4 border-green-200 bg-green-50">
                <CardHeader>
                  <CardTitle className="text-green-800">بيانات تسجيل الدخول</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2 text-sm">
                    <p><strong>اسم المستخدم:</strong> {result.credentials.username}</p>
                    <p><strong>كلمة السر:</strong> {result.credentials.password}</p>
                    <p><strong>البريد الإلكتروني:</strong> {result.credentials.email}</p>
                  </div>
                  <Alert className="mt-4 border-yellow-200 bg-yellow-50">
                    <AlertDescription className="text-yellow-800">
                      ⚠️ احفظ هذه البيانات في مكان آمن، لن تتمكن من رؤية كلمة السر مرة أخرى
                    </AlertDescription>
                  </Alert>
                </CardContent>
              </Card>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

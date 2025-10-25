import { useEffect, useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/lib/supabase';
import type { InventoryItem } from '@/lib/supabase';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { formatCurrency, CURRENCIES } from '@/const';
import { Plus, Search, Edit, Package, AlertTriangle } from 'lucide-react';
import { motion } from 'framer-motion';
import { toast } from 'sonner';

export default function Inventory() {
  const { user, store } = useAuth();
  const [items, setItems] = useState<InventoryItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [editingItem, setEditingItem] = useState<InventoryItem | null>(null);

  const [formData, setFormData] = useState({
    sku: '',
    name: '',
    description: '',
    unit: 'قطعة',
    min_stock: '0',
    current_stock: '0',
    price: '',
    currency: 'USD',
    category: '',
    notes: '',
  });

  useEffect(() => {
    loadData();
  }, [store]);

  async function loadData() {
    if (!store) return;

    try {
      const { data, error } = await supabase
        .from('inventory_items')
        .select('*')
        .eq('store_id', store.id)
        .eq('is_active', true)
        .order('name');

      if (error) throw error;
      if (data) setItems(data);
    } catch (error) {
      console.error('Error loading inventory:', error);
      toast.error('حدث خطأ في تحميل المخزون');
    } finally {
      setLoading(false);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!store || !user) return;

    try {
      const itemData = {
        ...formData,
        store_id: store.id,
        min_stock: parseFloat(formData.min_stock),
        current_stock: parseFloat(formData.current_stock),
        price: formData.price ? parseFloat(formData.price) : null,
        created_by: user.id,
      };

      if (editingItem) {
        const { error } = await supabase
          .from('inventory_items')
          .update(itemData)
          .eq('id', editingItem.id);

        if (error) throw error;
        toast.success('تم تحديث المنتج بنجاح');
      } else {
        const { error } = await supabase
          .from('inventory_items')
          .insert([itemData]);

        if (error) throw error;
        toast.success('تم إضافة المنتج بنجاح');
      }

      setDialogOpen(false);
      resetForm();
      loadData();
    } catch (error) {
      console.error('Error saving item:', error);
      toast.error('حدث خطأ في حفظ المنتج');
    }
  }

  function resetForm() {
    setFormData({
      sku: '',
      name: '',
      description: '',
      unit: 'قطعة',
      min_stock: '0',
      current_stock: '0',
      price: '',
      currency: 'USD',
      category: '',
      notes: '',
    });
    setEditingItem(null);
  }

  function openEditDialog(item: InventoryItem) {
    setEditingItem(item);
    setFormData({
      sku: item.sku || '',
      name: item.name,
      description: item.description || '',
      unit: item.unit,
      min_stock: item.min_stock.toString(),
      current_stock: item.current_stock.toString(),
      price: item.price?.toString() || '',
      currency: item.currency || 'USD',
      category: item.category || '',
      notes: item.notes || '',
    });
    setDialogOpen(true);
  }

  function getStockStatus(item: InventoryItem) {
    if (item.current_stock <= 0) return { label: 'نفذ', color: 'text-red-600 bg-red-50 dark:bg-red-900/20' };
    if (item.current_stock <= item.min_stock) return { label: 'منخفض', color: 'text-amber-600 bg-amber-50 dark:bg-amber-900/20' };
    return { label: 'متوفر', color: 'text-green-600 bg-green-50 dark:bg-green-900/20' };
  }

  const filteredItems = items.filter((item) => {
    const matchesSearch = item.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.sku?.toLowerCase().includes(searchTerm.toLowerCase());
    
    if (filterStatus === 'all') return matchesSearch;
    if (filterStatus === 'out') return matchesSearch && item.current_stock <= 0;
    if (filterStatus === 'low') return matchesSearch && item.current_stock > 0 && item.current_stock <= item.min_stock;
    if (filterStatus === 'available') return matchesSearch && item.current_stock > item.min_stock;
    return matchesSearch;
  });

  const stats = {
    total: items.length,
    outOfStock: items.filter(i => i.current_stock <= 0).length,
    lowStock: items.filter(i => i.current_stock > 0 && i.current_stock <= i.min_stock).length,
  };

  if (loading) {
    return <div className="flex justify-center items-center h-64">
      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600" />
    </div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-slate-900 dark:text-white">المستودع</h1>
          <p className="text-slate-600 dark:text-slate-400">إدارة المخزون والمنتجات</p>
        </div>
        <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
          <DialogTrigger asChild>
            <Button onClick={resetForm}>
              <Plus className="ml-2 h-5 w-5" />
              إضافة منتج
            </Button>
          </DialogTrigger>
          <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>{editingItem ? 'تعديل منتج' : 'إضافة منتج جديد'}</DialogTitle>
            </DialogHeader>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>كود المنتج</Label>
                  <Input
                    value={formData.sku}
                    onChange={(e) => setFormData({ ...formData, sku: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label>اسم المنتج *</Label>
                  <Input
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    required
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label>الوصف</Label>
                <Input
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                />
              </div>

              <div className="grid grid-cols-3 gap-4">
                <div className="space-y-2">
                  <Label>الوحدة *</Label>
                  <Input
                    value={formData.unit}
                    onChange={(e) => setFormData({ ...formData, unit: e.target.value })}
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label>الحد الأدنى</Label>
                  <Input
                    type="number"
                    step="0.01"
                    value={formData.min_stock}
                    onChange={(e) => setFormData({ ...formData, min_stock: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label>الكمية الحالية</Label>
                  <Input
                    type="number"
                    step="0.01"
                    value={formData.current_stock}
                    onChange={(e) => setFormData({ ...formData, current_stock: e.target.value })}
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>السعر</Label>
                  <Input
                    type="number"
                    step="0.01"
                    value={formData.price}
                    onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label>العملة</Label>
                  <Select value={formData.currency} onValueChange={(value) => setFormData({ ...formData, currency: value })}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {CURRENCIES.map((curr) => (
                        <SelectItem key={curr.code} value={curr.code}>
                          {curr.symbol} - {curr.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div className="space-y-2">
                <Label>التصنيف</Label>
                <Input
                  value={formData.category}
                  onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                />
              </div>

              <div className="space-y-2">
                <Label>ملاحظات</Label>
                <Input
                  value={formData.notes}
                  onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                />
              </div>

              <div className="flex gap-2 justify-end">
                <Button type="button" variant="outline" onClick={() => setDialogOpen(false)}>
                  إلغاء
                </Button>
                <Button type="submit">
                  {editingItem ? 'تحديث' : 'إضافة'}
                </Button>
              </div>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card className="p-4">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
              <Package className="w-6 h-6 text-blue-600" />
            </div>
            <div>
              <p className="text-sm text-slate-600 dark:text-slate-400">إجمالي المنتجات</p>
              <p className="text-2xl font-bold text-slate-900 dark:text-white">{stats.total}</p>
            </div>
          </div>
        </Card>
        <Card className="p-4">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-amber-50 dark:bg-amber-900/20 rounded-lg">
              <AlertTriangle className="w-6 h-6 text-amber-600" />
            </div>
            <div>
              <p className="text-sm text-slate-600 dark:text-slate-400">مخزون منخفض</p>
              <p className="text-2xl font-bold text-amber-600">{stats.lowStock}</p>
            </div>
          </div>
        </Card>
        <Card className="p-4">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-red-50 dark:bg-red-900/20 rounded-lg">
              <AlertTriangle className="w-6 h-6 text-red-600" />
            </div>
            <div>
              <p className="text-sm text-slate-600 dark:text-slate-400">نفذ من المخزون</p>
              <p className="text-2xl font-bold text-red-600">{stats.outOfStock}</p>
            </div>
          </div>
        </Card>
      </div>

      <Card className="p-6">
        <div className="flex gap-4 mb-6">
          <div className="flex-1 relative">
            <Search className="absolute right-3 top-1/2 transform -translate-y-1/2 text-slate-400 w-5 h-5" />
            <Input
              placeholder="بحث في المنتجات..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pr-10"
            />
          </div>
          <Select value={filterStatus} onValueChange={setFilterStatus}>
            <SelectTrigger className="w-48">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">جميع المنتجات</SelectItem>
              <SelectItem value="available">متوفر</SelectItem>
              <SelectItem value="low">مخزون منخفض</SelectItem>
              <SelectItem value="out">نفذ من المخزون</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-3">
          {filteredItems.map((item, index) => {
            const status = getStockStatus(item);
            return (
              <motion.div
                key={item.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.05 }}
                className="flex items-center gap-4 p-4 bg-slate-50 dark:bg-slate-800 rounded-lg hover:shadow-md transition-shadow"
              >
                <div className="w-12 h-12 rounded-lg bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center">
                  <Package className="w-6 h-6 text-blue-600" />
                </div>
                <div className="flex-1">
                  <div className="flex items-start justify-between">
                    <div>
                      <h3 className="font-semibold text-slate-900 dark:text-white">{item.name}</h3>
                      <div className="flex gap-3 mt-1 text-sm text-slate-600 dark:text-slate-400">
                        {item.sku && <span>#{item.sku}</span>}
                        <span>{item.unit}</span>
                        {item.category && <span className="px-2 py-0.5 bg-slate-200 dark:bg-slate-700 rounded">{item.category}</span>}
                      </div>
                    </div>
                    <div className="text-left">
                      <div className={`px-3 py-1 rounded-lg text-sm font-medium ${status.color}`}>
                        {status.label}
                      </div>
                      <p className="text-sm text-slate-600 dark:text-slate-400 mt-1">
                        {item.current_stock} / {item.min_stock}
                      </p>
                      {item.price && (
                        <p className="text-sm font-semibold text-slate-900 dark:text-white mt-1">
                          {formatCurrency(item.price, item.currency || 'USD')}
                        </p>
                      )}
                    </div>
                  </div>
                </div>
                <Button size="sm" variant="ghost" onClick={() => openEditDialog(item)}>
                  <Edit className="w-4 h-4" />
                </Button>
              </motion.div>
            );
          })}
          {filteredItems.length === 0 && (
            <div className="text-center py-12 text-slate-500 dark:text-slate-400">
              لا توجد منتجات
            </div>
          )}
        </div>
      </Card>
    </div>
  );
}


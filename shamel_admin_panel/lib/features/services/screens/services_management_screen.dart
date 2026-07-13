import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/services_provider.dart';

class ServicesManagementScreen extends ConsumerWidget {
  const ServicesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إدارة الخدمات',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddServiceDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('إضافة خدمة جديدة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Filters and Search
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'ابحث عن خدمة...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    value: 'الكل',
                    items: ['الكل', 'نشط', 'غير نشط'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) {},
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text('فلاتر متقدمة'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Services Table
          servicesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('خطأ في جلب البيانات: $err')),
            data: (services) {
              if (services.isEmpty) {
                return const Center(child: Text('لا توجد خدمات مضافة حتى الآن'));
              }
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.surfaceContainerLow),
                  dataRowMinHeight: 70,
                  dataRowMaxHeight: 70,
                  columns: const [
                    DataColumn(label: Text('معرف الخدمة', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('اسم الخدمة', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('التصنيف', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('السعر الأساسي', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: services.map((service) {
                    return DataRow(
                      cells: [
                        DataCell(Text('#${service.id.substring(0, 8).toUpperCase()}')),
                        DataCell(Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.home_repair_service, color: AppColors.onPrimaryContainer, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(service.category, style: const TextStyle(color: AppColors.onSecondaryContainer, fontSize: 12)),
                        )),
                        DataCell(Text('SAR ${service.basePrice}')),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: !service.isActive ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            !service.isActive ? 'غير نشط' : 'نشط',
                            style: TextStyle(
                              color: !service.isActive ? Colors.red : Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.primary), 
                              onPressed: () => _showEditServiceDialog(context, ref, service),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red), 
                              onPressed: () => _deleteService(context, ref, service.id),
                            ),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final catController = TextEditingController(text: 'نظافة');
    final priceController = TextEditingController(text: '100');
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة خدمة جديدة'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الخدمة'),
                validator: (val) => val!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: catController.text,
                decoration: const InputDecoration(labelText: 'التصنيف'),
                items: ['نظافة', 'صيانة', 'كهرباء', 'خارجية']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => catController.text = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'السعر الأساسي'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'مطلوب' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await Supabase.instance.client.from('services').insert({
                  'name': nameController.text,
                  'category': catController.text,
                  'base_price': double.parse(priceController.text),
                  'is_active': true,
                });
                ref.invalidate(servicesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(BuildContext context, WidgetRef ref, ServiceModel service) {
    final nameController = TextEditingController(text: service.name);
    final catController = TextEditingController(text: service.category);
    final priceController = TextEditingController(text: service.basePrice.toString());
    bool isActive = service.isActive;
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تعديل الخدمة'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم الخدمة'),
                  validator: (val) => val!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: ['نظافة', 'صيانة', 'كهرباء', 'خارجية'].contains(catController.text) ? catController.text : 'نظافة',
                  decoration: const InputDecoration(labelText: 'التصنيف'),
                  items: ['نظافة', 'صيانة', 'كهرباء', 'خارجية']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => catController.text = val!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'السعر الأساسي'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('الخدمة نشطة؟'),
                  value: isActive,
                  onChanged: (val) => setState(() => isActive = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await Supabase.instance.client.from('services').update({
                    'name': nameController.text,
                    'category': catController.text,
                    'base_price': double.parse(priceController.text),
                    'is_active': isActive,
                  }).eq('id', service.id);
                  ref.invalidate(servicesProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteService(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف خدمة'),
        content: const Text('هل أنت متأكد من حذف هذه الخدمة نهائياً؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              await Supabase.instance.client.from('services').delete().eq('id', id);
              ref.invalidate(servicesProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

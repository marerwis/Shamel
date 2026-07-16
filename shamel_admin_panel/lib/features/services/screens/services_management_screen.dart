import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/services_provider.dart';
import '../../categories/providers/categories_provider.dart';

class ServicesManagementScreen extends ConsumerWidget {
  const ServicesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_service',
        onPressed: () => _showAddServiceDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('إضافة خدمة جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
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
                    DataColumn(label: Text('السعر', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('مزود الخدمة', style: TextStyle(fontWeight: FontWeight.bold))),
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
                            Text(service.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(service.categoryName ?? 'غير مصنف', style: const TextStyle(color: AppColors.onSecondaryContainer, fontSize: 12)),
                        )),
                        DataCell(Text('SAR ${service.price}')),
                        DataCell(Text(service.providerName ?? 'غير معروف')),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_box, color: Colors.green),
                              tooltip: 'إضافة خدمة جديدة',
                              onPressed: () => _showAddServiceDialog(context, ref),
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
              await ref.read(servicesProvider.notifier).deleteService(id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    String? selectedCategoryId;
    
    showDialog(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final categoriesState = ref.watch(categoriesProvider);
            
            return AlertDialog(
              title: const Text('إضافة خدمة جديدة'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'اسم الخدمة'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'السعر (د.ل)'),
                    ),
                    const SizedBox(height: 16),
                    categoriesState.when(
                      data: (categories) {
                        final subCategories = categories.where((c) => c.parentId != null).toList();
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'التصنيف الفرعي'),
                          value: selectedCategoryId,
                          items: subCategories.map((c) {
                            final parent = categories.firstWhere((p) => p.id == c.parentId, orElse: () => c);
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text('${parent.name} - ${c.name}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            selectedCategoryId = val;
                          },
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => const Text('خطأ في جلب التصنيفات'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty || priceController.text.isEmpty) return;
                    
                    final price = double.tryParse(priceController.text) ?? 0.0;
                    
                    final errorMsg = await ref.read(servicesProvider.notifier).addService(
                      title: titleController.text.trim(),
                      price: price,
                      categoryId: selectedCategoryId,
                    );
                    
                    if (errorMsg == null && ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة الخدمة بنجاح')));
                    } else if (ctx.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل في الإضافة: $errorMsg')));
                    }
                  },
                  child: const Text('إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

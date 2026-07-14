import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/categories_provider.dart';
import '../models/category_model.dart';
import '../../../core/theme/app_colors.dart';

class CategoriesManagementScreen extends ConsumerWidget {
  const CategoriesManagementScreen({super.key});

  void _showAddEditDialog(BuildContext context, WidgetRef ref, [CategoryModel? category, CategoryModel? parent]) {
    final nameController = TextEditingController(text: category?.name);
    final iconController = TextEditingController(text: category?.icon);
    
    String? currentParentId = category?.parentId ?? parent?.id;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(category == null 
              ? (parent == null ? 'إضافة تصنيف رئيسي جديد' : 'إضافة تصنيف فرعي لـ ${parent.name}') 
              : 'تعديل التصنيف'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم التصنيف'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(labelText: 'رابط الأيقونة (اختياري)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                
                final notifier = ref.read(categoriesProvider.notifier);
                bool success;
                
                if (category == null) {
                  success = await notifier.addCategory(
                    nameController.text.trim(),
                    icon: iconController.text.trim(),
                    parentId: currentParentId,
                  );
                } else {
                  success = await notifier.updateCategory(
                    category.id,
                    nameController.text.trim(),
                    icon: iconController.text.trim(),
                    parentId: currentParentId,
                  );
                }

                if (success && ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم الحفظ بنجاح')),
                  );
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا التصنيف؟ سيتم حذف جميع التصنيفات الفرعية المرتبطة به أيضاً.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success = await ref.read(categoriesProvider.notifier).deleteCategory(id);
              if (success && ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم الحذف بنجاح')),
                );
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة التصنيفات'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showAddEditDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('تصنيف رئيسي جديد'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: categoriesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err', style: const TextStyle(color: Colors.red))),
        data: (categories) {
          final mainCategories = categories.where((c) => c.parentId == null).toList();

          if (mainCategories.isEmpty) {
            return const Center(child: Text('لا توجد تصنيفات حالياً. أضف تصنيفاً جديداً.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mainCategories.length,
            itemBuilder: (context, index) {
              final mainCategory = mainCategories[index];
              final subcategories = categories.where((c) => c.parentId == mainCategory.id).toList();

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(mainCategory.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('يحتوي على ${subcategories.length} تصنيفات فرعية'),
                  leading: mainCategory.icon != null && mainCategory.icon!.isNotEmpty
                      ? Image.network(mainCategory.icon!, width: 40, height: 40, errorBuilder: (_,__,___) => const Icon(Icons.category))
                      : const Icon(Icons.category, size: 40),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.primary),
                        tooltip: 'إضافة تصنيف فرعي',
                        onPressed: () => _showAddEditDialog(context, ref, null, mainCategory),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddEditDialog(context, ref, mainCategory),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCategory(context, ref, mainCategory.id),
                      ),
                    ],
                  ),
                  children: subcategories.map((sub) {
                    return ListTile(
                      contentPadding: const EdgeInsets.only(right: 48, left: 16),
                      leading: const Icon(Icons.subdirectory_arrow_left, size: 20),
                      title: Text(sub.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                            onPressed: () => _showAddEditDialog(context, ref, sub),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _deleteCategory(context, ref, sub.id),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

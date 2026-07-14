import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/categories_provider.dart';
import '../models/category_model.dart';
import '../../../core/theme/app_colors.dart';

class CategoriesManagementScreen extends ConsumerStatefulWidget {
  const CategoriesManagementScreen({super.key});

  @override
  ConsumerState<CategoriesManagementScreen> createState() => _CategoriesManagementScreenState();
}

class _CategoriesManagementScreenState extends ConsumerState<CategoriesManagementScreen> {
  String _searchQuery = '';

  void _showAddEditDialog(BuildContext context, [CategoryModel? category, CategoryModel? parent]) {
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
                    category!.id,
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

  void _deleteCategory(BuildContext context, String id) {
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
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إدارة التصنيفات',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('إضافة تصنيف رئيسي'),
                style: ElevatedButton.styleFrom(
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
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث عن تصنيف...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Categories List
          categoriesState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('خطأ: $err', style: const TextStyle(color: Colors.red))),
            data: (categories) {
              // Filtering
              final filteredCategories = categories.where((c) {
                return c.name.toLowerCase().contains(_searchQuery);
              }).toList();

              final mainCategories = filteredCategories.where((c) => c.parentId == null).toList();

              if (mainCategories.isEmpty) {
                return const Center(child: Text('لا توجد تصنيفات مطابقة للبحث.'));
              }

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mainCategories.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final mainCategory = mainCategories[index];
                    final subcategories = categories.where((c) => c.parentId == mainCategory.id).toList();

                    return ExpansionTile(
                      title: Text(mainCategory.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text('يحتوي على ${subcategories.length} تصنيفات فرعية', style: TextStyle(color: AppColors.onSurfaceVariant)),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: mainCategory.icon != null && mainCategory.icon!.isNotEmpty
                            ? Image.network(mainCategory.icon!, errorBuilder: (_,__,___) => const Icon(Icons.category, color: AppColors.onPrimaryContainer))
                            : const Icon(Icons.category, color: AppColors.onPrimaryContainer),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add, color: AppColors.primary),
                            tooltip: 'إضافة تصنيف فرعي',
                            onPressed: () => _showAddEditDialog(context, null, mainCategory),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'تعديل',
                            onPressed: () => _showAddEditDialog(context, mainCategory),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'حذف',
                            onPressed: () => _deleteCategory(context, mainCategory.id),
                          ),
                        ],
                      ),
                      children: subcategories.map((sub) {
                        return Container(
                          color: AppColors.surfaceContainerLow,
                          child: ListTile(
                            contentPadding: const EdgeInsets.only(right: 64, left: 16),
                            leading: const Icon(Icons.subdirectory_arrow_left, size: 20, color: AppColors.onSurfaceVariant),
                            title: Text(sub.name, style: const TextStyle(fontSize: 14)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                  onPressed: () => _showAddEditDialog(context, sub),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () => _deleteCategory(context, sub.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

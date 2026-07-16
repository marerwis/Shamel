import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/promotions_provider.dart';

class PromotionsManagementScreen extends ConsumerWidget {
  const PromotionsManagementScreen({super.key});

  void _showAddPromotionDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          XFile? selectedImage;
          Uint8List? imageBytes;
          
          return AlertDialog(
            title: const Text('إنشاء عرض ترويجي'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'عنوان العرض (مطلوب)'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'وصف العرض'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final file = await picker.pickImage(source: ImageSource.gallery);
                            if (file != null) {
                              final bytes = await file.readAsBytes();
                              setState(() {
                                selectedImage = file;
                                imageBytes = bytes;
                              });
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: const Text('اختيار صورة العرض'),
                        ),
                        const SizedBox(width: 16),
                        if (imageBytes != null)
                          Image.memory(imageBytes!, width: 60, height: 60, fit: BoxFit.cover)
                        else
                          const Text('مطلوب'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: targetUrlController,
                      decoration: const InputDecoration(
                        labelText: 'رابط التوجيه (اختياري)',
                        hintText: 'https://example.com/promo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              StatefulBuilder(
                builder: (context, setBtnState) {
                  bool isLoading = false;
                  return ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      if (titleController.text.isEmpty || imageBytes == null) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('الرجاء إدخال العنوان والصورة')));
                        return;
                      }
                      
                      setBtnState(() => isLoading = true);
                      
                      try {
                        final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
                        await Supabase.instance.client.storage.from('app_assets').uploadBinary('promotions/$fileName', imageBytes!);
                        final imageUrl = Supabase.instance.client.storage.from('app_assets').getPublicUrl('promotions/$fileName');
                        
                        final error = await ref.read(promotionsProvider.notifier).addPromotion(
                          title: titleController.text,
                          description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                          imageUrl: imageUrl,
                          targetUrl: targetUrlController.text.isNotEmpty ? targetUrlController.text : null,
                        );
                        
                        if (error == null && ctx.mounted) {
                          Navigator.pop(ctx);
                        } else if (error != null && ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(error)));
                          setBtnState(() => isLoading = false);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('خطأ في رفع الصورة: $e')));
                        setBtnState(() => isLoading = false);
                      }
                    },
                    child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('إنشاء'),
                  );
                }
              ),
            ],
          );
        }
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا العرض؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(promotionsProvider.notifier).deletePromotion(id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إدارة العروض الترويجية',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showAddPromotionDialog(context, ref);
                },
                icon: const Icon(Icons.local_offer),
                label: const Text('إنشاء عرض جديد'),
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
          
          // Analytics Cards
          Row(
            children: [
              Expanded(child: _buildStatCard(context, 'العروض النشطة', '12', Icons.local_activity, AppColors.primary)),
              const SizedBox(width: 24),
              Expanded(child: _buildStatCard(context, 'كوبونات مستخدمة', '1,420', Icons.confirmation_number, AppColors.secondary)),
              const SizedBox(width: 24),
              Expanded(child: _buildStatCard(context, 'إجمالي الخصومات الممنوحة', 'SAR 45,000', Icons.money_off, Colors.red)),
            ],
          ),
          const SizedBox(height: 32),
          
          // Promotions List
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('قائمة العروض الحالية', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                ref.watch(promotionsProvider).when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('خطأ: $error')),
                  data: (promotions) {
                    if (promotions.isEmpty) {
                      return const Center(child: Text('لا توجد عروض حالياً'));
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: promotions.length,
                      itemBuilder: (context, index) {
                        final promo = promotions[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.outlineVariant),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 60,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: promo.isActive ? AppColors.primary.withValues(alpha: 0.1) : AppColors.outlineVariant.withValues(alpha: 0.1),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        promo.title,
                                        style: TextStyle(fontWeight: FontWeight.bold, color: promo.isActive ? AppColors.primary : AppColors.outline),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: promo.isActive ? AppColors.primary : AppColors.outline,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        promo.isActive ? 'نشط' : 'متوقف',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(promo.description ?? 'بدون تفاصيل', maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: Icon(promo.isActive ? Icons.pause : Icons.play_arrow, color: promo.isActive ? Colors.orange : Colors.green),
                                            tooltip: promo.isActive ? 'إيقاف' : 'تفعيل',
                                            onPressed: () {
                                              ref.read(promotionsProvider.notifier).togglePromotionStatus(promo.id, !promo.isActive);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            tooltip: 'حذف',
                                            onPressed: () {
                                              _showDeleteDialog(context, ref, promo.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

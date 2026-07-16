import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../categories/providers/categories_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }
        ),
        title: const Text('Shamel'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  context.push('/notifications');
                },
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            TextField(
              decoration: InputDecoration(
                hintText: 'عن ماذا تبحث اليوم؟',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () {},
                  color: AppColors.primary,
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
              ),
            ),
            const SizedBox(height: 24),

            // Promos
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  _buildPromoCard(
                    context,
                    color: AppColors.primaryContainer,
                    onColor: AppColors.onPrimaryContainer,
                    title: 'خصم 20% على خدمات التنظيف',
                    subtitle: 'استخدم كود CLEAN20',
                    tag: 'عرض خاص',
                    tagColor: AppColors.secondary,
                    tagOnColor: AppColors.onSecondary,
                    imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?q=80&w=600&auto=format&fit=crop',
                    btnColor: AppColors.onPrimaryContainer,
                    btnOnColor: AppColors.primaryContainer,
                  ),
                  const SizedBox(width: 16),
                  _buildPromoCard(
                    context,
                    color: AppColors.tertiaryContainer,
                    onColor: AppColors.onTertiaryContainer,
                    title: 'صيانة المكيفات الدورية',
                    subtitle: 'حافظ على برودة صيفك',
                    tag: 'باقة التوفير',
                    tagColor: AppColors.surface,
                    tagOnColor: AppColors.onSurface,
                    imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=600&auto=format&fit=crop',
                    btnColor: AppColors.onTertiaryContainer,
                    btnOnColor: AppColors.tertiaryContainer,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Categories Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التصنيفات الرئيسية',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                TextButton(
                  onPressed: () {
                    context.push('/categories'); // We can make a categories list screen later
                  },
                  child: const Text('عرض الكل', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Categories Grid
            ref.watch(rootCategoriesProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('خطأ في جلب التصنيفات\n$err')),
              data: (categories) {
                if (categories.isEmpty) {
                  return const Center(child: Text('لا توجد تصنيفات متاحة'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context.push(
                            '/category_details', 
                            extra: category,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  category.iconData,
                                  color: AppColors.onPrimaryContainer,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.name,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),

            // Recent Orders
            Text(
              'طلباتي الأخيرة',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _buildRecentOrderItem(
              context,
              title: 'إصلاح تسريب مياه',
              date: 'اليوم، 10:30 صباحاً',
              status: 'مكتمل',
              icon: Icons.plumbing,
              iconColor: AppColors.onPrimaryContainer,
              iconBg: AppColors.primaryContainer,
              statusColor: AppColors.onSecondaryContainer,
              statusBg: AppColors.secondaryContainer.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            _buildRecentOrderItem(
              context,
              title: 'كي ملابس',
              date: 'أمس، 04:00 مساءً',
              status: 'قيد التنفيذ',
              icon: Icons.iron,
              iconColor: AppColors.onTertiaryContainer,
              iconBg: AppColors.tertiaryContainer,
              statusColor: AppColors.primary,
              statusBg: AppColors.primaryContainer.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard(
    BuildContext context, {
    required Color color,
    required Color onColor,
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required Color tagOnColor,
    required String imageUrl,
    required Color btnColor,
    required Color btnOnColor,
  }) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with overlay
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            color: color.withOpacity(0.6),
            colorBlendMode: BlendMode.overlay,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(color: tagOnColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: onColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: onColor.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    context.push('/booking');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: btnOnColor,
                    minimumSize: const Size(100, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('احجز الآن'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, IconData icon, Color bgColor, Color iconColor) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 32 - 32) / 3, // 3 per row approx
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Material(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  context.push(Uri.encodeFull('/category/$title'));
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildRecentOrderItem(
    BuildContext context, {
    required String title,
    required String date,
    required String status,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color statusColor,
    required Color statusBg,
  }) {
    return InkWell(
      onTap: () {
        context.push('/order_details/1');
      },
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.onBackground.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text(date, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

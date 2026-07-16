import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class CategoryProvidersScreen extends StatelessWidget {
  final String categoryName;
  const CategoryProvidersScreen({super.key, this.categoryName = 'مزودي الخدمة'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
          color: AppColors.primary,
        ),
        title: Text(categoryName, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            color: AppColors.onSurfaceVariant,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip(context, 'الأعلى تقييماً', Icons.star, true),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'الأقرب إليك', Icons.location_on, false),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'الأقل سعراً', Icons.attach_money, false),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'متاح الآن', Icons.flash_on, false),
              ],
            ),
          ),

          // Provider List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildProviderCard(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        context.push('/provider/1');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surfaceVariant, width: 2),
                        image: DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-${1560250097 + index}-0b93528c311a?q=80&w=200&auto=format&fit=crop'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (index % 2 == 0)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surfaceContainerLowest, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('أحمد محمود', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text('4.${9 - index}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(' (120)', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('متخصص صيانة عامة', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: AppColors.outline),
                          const SizedBox(width: 4),
                          Text('${index + 1}.5 كم', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.outline)),
                          const SizedBox(width: 16),
                          Icon(Icons.attach_money, size: 14, color: AppColors.outline),
                          const SizedBox(width: 4),
                          Text('${50 + (index * 10)} د.ل / ساعة', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.outline)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/booking');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('طلب الخدمة'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    context.push('/provider/1');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.outlineVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('الملف الشخصي'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

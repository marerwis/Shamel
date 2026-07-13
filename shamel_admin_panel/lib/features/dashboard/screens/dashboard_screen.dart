import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'نظرة عامة',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('تصدير التقرير'),
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
          
          // KPIs
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('خطأ في جلب الإحصائيات')),
            data: (stats) => Row(
              children: [
                Expanded(child: _buildKpiCard(context, 'إجمالي الإيرادات', 'SAR ${stats.totalRevenue}', '+0%', Icons.attach_money, AppColors.secondary)),
                const SizedBox(width: 24),
                Expanded(child: _buildKpiCard(context, 'الطلبات النشطة', '${stats.activeOrders}', '+0%', Icons.receipt_long, AppColors.primary)),
                const SizedBox(width: 24),
                Expanded(child: _buildKpiCard(context, 'مزودي الخدمة', '${stats.totalProviders}', '+0%', Icons.engineering, AppColors.tertiary)),
                const SizedBox(width: 24),
                Expanded(child: _buildKpiCard(context, 'المستخدمين', '${stats.totalUsers}', '+0%', Icons.people, AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Charts & Recent Activity
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Chart Placeholder
              Expanded(
                flex: 2,
                child: Container(
                  height: 400,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الإيرادات خلال العام', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bar_chart, size: 80, color: AppColors.surfaceVariant),
                              const SizedBox(height: 16),
                              Text('مساحة مخصصة للرسم البياني (Charts)', style: TextStyle(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              
              // Recent Orders
              Expanded(
                flex: 1,
                child: Container(
                  height: 400,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('أحدث الطلبات', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.separated(
                          itemCount: 5,
                          separatorBuilder: (context, index) => const Divider(height: 24),
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.handyman, color: AppColors.onPrimaryContainer, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('طلب صيانة #${10045 - index}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('منذ ${index + 1} ساعة', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                Text('SAR 150', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, String title, String value, String change, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onSurfaceVariant)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.secondary, size: 16),
              const SizedBox(width: 4),
              Text(change, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text('مقارنة بالشهر الماضي', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.outline)),
            ],
          ),
        ],
      ),
    );
  }
}

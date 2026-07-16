import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, we'd use a LayoutBuilder for the sidebar on tablet/desktop
    // For now, focusing on the mobile layout per the design.
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              color: AppColors.primary,
            );
          }
        ),
        title: const Text('Shamel Dashboard', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryContainer, width: 2),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceVariant),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('أهلاً أحمد،', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('إليك ملخص أداءك اليوم.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, color: AppColors.onSecondaryContainer, size: 16),
                        const SizedBox(width: 4),
                        const Text('متاح للعمل', style: TextStyle(color: AppColors.onSecondaryContainer, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return isWide
                    ? Row(
                        children: [
                          Expanded(child: _buildStatCard(context, 'إجمالي الأرباح', '2,450', 'د.ل', Icons.payments, AppColors.primary, '+12%')),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard(context, 'الطلبات النشطة', '3', '', Icons.work_history, AppColors.secondary, null)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard(context, 'تقييم الأداء', '4.8', '★', Icons.star, AppColors.tertiaryContainer, 'من 150 تقييم', isRating: true)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildStatCard(context, 'إجمالي الأرباح', '2,450', 'د.ل', Icons.payments, AppColors.primary, '+12%'),
                          const SizedBox(height: 16),
                          _buildStatCard(context, 'الطلبات النشطة', '3', '', Icons.work_history, AppColors.secondary, null),
                          const SizedBox(height: 16),
                          _buildStatCard(context, 'تقييم الأداء', '4.8', '★', Icons.star, AppColors.tertiaryContainer, 'من 150 تقييم', isRating: true),
                        ],
                      );
              },
            ),
            const SizedBox(height: 24),

            // Current Orders
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceVariant),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الطلبات الحالية', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            context.push('/orders');
                          }, 
                          child: const Text('عرض الكل', style: TextStyle(color: AppColors.secondary))
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.surfaceVariant),
                  _buildOrderItem(context, 'صيانة سباكة - تسرب مياه', 'اليوم، 10:30 صباحاً', 'حي الملقا، الرياض', Icons.plumbing, AppColors.secondary, 'قيد التنفيذ', AppColors.primary),
                  const Divider(height: 1, color: AppColors.surfaceVariant),
                  _buildOrderItem(context, 'إصلاح كهرباء - شورت', 'اليوم، 02:00 مساءً', 'حي النرجس، الرياض', Icons.electric_bolt, AppColors.tertiaryContainer, 'مجدول', AppColors.onSurfaceVariant),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Weekly Stats Placeholder
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceVariant),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('إحصائيات الأسبوع', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      // Simple bar chart mock
                      Expanded(
                        child: SizedBox(
                          height: 150,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildBar(40, 'الأحد', AppColors.primary.withOpacity(0.2)),
                              _buildBar(60, 'الإثنين', AppColors.primary.withOpacity(0.4)),
                              _buildBar(90, 'الثلاثاء', AppColors.primary),
                              _buildBar(50, 'الأربعاء', AppColors.primary.withOpacity(0.6)),
                              _buildBar(70, 'الخميس', AppColors.primary.withOpacity(0.3)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Sidebar stats
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('المهام المنجزة', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 4),
                            Text('14 مهمة', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: AppColors.surfaceVariant),
                            ),
                            Text('معدل الإنجاز', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 4),
                            Text('92%', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, String unit, IconData icon, Color color, String? badge, {bool isRating = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRating ? AppColors.surfaceVariant.withOpacity(0.5) : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(badge, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isRating ? AppColors.onSurfaceVariant : color)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                isRating
                    ? Icon(Icons.star, color: color, size: 24)
                    : Text(unit, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, String title, String time, String location, IconData icon, Color iconColor, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(time, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('•', style: TextStyle(color: AppColors.onSurfaceVariant))),
                    const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(location, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Text(status, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: statusColor)),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  context.push('/order_details/1');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide.none,
                  backgroundColor: AppColors.surfaceVariant,
                  foregroundColor: AppColors.onSurface,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('التفاصيل'),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_left, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightPercentage, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 120 * (heightPercentage / 100),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

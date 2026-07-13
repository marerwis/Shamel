import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
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
        title: const Text('تفاصيل الطلب', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
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
                      Text('طلب رقم', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                      Text('#SH-9824', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
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
                        const Icon(Icons.sync, color: AppColors.onSecondaryContainer, size: 16),
                        const SizedBox(width: 8),
                        const Text('الخدمة قيد التنفيذ', style: TextStyle(color: AppColors.onSecondaryContainer, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tracking Stepper
            _buildSectionContainer(
              context,
              title: 'حالة الطلب',
              child: Column(
                children: [
                  _buildStep(context, title: 'تم استلام الطلب', subtitle: '12 أكتوبر 2023, 09:00 ص', isActive: false, isCompleted: true),
                  _buildStep(context, title: 'مزود الخدمة في الطريق', subtitle: '12 أكتوبر 2023, 09:45 ص', isActive: false, isCompleted: true),
                  _buildStep(context, title: 'الخدمة قيد التنفيذ', subtitle: 'بدأ العمل: 10:15 ص', isActive: true, isCompleted: false),
                  _buildStep(context, title: 'المراجعة والدفع', subtitle: 'في انتظار انتهاء الخدمة', isActive: false, isCompleted: false, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Provider Info
            _buildSectionContainer(
              context,
              title: 'مزود الخدمة',
              child: InkWell(
                onTap: () {
                  context.push('/provider/1');
                },
                child: Row(
                  children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surfaceVariant, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('أحمد محمود', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('فني صيانة عامة • تقييم 4.9', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (index) => Icon(Icons.star, color: index < 4 ? Colors.amber : Colors.amber.withOpacity(0.5), size: 16)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.push('/live_chat');
                    },
                    icon: const Icon(Icons.chat),
                    color: AppColors.primary,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Service Details
            _buildSectionContainer(
              context,
              title: 'تفاصيل الخدمة',
              child: Column(
                children: [
                  _buildDetailRow(context, Icons.home_repair_service, 'نوع الخدمة', 'صيانة أجهزة تكييف'),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, Icons.calendar_month, 'الموعد', '12 أكتوبر 2023, 10:00 ص'),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, Icons.location_on, 'الموقع', 'فيلا 45، شارع العليا، الرياض'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order Summary
            _buildSectionContainer(
              context,
              title: 'ملخص الطلب',
              child: Column(
                children: [
                  _buildSummaryRow(context, 'تكلفة الخدمة (تقديرية)', '150 ر.س'),
                  const SizedBox(height: 12),
                  _buildSummaryRow(context, 'رسوم الزيارة', '50 ر.س'),
                  const SizedBox(height: 12),
                  _buildSummaryRow(context, 'الضريبة (15%)', '30 ر.س'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: AppColors.outlineVariant),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الإجمالي', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      Text('230 ر.س', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info, color: AppColors.secondary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'التكلفة النهائية قد تتغير بناءً على قطع الغيار أو العمل الإضافي المطلوب بعد التقييم النهائي.',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.cancel),
                label: const Text('إلغاء الطلب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorContainer,
                  foregroundColor: AppColors.onErrorContainer,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer(BuildContext context, {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, {required String title, required String subtitle, required bool isActive, required bool isCompleted, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.secondary : (isActive ? AppColors.primary : AppColors.surface),
                  border: isCompleted || isActive ? null : Border.all(color: AppColors.outlineVariant, width: 2),
                  boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)] : null,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: AppColors.onSecondary)
                    : (isActive ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.onPrimary, shape: BoxShape.circle))) : null),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.outlineVariant,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isActive ? AppColors.primary : (isCompleted ? AppColors.onSurface : AppColors.onSurfaceVariant),
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurface)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface)),
      ],
    );
  }
}

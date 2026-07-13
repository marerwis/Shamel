import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
        title: const Text('الإشعارات', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNotificationItem(
            context,
            title: 'تم تأكيد حجزك!',
            message: 'تم تأكيد حجز خدمة صيانة التكييف بنجاح.',
            time: 'منذ ساعتين',
            icon: Icons.check_circle,
            color: AppColors.secondary,
            isNew: true,
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            context,
            title: 'عرض خاص لك 🎉',
            message: 'احصل على خصم 20% على خدمات التنظيف اليوم.',
            time: 'منذ 5 ساعات',
            icon: Icons.local_offer,
            color: AppColors.primary,
            isNew: true,
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            context,
            title: 'اكتملت الخدمة',
            message: 'نرجو تقييم الخدمة التي قدمها أحمد محمود.',
            time: 'أمس',
            icon: Icons.star,
            color: AppColors.tertiaryContainer,
            isNew: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required Color color,
    required bool isNew,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNew ? AppColors.surfaceContainerLowest : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNew ? color.withValues(alpha: 0.3) : AppColors.surfaceVariant,
        ),
        boxShadow: [
          if (isNew)
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: isNew ? FontWeight.bold : FontWeight.normal,
                            ),
                      ),
                    ),
                    if (isNew)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.outline,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

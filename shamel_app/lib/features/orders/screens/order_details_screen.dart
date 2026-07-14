import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/orders_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../chat/providers/chat_provider.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final OrderModel? order;

  const OrderDetailsScreen({super.key, this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الطلب')),
        body: const Center(child: Text('الطلب غير موجود')),
      );
    }

    final user = ref.watch(currentUserProvider);
    final isProvider = user?.role == 'provider';

    String statusAr = order!.status;
    Color statusColor = AppColors.onSurfaceVariant;
    Color statusBg = AppColors.surfaceVariant;
    IconData statusIcon = Icons.schedule;

    switch (order!.status) {
      case 'pending':
        statusAr = 'قيد الانتظار';
        statusColor = Colors.orange;
        statusBg = Colors.orange.withOpacity(0.1);
        statusIcon = Icons.hourglass_empty;
        break;
      case 'accepted':
        statusAr = 'تم القبول';
        statusColor = Colors.blue;
        statusBg = Colors.blue.withOpacity(0.1);
        statusIcon = Icons.thumb_up;
        break;
      case 'in_progress':
        statusAr = 'قيد التنفيذ';
        statusColor = AppColors.primary;
        statusBg = AppColors.primaryContainer.withOpacity(0.1);
        statusIcon = Icons.sync;
        break;
      case 'completed':
        statusAr = 'مكتمل';
        statusColor = Colors.green;
        statusBg = Colors.green.withOpacity(0.1);
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusAr = 'ملغى';
        statusColor = Colors.red;
        statusBg = Colors.red.withOpacity(0.1);
        statusIcon = Icons.cancel;
        break;
    }

    final serviceName = order!.service?['name'] ?? 'خدمة عامة';
    final otherParty = isProvider ? order!.customer : order!.provider;
    final otherPartyName = otherParty != null ? otherParty['full_name'] : 'غير معروف';
    final otherPartyAvatar = otherParty != null ? otherParty['avatar_url'] : null;

    final dateStr = order!.scheduledAt != null 
        ? '${order!.scheduledAt!.year}-${order!.scheduledAt!.month.toString().padLeft(2, '0')}-${order!.scheduledAt!.day.toString().padLeft(2, '0')} ${order!.scheduledAt!.hour}:00'
        : 'غير محدد';

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
                      Text('رقم الطلب', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                      Text('#${order!.id.substring(0, 8).toUpperCase()}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),
                        const SizedBox(width: 8),
                        Text(statusAr, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Provider/Customer Info
            _buildSectionContainer(
              context,
              title: isProvider ? 'العميل' : 'مزود الخدمة',
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: otherPartyAvatar != null ? NetworkImage(otherPartyAvatar) : null,
                    child: otherPartyAvatar == null ? const Icon(Icons.person) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(otherPartyName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (otherParty != null) {
                        final chatId = await ref.read(chatsListProvider.notifier).createOrGetChat(
                          otherUserId: otherParty['id'],
                          orderId: order!.id,
                        );
                        if (chatId != null && context.mounted) {
                          context.push('/live_chat/$chatId');
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('فشل في فتح المحادثة')),
                          );
                        }
                      }
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
            const SizedBox(height: 24),

            // Service Details
            _buildSectionContainer(
              context,
              title: 'تفاصيل الخدمة',
              child: Column(
                children: [
                  _buildDetailRow(context, Icons.home_repair_service, 'نوع الخدمة', serviceName),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, Icons.calendar_month, 'الموعد', dateStr),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, Icons.location_on, 'الموقع', order!.address),
                  if (order!.notes != null && order!.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow(context, Icons.note, 'الملاحظات', order!.notes!),
                  ]
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
                  _buildSummaryRow(context, 'تكلفة الخدمة', '${order!.price ?? 0} ر.س'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: AppColors.outlineVariant),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الإجمالي', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      Text('${order!.price ?? 0} ر.س', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (isProvider && order!.status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref.read(ordersProvider.notifier).updateOrderStatus(order!.id, 'accepted');
                        if (context.mounted) context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('قبول الطلب'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref.read(ordersProvider.notifier).updateOrderStatus(order!.id, 'rejected');
                        if (context.mounted) context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('رفض الطلب'),
                    ),
                  ),
                ],
              ),
            ] else if (isProvider && order!.status == 'accepted') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(ordersProvider.notifier).updateOrderStatus(order!.id, 'in_progress');
                    if (context.mounted) context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('بدء التنفيذ'),
                ),
              ),
            ] else if (isProvider && order!.status == 'in_progress') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(ordersProvider.notifier).updateOrderStatus(order!.id, 'completed');
                    if (context.mounted) context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('إكمال الخدمة'),
                ),
              ),
            ] else if (!isProvider && (order!.status == 'pending' || order!.status == 'accepted')) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(ordersProvider.notifier).updateOrderStatus(order!.id, 'cancelled');
                    if (context.mounted) context.pop();
                  },
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
            ],
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

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
        title: const Text('الرسائل', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'البحث في الرسائل...',
                hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          
          // Messages List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildChatItem(
                  context,
                  name: 'أحمد للصيانة',
                  time: 'الآن',
                  serviceType: 'صيانة منزلية',
                  message: 'مرحباً، سأكون عندك خلال 15 دقيقة.',
                  unreadCount: 1,
                  avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop',
                  isUnread: true,
                ),
                const SizedBox(height: 12),
                _buildChatItem(
                  context,
                  name: 'مؤسسة النور للتنظيف',
                  time: '10:30 ص',
                  serviceType: 'تنظيف شامل',
                  message: 'تم استلام الدفعة، شكراً لك.',
                  unreadCount: 0,
                  avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200&auto=format&fit=crop',
                  isReadReceipt: true,
                ),
                const SizedBox(height: 12),
                _buildChatItem(
                  context,
                  name: 'سعيد للكهرباء',
                  time: 'أمس',
                  serviceType: 'أعمال كهرباء',
                  message: 'هل يمكنك إرسال صورة للمشكلة؟',
                  unreadCount: 0,
                  avatarUrl: 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?q=80&w=200&auto=format&fit=crop',
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context, {
    required String name,
    required String time,
    required String serviceType,
    required String message,
    required int unreadCount,
    required String avatarUrl,
    bool isUnread = false,
    bool isReadReceipt = false,
  }) {
    return InkWell(
      onTap: () {
        context.push('/live_chat');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread ? AppColors.primary.withValues(alpha: 0.3) : AppColors.outlineVariant,
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: isUnread ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 4)] : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                    image: DecorationImage(
                      image: NetworkImage(avatarUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isUnread)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isUnread ? AppColors.primary : AppColors.onSurfaceVariant,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isUnread ? AppColors.secondaryContainer : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      serviceType,
                      style: TextStyle(
                        fontSize: 10,
                        color: isUnread ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isReadReceipt && !isUnread) ...[
                        const Icon(Icons.done_all, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          message,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isUnread ? AppColors.onSurface : AppColors.onSurfaceVariant,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Unread Badge
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(color: AppColors.onError, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

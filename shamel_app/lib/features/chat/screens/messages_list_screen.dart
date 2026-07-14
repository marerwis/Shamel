import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/chat_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessagesListScreen extends ConsumerStatefulWidget {
  const MessagesListScreen({super.key});

  @override
  ConsumerState<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends ConsumerState<MessagesListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatsListProvider);
    final user = ref.watch(currentUserProvider);
    final isProvider = user?.role == 'provider';

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
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
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
            child: chatsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('خطأ: $err')),
              data: (chats) {
                final filteredChats = chats.where((chat) {
                  final otherParty = isProvider ? chat.customer : chat.provider;
                  final otherName = otherParty != null ? otherParty['full_name'].toString().toLowerCase() : '';
                  return otherName.contains(_searchQuery);
                }).toList();

                if (filteredChats.isEmpty) {
                  return const Center(child: Text('لا توجد محادثات'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredChats.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final chat = filteredChats[index];
                    final otherParty = isProvider ? chat.customer : chat.provider;
                    final otherName = otherParty != null ? otherParty['full_name'] : 'مستخدم';
                    final otherAvatar = otherParty != null ? otherParty['avatar_url'] : null;
                    
                    final lastMsg = chat.recentMessages.isNotEmpty ? chat.recentMessages.first : null;
                    final msgContent = lastMsg?.content ?? 'لا توجد رسائل';
                    final msgTime = lastMsg != null ? timeago.format(lastMsg.createdAt, locale: 'ar') : '';
                    final isUnread = lastMsg != null && !lastMsg.isRead && lastMsg.senderId != user?.id;

                    return _buildChatItem(
                      context,
                      chatId: chat.id,
                      name: otherName,
                      time: msgTime,
                      serviceType: chat.orderId != null ? 'طلب #${chat.orderId!.substring(0,6)}' : 'دردشة عامة',
                      message: msgContent,
                      unreadCount: isUnread ? 1 : 0, // Simplified for now
                      avatarUrl: otherAvatar,
                      isUnread: isUnread,
                      isReadReceipt: lastMsg != null && lastMsg.isRead && lastMsg.senderId == user?.id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context, {
    required String chatId,
    required String name,
    required String time,
    required String serviceType,
    required String message,
    required int unreadCount,
    String? avatarUrl,
    bool isUnread = false,
    bool isReadReceipt = false,
  }) {
    return InkWell(
      onTap: () {
        context.push('/live_chat/$chatId');
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
                CircleAvatar(
                  radius: 28,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null ? const Icon(Icons.person) : null,
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

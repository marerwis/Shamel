import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class LiveChatScreen extends StatelessWidget {
  const LiveChatScreen({super.key});

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
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أحمد', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('متخصص سباكة • متصل الآن', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 16),
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.call, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('جاري الاتصال...')),
                );
              },
              color: AppColors.onSecondaryContainer,
            ),
          ),
        ],
        backgroundColor: AppColors.surface,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: Column(
        children: [
          // Chat Canvas
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                // Date Divider
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('اليوم', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                  ),
                ),
                const SizedBox(height: 24),

                // Received Message 1
                _buildMessageBubble(
                  context,
                  message: 'مرحباً! أنا أحمد، متخصص السباكة. كيف يمكنني مساعدتك اليوم؟',
                  time: '10:30 ص',
                  isMe: false,
                ),
                const SizedBox(height: 16),

                // Sent Message 1
                _buildMessageBubble(
                  context,
                  message: 'أهلاً أحمد، لدي تسريب في حوض المطبخ ويبدو أنه يحتاج إلى إصلاح عاجل.',
                  time: '10:32 ص',
                  isMe: true,
                  isRead: true,
                ),
                const SizedBox(height: 16),

                // Received Message 2
                _buildMessageBubble(
                  context,
                  message: 'مفهوم. هل يمكنك إرسال صورة للمشكلة حتى أتمكن من تقييم الوضع بشكل أفضل؟',
                  time: '10:33 ص',
                  isMe: false,
                ),
                const SizedBox(height: 16),

                // Sent Message 2 (With Image)
                _buildMessageBubble(
                  context,
                  message: 'إليك الصورة، التسريب من الأنبوب السفلي.',
                  time: '10:35 ص',
                  isMe: true,
                  isRead: false,
                  imageUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=400&auto=format&fit=crop',
                ),
              ],
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    context.push('/chat_quote');
                  },
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, size: 20),
                    onPressed: () {},
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context, {
    required String message,
    required String time,
    required bool isMe,
    bool isRead = false,
    String? imageUrl,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.all(imageUrl != null ? 8 : 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 0 : 16),
                  bottomRight: Radius.circular(isMe ? 16 : 0),
                ),
                border: isMe ? null : Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Padding(
                    padding: imageUrl != null ? const EdgeInsets.symmetric(horizontal: 4) : EdgeInsets.zero,
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isMe ? AppColors.onPrimaryContainer : AppColors.onSurface,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMe) ...[
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: isRead ? AppColors.primary : AppColors.outline,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  time,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

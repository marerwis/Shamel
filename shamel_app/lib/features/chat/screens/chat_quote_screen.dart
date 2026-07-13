import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class ChatQuoteScreen extends StatelessWidget {
  const ChatQuoteScreen({super.key});

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
              onPressed: () {},
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
                  isRead: true,
                  imageUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=400&auto=format&fit=crop',
                ),
                const SizedBox(height: 16),
                
                // Quote Message
                _buildQuoteBubble(context),
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
                  onPressed: () {},
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

  Widget _buildQuoteBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(0),
                ),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إصلاح تسريب مياه', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('عرض سعر', style: TextStyle(color: AppColors.onPrimaryContainer, fontSize: 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('150', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('ريال', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'شامل قطع الغيار والعمالة وضمان لمدة شهر على الإصلاح.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم قبول العرض بنجاح')),
                          );
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('قبول العرض'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم رفض العرض')),
                          );
                          context.pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.onSurfaceVariant,
                          side: const BorderSide(color: AppColors.outline),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('رفض'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '10:36 ص',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.outline),
            ),
          ],
        ),
      ),
    );
  }
}

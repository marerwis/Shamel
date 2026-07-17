import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/orders_provider.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderId = order.id;
    final isProcessing = ref.watch(ordersProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isCustomer = currentUserId == order.userId;
    final isProvider = currentUserId == order.providerId;

    // Timeline calculation
    // 'accepted' -> Stage 1
    // 'in_progress' -> Stage 2
    // 'completed' -> Stage 3
    int currentStage = 0;
    if (order.status == 'accepted') currentStage = 1;
    if (order.status == 'in_progress') currentStage = 2;
    if (order.status == 'completed') currentStage = 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل التوصيل'),
      ),
      body: Column(
        children: [
          // 1. Map Placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              image: const DecorationImage(
                image: NetworkImage('https://i.stack.imgur.com/HILmr.png'), // A static map background placeholder
                fit: BoxFit.cover,
                opacity: 0.5,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 50, color: Colors.red),
                  SizedBox(height: 8),
                  Text('خريطة التوصيل (مباشر)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, backgroundColor: Colors.white70)),
                ],
              ),
            ),
          ),

          // 2. Order Info Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الطلب #${order.id.substring(0, 8)}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    Text('${order.price} د.ل', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('الوصف: ${order.notes ?? 'لا يوجد'}', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),

          if (isProcessing) const LinearProgressIndicator(),

          const SizedBox(height: 16),

          // 3. Delivery Timeline
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  const Text('حالة الطلب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  // Stage 1
                  _buildTimelineTile(
                    title: 'جاري تحضير الطلب',
                    subtitle: 'المطعم يقوم بتجهيز طلبك',
                    icon: Icons.restaurant,
                    isActive: currentStage >= 1,
                    isLast: false,
                  ),
                  
                  // Stage 2
                  _buildTimelineTile(
                    title: 'جاري التوصيل',
                    subtitle: 'الكابتن في طريقه إليك',
                    icon: Icons.delivery_dining,
                    isActive: currentStage >= 2,
                    isLast: false,
                  ),
                  
                  // Stage 3
                  _buildTimelineTile(
                    title: 'تم التسليم',
                    subtitle: 'بالهناء والشفاء!',
                    icon: Icons.check_circle,
                    isActive: currentStage >= 3,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),

          // 4. Captain Controls
          if (isProvider && order.status != 'completed' && order.status != 'Cancelled' && order.status != 'Disputed')
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              width: double.infinity,
              child: Column(
                children: [
                  if (order.status == 'accepted')
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        try {
                          await ref.read(ordersProvider.notifier).updateOrderStatus(orderId, 'in_progress');
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الحالة إلى: جاري التوصيل')));
                        } catch (e) {
                          final msg = e.toString().replaceAll('Exception: ', '');
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $msg')));
                        }
                      },
                      icon: const Icon(Icons.motorcycle),
                      label: const Text('استلمت الطلب من المطعم', style: TextStyle(fontSize: 18)),
                    ),

                  if (order.status == 'in_progress')
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        // Confirm dialog
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('تأكيد التسليم'),
                            content: const Text('هل أنت متأكد من تسليم الطلب للعميل؟ سيتم تحويل الأرباح لمحفظتك فوراً.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')),
                              TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('تأكيد التوصيل')),
                            ],
                          )
                        );

                        if (confirm == true) {
                          try {
                            await ref.read(ordersProvider.notifier).completeDelivery(orderId, currentUserId!, order.price);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنهاء الطلب وتحويل الأرباح لمحفظتك بنجاح!')));
                              Navigator.pop(context); // Go back after completion
                            }
                          } catch (e) {
                            final msg = e.toString().replaceAll('Exception: ', '');
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $msg')));
                          }
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('قمت بتسليم الطلب', style: TextStyle(fontSize: 18)),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineTile({required String title, required String subtitle, required IconData icon, required bool isActive, required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              backgroundColor: isActive ? Colors.blue : Colors.grey.shade300,
              child: Icon(icon, color: Colors.white),
            ),
            if (!isLast)
              Container(
                height: 40,
                width: 2,
                color: isActive ? Colors.blue : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.grey)),
              Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey)),
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

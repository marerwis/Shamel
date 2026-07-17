import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/orders_provider.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderId = order.id;
    final milestonesStream = ref.watch(orderMilestonesStreamProvider(orderId));
    final isProcessing = ref.watch(ordersProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isCustomer = currentUserId == order.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطلب والدفعات'),
      ),
      body: Column(
        children: [
          // Order Status Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            width: double.infinity,
            child: Column(
              children: [
                Text('المبلغ الإجمالي: ${order.price} د.ل', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 8),
                Text('حالة الطلب: ${order.status}', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          
          if (isProcessing) const LinearProgressIndicator(),

          if ((order.status == 'accepted' || order.status == 'in_progress') && 
              ((isCustomer && order.provider?['phone'] != null) || (!isCustomer && order.customer?['phone'] != null)))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () async {
                        final phone = isCustomer ? order.provider?['phone'] : order.customer?['phone'];
                        if (phone != null) {
                          final url = Uri.parse('whatsapp://send?phone=$phone');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن فتح واتساب')));
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('واتساب'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      onPressed: () async {
                        final phone = isCustomer ? order.provider?['phone'] : order.customer?['phone'];
                        if (phone != null) {
                          final url = Uri.parse('tel:$phone');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن إجراء المكالمة')));
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.call),
                      label: const Text('اتصال'),
                    ),
                  ),
                ],
              ),
            ),

          // Milestones List
          Expanded(
            child: milestonesStream.when(
              data: (milestones) {
                if (milestones.isEmpty) {
                  return const Center(child: Text('جاري تحميل الدفعات...'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: milestones.length,
                  itemBuilder: (context, index) {
                    final m = milestones[index];
                    final isPaid = m['status'] == 'Paid';

                    return Card(
                      color: isPaid ? Colors.green.shade50 : Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPaid ? Colors.green : Colors.grey,
                          child: Icon(isPaid ? Icons.check : Icons.hourglass_bottom, color: Colors.white),
                        ),
                        title: Text(m['description'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('المبلغ: ${m['amount']} د.ل'),
                        trailing: isCustomer && !isPaid && order.status != 'Disputed' && order.status != 'Cancelled'
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                onPressed: () async {
                                  // Show confirm dialog
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('تأكيد الدفع'),
                                      content: const Text('هل أنت متأكد من تسليم هذه الدفعة للمزود؟ لا يمكن التراجع عن هذه الخطوة.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')),
                                        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('تأكيد التسليم')),
                                      ],
                                    )
                                  );

                                  if (confirm == true) {
                                    try {
                                      final double amount = double.parse(m['amount'].toString());
                                      await ref.read(ordersProvider.notifier).releaseMilestone(m['id'], orderId, amount, order.providerId);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحويل الدفعة للمزود بنجاح!')));
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                                    }
                                  }
                                },
                                child: const Text('تسليم الدفعة'),
                              )
                            : isPaid 
                                ? const Text('تم التسليم', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                : const Text('قيد الانتظار', style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('خطأ: $err')),
            ),
          ),
          
          // Dispute Action
          if (order.status != 'Completed' && order.status != 'Cancelled' && order.status != 'Disputed')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: () async {
                    // Show dispute dialog
                    String reason = '';
                    final submit = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('إبلاغ عن مشكلة / تجميد الدفع'),
                        content: TextField(
                          decoration: const InputDecoration(hintText: 'اكتب سبب المشكلة بوضوح للإدارة...'),
                          maxLines: 3,
                          onChanged: (val) => reason = val,
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            onPressed: () => Navigator.pop(c, true), 
                            child: const Text('رفع النزاع للإدارة')
                          ),
                        ],
                      )
                    );

                    if (submit == true && reason.isNotEmpty) {
                      try {
                        await ref.read(ordersProvider.notifier).raiseDispute(orderId, reason);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفع النزاع وإيقاف الدفعات. سنتواصل معك قريباً.')));
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                      }
                    }
                  },
                  icon: const Icon(Icons.gavel),
                  label: const Text('إبلاغ عن مشكلة (تجميد الدفعات)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

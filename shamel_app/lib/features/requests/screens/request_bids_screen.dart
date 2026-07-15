import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/requests_provider.dart';

class RequestBidsScreen extends ConsumerWidget {
  final Map<String, dynamic> requestData;
  const RequestBidsScreen({super.key, required this.requestData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestId = requestData['id'];
    final bidsStream = ref.watch(requestBidsProvider(requestId));
    final isProcessing = ref.watch(requestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('عروض الأسعار'),
      ),
      body: Column(
        children: [
          // Request Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تفاصيل طلبك:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(requestData['description'] ?? ''),
                const SizedBox(height: 8),
                Text('الحالة: ${requestData['status']}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          if (isProcessing) const LinearProgressIndicator(),

          // Bids List
          Expanded(
            child: bidsStream.when(
              data: (bids) {
                if (bids.isEmpty) {
                  return const Center(child: Text('جاري انتظار العروض من المزودين...'));
                }

                // Filter out rejected bids so customer doesn't see them anymore
                final visibleBids = bids.where((b) => b['status'] != 'Rejected').toList();

                if (visibleBids.isEmpty) {
                  return const Center(child: Text('لا توجد عروض متاحة حالياً.'));
                }

                return ListView.builder(
                  itemCount: visibleBids.length,
                  itemBuilder: (context, index) {
                    final bid = visibleBids[index];
                    return _BidCard(
                      bid: bid, 
                      requestId: requestId,
                      isAccepted: requestData['status'] == 'Accepted' || bid['status'] == 'Accepted',
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('خطأ: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _BidCard extends ConsumerWidget {
  final Map<String, dynamic> bid;
  final String requestId;
  final bool isAccepted; // If the request is already accepted, disable buttons

  const _BidCard({required this.bid, required this.requestId, required this.isAccepted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerAsync = ref.watch(bidProviderDetailsProvider(bid['provider_id']));
    final createdAt = DateTime.parse(bid['created_at']);
    final timeAgoStr = timeago.format(createdAt, locale: 'ar');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                providerAsync.when(
                  data: (provider) => CircleAvatar(
                    backgroundImage: provider['avatar_url'] != null ? NetworkImage(provider['avatar_url']) : null,
                    child: provider['avatar_url'] == null ? const Icon(Icons.person) : null,
                  ),
                  loading: () => const CircleAvatar(child: CircularProgressIndicator()),
                  error: (_, __) => const CircleAvatar(child: Icon(Icons.error)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      providerAsync.when(
                        data: (provider) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(provider['full_name'] ?? 'مزود مجهول', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (provider['is_premium'] == true)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Tooltip(message: 'مميز', child: Text('👑')),
                                  ),
                                if (provider['is_fast'] == true)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Tooltip(message: 'سريع التجاوب', child: Text('⚡')),
                                  ),
                                if (provider['is_clean'] == true)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Tooltip(message: 'عمل نظيف', child: Text('✨')),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        loading: () => const Text('جاري التحميل...'),
                        error: (_, __) => const Text('خطأ'),
                      ),
                      const SizedBox(height: 4),
                      Text(timeAgoStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Text(
                  '${bid['price']} د.ل',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green),
                ),
              ],
            ),
            if (!isAccepted && bid['status'] == 'Pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () async {
                        try {
                          await ref.read(requestsProvider.notifier).rejectBid(bid['id'], bid['provider_id'], requestId);
                        } catch(e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                        }
                      },
                      child: const Text('رفض وإخفاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () async {
                        try {
                          final priceStr = bid['price'].toString();
                          final price = double.parse(priceStr);
                          await ref.read(requestsProvider.notifier).acceptBid(bid['id'], requestId, bid['provider_id'], price);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم قبول العرض وتحويل المبلغ למحفظة الحجز (Escrow)!')));
                          }
                        } catch(e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                        }
                      },
                      child: const Text('قبول العرض'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  // Navigate to Live Chat to negotiate
                  context.push('/chat', extra: bid['provider_id']);
                }, 
                icon: const Icon(Icons.chat), 
                label: const Text('محادثة للتفاوض')
              )
            ] else if (bid['status'] == 'Accepted') ...[
               const SizedBox(height: 16),
               const Text('تم قبول هذا العرض ✅', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ]
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/bids_blocks_provider.dart';

class BidsBlocksScreen extends ConsumerWidget {
  const BidsBlocksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مراقبة العروض والحظر'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'عروض الأسعار (Bids)'),
              Tab(text: 'قائمة الحظر (Blocklist)'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BidsList(),
            _BlocksList(),
          ],
        ),
      ),
    );
  }
}

class _BidsList extends ConsumerWidget {
  const _BidsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bidsAsync = ref.watch(adminBidsProvider);

    return bidsAsync.when(
      data: (bids) {
        if (bids.isEmpty) return const Center(child: Text('لا توجد عروض أسعار'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bids.length,
          itemBuilder: (context, index) {
            final bid = bids[index];
            final providerName = bid['profiles']?['full_name'] ?? 'مجهول';
            final requestDesc = bid['requests']?['description'] ?? 'بدون وصف';
            final categoryName = bid['requests']?['categories']?['name'] ?? 'غير محدد';
            final date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(bid['created_at']));

            return Card(
              child: ListTile(
                title: Text('المزود: $providerName'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الطلب: $categoryName - $requestDesc', maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('السعر: ${bid['price']} | صافي الربح: ${bid['net_profit']}'),
                    Text('الحالة: ${bid['status']} | التاريخ: $date', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                isThreeLine: true,
                trailing: Chip(
                  label: Text(bid['status']),
                  backgroundColor: bid['status'] == 'Accepted' ? Colors.green.shade100 : Colors.grey.shade200,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('خطأ: $err')),
    );
  }
}

class _BlocksList extends ConsumerWidget {
  const _BlocksList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync = ref.watch(adminBlocksProvider);
    final isProcessing = ref.watch(adminBlocksNotifierProvider);

    return blocksAsync.when(
      data: (blocks) {
        if (blocks.isEmpty) return const Center(child: Text('لا يوجد حظر حالياً'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: blocks.length,
          itemBuilder: (context, index) {
            final block = blocks[index];
            final customerName = block['customer']?['full_name'] ?? 'مجهول';
            final providerName = block['provider']?['full_name'] ?? 'مجهول';
            final expiresAt = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(block['expires_at']));
            
            final isExpired = DateTime.parse(block['expires_at']).isBefore(DateTime.now());

            return Card(
              color: isExpired ? Colors.grey.shade100 : Colors.red.shade50,
              child: ListTile(
                title: Text('حظر من: $customerName'),
                subtitle: Text('على المزود: $providerName\nينتهي في: $expiresAt ${isExpired ? "(منتهي)" : ""}'),
                isThreeLine: true,
                trailing: isProcessing 
                  ? const CircularProgressIndicator()
                  : IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'رفع الحظر',
                  onPressed: () async {
                    try {
                      await ref.read(adminBlocksNotifierProvider.notifier).removeBlock(block['id']);
                      ref.invalidate(adminBlocksProvider);
                      if (context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفع الحظر بنجاح')));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                    }
                  },
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('خطأ: $err')),
    );
  }
}

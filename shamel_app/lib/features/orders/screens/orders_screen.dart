import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/orders_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersStream = ref.watch(myOrdersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: const Text('الطلبات المنفذة والمفتوحة'),
      ),
      body: ordersStream.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('لا توجد طلبات حالياً', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final createdAt = order.createdAt;
              
              Color statusColor = Colors.blue;
              if (order.status == 'Completed') statusColor = Colors.green;
              if (order.status == 'Disputed') statusColor = Colors.red;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text('طلب #${order.id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('الإجمالي: ${order.price} د.ل', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 4),
                      Text(timeago.format(createdAt, locale: 'ar'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(order.status),
                    backgroundColor: statusColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: statusColor),
                  ),
                  onTap: () {
                    context.push('/order_details', extra: order);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
      ),
    );
  }
}

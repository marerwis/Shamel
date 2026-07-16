import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/requests_provider.dart';
import '../providers/commission_provider.dart';

class ProviderRequestsScreen extends ConsumerStatefulWidget {
  final String categoryId;
  const ProviderRequestsScreen({super.key, required this.categoryId});

  @override
  ConsumerState<ProviderRequestsScreen> createState() => _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState extends ConsumerState<ProviderRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    final requestsStream = ref.watch(providerRequestsProvider(widget.categoryId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات المتاحة للتقديم'),
      ),
      body: requestsStream.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(child: Text('لا يوجد طلبات متاحة حالياً في تخصصك.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final createdAt = DateTime.parse(req['created_at']);
              final timeAgoStr = timeago.format(createdAt, locale: 'ar');

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('طلب خدمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text(timeAgoStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        req['description'] ?? 'بدون وصف',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              context.push('/provider_accept_request', extra: req);
                            },
                            icon: const Icon(Icons.check_circle),
                            label: const Text('قبول وتقديم سعر'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      ),
    );
}

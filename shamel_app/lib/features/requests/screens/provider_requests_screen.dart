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

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(providerRequestsProvider(widget.categoryId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                final createdAtRaw = req['created_at'];
                final createdAt = createdAtRaw != null ? DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now() : DateTime.now();
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
                            Consumer(
                              builder: (context, ref, _) {
                                final isLoading = ref.watch(requestsProvider);
                                return ElevatedButton.icon(
                                  onPressed: isLoading ? null : () async {
                                    try {
                                      await ref.read(requestsProvider.notifier).acceptRequestDirectly(req['id']);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('تم قبول الطلب بنجاح!')),
                                        );
                                        context.go('/orders');
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(e.toString().replaceAll('Exception:', '').trim()), backgroundColor: Colors.red),
                                        );
                                      }
                                    }
                                  },
                                  icon: isLoading 
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Icon(Icons.check_circle),
                                  label: const Text('قبول الطلب'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      ),
    );
  }
}

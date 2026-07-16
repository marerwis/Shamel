import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/requests_provider.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(adminRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطلبات (Requests)'),
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(child: Text('لا يوجد طلبات حالياً'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final customerName = req['customer']?['full_name'] ?? 'مجهول';
              final categoryName = req['category']?['name'] ?? 'غير محدد';
              final createdAt = DateTime.parse(req['created_at']);
              final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(_getStatusIcon(req['status'])),
                    backgroundColor: _getStatusColor(req['status']).withOpacity(0.2),
                    foregroundColor: _getStatusColor(req['status']),
                  ),
                  title: Text('العميل: $customerName - $categoryName'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(req['description'] ?? 'بدون وصف', maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('الحالة: ${req['status']} • $formattedDate', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showRequestDetails(context, req);
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending_Broadcast': return Icons.podcasts;
      case 'Accepted': return Icons.check_circle;
      case 'Completed': return Icons.done_all;
      case 'Cancelled': return Icons.cancel;
      default: return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending_Broadcast': return Colors.orange;
      case 'Accepted': return Colors.blue;
      case 'Completed': return Colors.green;
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showRequestDetails(BuildContext context, Map<String, dynamic> req) {
    final images = (req['images'] as List?)?.cast<String>() ?? [];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تفاصيل الطلب', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              Text('وصف العميل:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(req['description'] ?? ''),
              const SizedBox(height: 16),
              
              if (images.isNotEmpty) ...[
                const Text('الصور المرفقة:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Image.network(images[i], width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // In the future, this is where we will fetch the providers who received this broadcast.
              const Text('سجل البث (Logs):', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('سيتم إضافة سجل المزودين الذين وصلهم الطلب لاحقاً.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
              const SizedBox(height: 32),
            ],
          ),
        );
      }
    );
  }
}

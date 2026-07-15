import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/disputes_provider.dart';

class DisputesManagementScreen extends ConsumerWidget {
  const DisputesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(disputesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'النزاعات والشكاوى',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
            ),
            OutlinedButton.icon(
              onPressed: () => ref.refresh(disputesProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        
        Expanded(
          child: asyncData.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
            data: (disputes) {
              if (disputes.isEmpty) {
                return const Center(child: Text('لا توجد نزاعات أو شكاوى حالياً'));
              }
              return _buildDisputesTable(context, ref, disputes);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDisputesTable(BuildContext context, WidgetRef ref, List<DisputeModel> disputes) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceContainerLow),
          dataRowMinHeight: 70,
          dataRowMaxHeight: 70,
          columns: const [
            DataColumn(label: Text('رقم الشكوى', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الموضوع', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('التاريخ', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: disputes.map((dispute) {
            Color statusColor;
            String statusText;
            switch(dispute.status) {
              case 'open': statusColor = Colors.red; statusText = 'مفتوح'; break;
              case 'under_review': statusColor = Colors.orange; statusText = 'قيد المراجعة'; break;
              case 'resolved': statusColor = Colors.green; statusText = 'محلول'; break;
              case 'closed': statusColor = Colors.grey; statusText = 'مغلق'; break;
              default: statusColor = Colors.grey; statusText = dispute.status;
            }

            return DataRow(
              cells: [
                DataCell(Text('#${dispute.id.substring(0, 8).toUpperCase()}')),
                DataCell(Text(dispute.reason, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                DataCell(Text(dispute.createdAt.toString().split(' ')[0])),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                )),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary), 
                      onPressed: () => _showDisputeDialog(context, ref, dispute),
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDisputeDialog(BuildContext context, WidgetRef ref, DisputeModel dispute) {
    String currentStatus = dispute.status;
    final notesController = TextEditingController(text: dispute.adminNotes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تفاصيل النزاع'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الطلب: #${dispute.orderId.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('السبب: ${dispute.reason}', maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(
                  'تاريخ النزاع: ${dispute.createdAt.toString().substring(0, 10)}',
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: currentStatus,
                  items: const [
                    DropdownMenuItem(value: 'Open', child: Text('مفتوح')),
                    DropdownMenuItem(value: 'Resolved_Customer', child: Text('لصالح العميل')),
                    DropdownMenuItem(value: 'Resolved_Provider', child: Text('لصالح المزود')),
                  ],
                  onChanged: (val) => setState(() => currentStatus = val!),
                  decoration: const InputDecoration(labelText: 'حالة الشكوى'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.from('disputes').update({
                  'status': currentStatus,
                }).eq('id', dispute.id);
                
                // If resolved, update order status as well
                if (currentStatus == 'Resolved_Customer' || currentStatus == 'Resolved_Provider') {
                    await Supabase.instance.client.from('orders').update({'status': 'Completed'}).eq('id', dispute.orderId);
                }

                ref.invalidate(disputesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('تحديث'),
            ),
          ],
        ),
      ),
    );
  }
}

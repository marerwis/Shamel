import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/orders_provider.dart';

class OrdersManagementScreen extends ConsumerWidget {
  const OrdersManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(ordersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'إدارة الطلبات',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
            ),
            OutlinedButton.icon(
              onPressed: () => ref.refresh(ordersProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        
        // Search & Filters
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'ابحث برقم الطلب...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  value: 'الكل',
                  items: ['الكل', 'جديد', 'مكتمل', 'ملغى'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {},
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Expanded(
          child: asyncData.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
            data: (orders) {
              if (orders.isEmpty) {
                return const Center(child: Text('لا توجد طلبات حتى الآن'));
              }
              return _buildOrdersTable(context, ref, orders);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTable(BuildContext context, WidgetRef ref, List<OrderModel> orders) {
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
            DataColumn(label: Text('رقم الطلب', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الأطراف', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الموعد المجدول', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('السعر', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: orders.map((order) {
            Color statusColor;
            String statusText;
            switch(order.status) {
              case 'pending': statusColor = Colors.orange; statusText = 'قيد الانتظار'; break;
              case 'accepted': statusColor = Colors.blue; statusText = 'مقبول'; break;
              case 'in_progress': statusColor = Colors.purple; statusText = 'قيد التنفيذ'; break;
              case 'completed': statusColor = Colors.green; statusText = 'مكتمل'; break;
              case 'cancelled': statusColor = Colors.red; statusText = 'ملغى'; break;
              default: statusColor = Colors.grey; statusText = order.status;
            }

            return DataRow(
              cells: [
                DataCell(Text('#${order.id.substring(0, 8).toUpperCase()}')),
                DataCell(Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('العميل: ${order.customerName ?? "غير معروف"}', style: const TextStyle(fontSize: 12)),
                    Text('المزود: ${order.providerName ?? "غير معين"}', style: const TextStyle(fontSize: 12)),
                  ],
                )),
                DataCell(Text(order.scheduledAt.toString().substring(0, 16))),
                DataCell(Text(order.price != null ? 'SAR ${order.price}' : 'غير محدد')),
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
                      onPressed: () => _showEditStatusDialog(context, ref, order),
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

  void _showEditStatusDialog(BuildContext context, WidgetRef ref, OrderModel order) {
    String currentStatus = order.status;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تغيير حالة الطلب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: currentStatus,
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('قيد الانتظار')),
                  DropdownMenuItem(value: 'accepted', child: Text('مقبول')),
                  DropdownMenuItem(value: 'in_progress', child: Text('قيد التنفيذ')),
                  DropdownMenuItem(value: 'completed', child: Text('مكتمل')),
                  DropdownMenuItem(value: 'cancelled', child: Text('ملغى')),
                ],
                onChanged: (val) => setState(() => currentStatus = val!),
                decoration: const InputDecoration(labelText: 'الحالة الجديدة'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.from('orders').update({
                  'status': currentStatus,
                }).eq('id', order.id);
                ref.invalidate(ordersProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

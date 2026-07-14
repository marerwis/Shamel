import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/finance_provider.dart';

class FinanceManagementScreen extends ConsumerWidget {
  const FinanceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(financeRequestsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المعاملات المالية وطلبات السحب',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
            ),
            OutlinedButton.icon(
              onPressed: () => ref.refresh(financeRequestsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        
        // Stats Cards
        Row(
          children: [
            Expanded(child: _buildFinanceCard(context, 'إجمالي الإيرادات', 'SAR 0.00', Icons.account_balance, AppColors.primary)),
            const SizedBox(width: 24),
            Expanded(child: _buildFinanceCard(context, 'أرباح المنصة (عمولة)', 'SAR 0.00', Icons.pie_chart, AppColors.secondary)),
            const SizedBox(width: 24),
            Expanded(child: _buildFinanceCard(context, 'مستحقات المزودين', 'SAR 0.00', Icons.payments, AppColors.tertiary)),
          ],
        ),
        const SizedBox(height: 32),
        
        Text(
          'طلبات السحب',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: requestsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
            data: (requests) {
              if (requests.isEmpty) {
                return const Center(child: Text('لا توجد طلبات سحب حالياً'));
              }
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.surfaceContainerLow),
                    columns: const [
                      DataColumn(label: Text('رقم الطلب', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('المزود', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('المبلغ', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('البنك / الحساب', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: requests.map((request) {
                      Color statusColor;
                      String statusText;
                      switch(request.status) {
                        case 'pending': statusColor = Colors.orange; statusText = 'قيد الانتظار'; break;
                        case 'approved': statusColor = Colors.green; statusText = 'مقبول'; break;
                        case 'rejected': statusColor = Colors.red; statusText = 'مرفوض'; break;
                        case 'completed': statusColor = Colors.blue; statusText = 'مكتمل'; break;
                        default: statusColor = Colors.grey; statusText = request.status;
                      }

                      return DataRow(
                        cells: [
                          DataCell(Text('#${request.id.substring(0, 8).toUpperCase()}')),
                          DataCell(Text(request.providerName ?? 'غير معروف')),
                          DataCell(Text('${request.amount} SAR', style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text('${request.bankName}\n${request.iban}', style: const TextStyle(fontSize: 12))),
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
                              if (request.status == 'pending') ...[
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => ref.read(financeRequestsProvider.notifier).updateRequestStatus(request.id, 'approved'),
                                  tooltip: 'قبول',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => ref.read(financeRequestsProvider.notifier).updateRequestStatus(request.id, 'rejected'),
                                  tooltip: 'رفض',
                                ),
                              ] else if (request.status == 'approved') ...[
                                IconButton(
                                  icon: const Icon(Icons.done_all, color: Colors.blue),
                                  onPressed: () => ref.read(financeRequestsProvider.notifier).updateRequestStatus(request.id, 'completed'),
                                  tooltip: 'تأكيد التحويل',
                                ),
                              ]
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

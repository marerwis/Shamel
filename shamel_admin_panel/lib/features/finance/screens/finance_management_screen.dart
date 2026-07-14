import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../members/providers/members_provider.dart';

class FinanceManagementScreen extends ConsumerWidget {
  const FinanceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(providersListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المعاملات المالية',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text('تصدير التقرير'),
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
          'محافظ المزودين',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: providersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
            data: (providers) {
              if (providers.isEmpty) {
                return const Center(child: Text('لا يوجد مزودين متاحين بعد'));
              }
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.surfaceContainerLow),
                  columns: const [
                    DataColumn(label: Text('المزود', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('الرصيد الكلي', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('الرصيد المتاح للسحب', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('حالة الحساب', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: providers.map((provider) {
                    // Status UI
                    Color statusColor = Colors.grey;
                    String statusText = provider.status;
                    if (provider.status == 'active') {
                      statusColor = Colors.green;
                      statusText = 'نشط';
                    } else if (provider.status == 'pending') {
                      statusColor = Colors.orange;
                      statusText = 'قيد الانتظار';
                    } else if (provider.status == 'suspended') {
                      statusColor = Colors.red;
                      statusText = 'موقوف';
                    }

                    return DataRow(
                      cells: [
                        DataCell(Text(provider.fullName ?? 'بدون اسم')),
                        const DataCell(Text('SAR 0.00')),
                        const DataCell(Text('SAR 0.00')),
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
                            TextButton(onPressed: () {}, child: const Text('تحويل أرباح')),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
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

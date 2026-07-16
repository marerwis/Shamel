import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showAddFundsDialog(context, ref),
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('شحن رصيد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => ref.refresh(financeRequestsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('تحديث'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        
        // Stats Cards
        Consumer(
          builder: (context, ref, child) {
            final adminWallet = ref.watch(adminWalletProvider);
            return Row(
              children: [
                Expanded(child: _buildFinanceCard(context, 'أرباح المنصة (عمولة)', adminWallet.when(data: (d) => '$d د.ل', loading: () => '...', error: (e,s) => 'خطأ'), Icons.account_balance, AppColors.primary)),
                const SizedBox(width: 24),
                Expanded(child: _buildFinanceCard(context, 'إجمالي الإيرادات', 'قريباً', Icons.pie_chart, AppColors.secondary)),
                const SizedBox(width: 24),
                Expanded(child: _buildFinanceCard(context, 'مستحقات المزودين', 'قريباً', Icons.payments, AppColors.tertiary)),
              ],
            );
          }
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
                        case 'Pending': statusColor = Colors.orange; statusText = 'قيد الانتظار'; break;
                        case 'Approved': statusColor = Colors.green; statusText = 'مقبول / محول'; break;
                        case 'Rejected': statusColor = Colors.red; statusText = 'مرفوض'; break;
                        default: statusColor = Colors.grey; statusText = request.status;
                      }

                      return DataRow(
                        cells: [
                          DataCell(Text('#${request.id.substring(0, 8).toUpperCase()}')),
                          DataCell(Text(request.providerName ?? 'غير معروف')),
                          DataCell(Text('${request.amount} د.ل', style: const TextStyle(fontWeight: FontWeight.bold))),
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
                              if (request.status == 'Pending') ...[
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => ref.read(financeRequestsProvider.notifier).updateRequestStatus(request.id, 'approved'),
                                  tooltip: 'قبول وتأكيد التحويل',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => ref.read(financeRequestsProvider.notifier).updateRequestStatus(request.id, 'rejected'),
                                  tooltip: 'رفض (إرجاع الرصيد للمزود)',
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

  Widget _buildFinanceCard(BuildContext context, String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
              Icon(icon, color: color, size: 32),
            ],
          ),
          const SizedBox(height: 16),
          Text(amount, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAddFundsDialog(BuildContext context, WidgetRef ref) {
    final emailCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: AppColors.secondary),
                SizedBox(width: 8),
                Text('شحن رصيد مستخدم'),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني للمستخدم',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'المبلغ (د.ل)',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        final amount = double.tryParse(amountCtrl.text.trim());
                        if (emailCtrl.text.isEmpty || amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('الرجاء إدخال بريد إلكتروني صالح ومبلغ صحيح')),
                          );
                          return;
                        }
                        
                        setState(() => isLoading = true);
                        try {
                          await Supabase.instance.client.rpc('admin_add_funds_by_email', params: {
                            'target_email': emailCtrl.text.trim(),
                            'amount_to_add': amount,
                          });
                          
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text('تم شحن رصيد ${emailCtrl.text} بمبلغ $amount بنجاح!'),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('خطأ: $e')),
                            );
                          }
                        } finally {
                          if (ctx.mounted) {
                            setState(() => isLoading = false);
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('إضافة الرصيد'),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class WithdrawalRequestScreen extends StatefulWidget {
  const WithdrawalRequestScreen({super.key});

  @override
  State<WithdrawalRequestScreen> createState() => _WithdrawalRequestScreenState();
}

class _WithdrawalRequestScreenState extends State<WithdrawalRequestScreen> {
  String _selectedMethod = 'bank';
  final TextEditingController _amountController = TextEditingController(text: '500');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
          color: AppColors.onSurfaceVariant,
        ),
        title: const Text('سحب الأموال', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Text('الرصيد المتاح للسحب', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primaryFixedDim)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('12,450.00', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text('ر.س', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primaryFixedDim)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Amount Input
            Text('المبلغ المراد سحبه', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                suffixText: 'ر.س',
                suffixStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              ),
            ),
            const SizedBox(height: 32),

            // Withdrawal Methods
            Text('طريقة السحب', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildMethodOption(
              value: 'bank',
              title: 'حساب بنكي مرتبط',
              subtitle: 'مصرف الراجحي **** 4321',
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 12),
            _buildMethodOption(
              value: 'stc',
              title: 'STC Pay',
              subtitle: 'رقم الجوال **** 055',
              icon: Icons.payments,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('إضافة طريقة سحب جديدة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.outline),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 32),

            // Summary Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ملخص العملية', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildSummaryRow('المبلغ المسحوب', '${_amountController.text.isEmpty ? "0.00" : _amountController.text}.00 ر.س', false),
                  const SizedBox(height: 12),
                  _buildSummaryRow('رسوم التحويل', '0.00 ر.س', false),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: AppColors.outlineVariant),
                  ),
                  _buildSummaryRow('إجمالي المبلغ المستلم', '${_amountController.text.isEmpty ? "0.00" : _amountController.text}.00 ر.س', true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Terms and Notes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info, color: AppColors.onSurfaceVariant, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'عادة ما تستغرق عمليات السحب إلى الحسابات البنكية من 1 إلى 3 أيام عمل. السحب إلى المحافظ الإلكترونية يتم بشكل فوري. بتأكيدك للعملية، أنت توافق على شروط وأحكام الخدمة.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم استلام طلب السحب الخاص بك بنجاح!'), backgroundColor: Colors.green),
                  );
                  context.pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('تأكيد السحب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer.withOpacity(0.1) : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outlineVariant, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.outline, width: 2),
                shape: BoxShape.circle,
              ),
              child: isSelected ? const Icon(Icons.check, color: AppColors.onPrimary, size: 16) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              : Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        Text(
          value,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)
              : Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

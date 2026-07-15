import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../providers/wallet_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              color: AppColors.primary,
            );
          }
        ),
        title: const Text('المحفظة', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              context.push('/notifications');
            },
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: walletAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
        data: (wallet) {
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(walletProvider.future),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Balance Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('الرصيد المتاح', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onPrimary.withOpacity(0.8))),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${wallet.balance}', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Text('د.ل', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onPrimary.withOpacity(0.8))),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.account_balance_wallet, color: AppColors.onPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Add funds
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شحن الرصيد غير مفعل حالياً')));
                                },
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text('شحن الرصيد'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: AppColors.onSecondary,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  context.push('/withdraw');
                                },
                                icon: const Icon(Icons.arrow_downward, size: 20),
                                label: const Text('سحب'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.onPrimary,
                                  side: const BorderSide(color: AppColors.onPrimary),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Row(
                    children: [
                      Expanded(child: _buildQuickActionCard(context, Icons.send, 'إرسال أموال')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildQuickActionCard(context, Icons.request_quote, 'طلب أموال')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildQuickActionCard(context, Icons.receipt, 'دفع فواتير')),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Transaction History
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('المعاملات الأخيرة', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                      if (wallet.transactions.length > 5)
                        TextButton(
                          onPressed: () {},
                          child: const Text('عرض الكل', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (wallet.transactions.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('لا توجد معاملات بعد', style: TextStyle(color: AppColors.onSurfaceVariant))))
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: wallet.transactions.take(5).length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final tx = wallet.transactions[index];
                          final isCredit = tx.type == 'credit';
                          return _buildTransactionItem(
                            context,
                            title: tx.description,
                            date: timeago.format(tx.createdAt, locale: 'ar'),
                            amount: '${isCredit ? '+' : '-'} ${tx.amount} د.ل',
                            isPositive: isCredit,
                            status: 'مكتمل',
                            icon: isCredit ? Icons.add_card : Icons.payment,
                            iconBg: isCredit ? AppColors.secondaryContainer : AppColors.errorContainer,
                            iconColor: isCredit ? AppColors.onSecondaryContainer : AppColors.onErrorContainer,
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, IconData icon, String title) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً')));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.onPrimaryContainer),
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required String title,
    required String date,
    required String amount,
    required bool isPositive,
    required String status,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                const SizedBox(height: 4),
                Text(date, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPositive ? AppColors.secondary : AppColors.error,
                    ),
              ),
              const SizedBox(height: 4),
              Text(status, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.outline)),
            ],
          ),
        ],
      ),
    );
  }
}

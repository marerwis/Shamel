import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../services/notification_service.dart';

class MainLayoutScreen extends ConsumerWidget {
  final Widget child;
  
  const MainLayoutScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final isProvider = profileAsync.value?['role'] == 'provider';
    final pDetailsRaw = profileAsync.value?['provider_details'];
    String? categoryId;
    if (isProvider && pDetailsRaw != null) {
      if (pDetailsRaw is List && pDetailsRaw.isNotEmpty) {
        categoryId = pDetailsRaw[0]['category_id'];
      } else if (pDetailsRaw is Map) {
        categoryId = pDetailsRaw['category_id'];
      }
    }

    // Listen to provider category requests for local notifications
    ref.listen(userProfileProvider, (previous, next) {
      final pRole = next.value?['role'];
      if (pRole == 'provider') {
        final detailsRaw = next.value?['provider_details'];
        String? cId;
        if (detailsRaw is List && detailsRaw.isNotEmpty) {
          cId = detailsRaw[0]['category_id'];
        } else if (detailsRaw is Map) {
          cId = detailsRaw['category_id'];
        }
        if (cId != null) {
          ref.read(notificationServiceProvider).init();
          ref.read(notificationServiceProvider).startListeningToRequests(cId);
        }
      } else {
        ref.read(notificationServiceProvider).stopListening();
      }
    });

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _calculateSelectedIndex(context),
          onDestinationSelected: (int index) => _onItemTapped(index, context, isProvider),
          backgroundColor: AppColors.surface,
          elevation: 0,
          indicatorColor: AppColors.primaryContainer,
          destinations: isProvider 
          ? const [
              NavigationDestination(
                icon: Icon(Icons.work_outline),
                selectedIcon: Icon(Icons.work, color: AppColors.onPrimaryContainer),
                label: 'الطلبات المتاحة',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long, color: AppColors.onPrimaryContainer),
                label: 'طلباتي النشطة',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.onPrimaryContainer),
                label: 'المحفظة',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.onPrimaryContainer),
                label: 'حسابي',
              ),
            ]
          : const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppColors.onPrimaryContainer),
                label: 'الرئيسية',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long, color: AppColors.onPrimaryContainer),
                label: 'طلباتي',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.onPrimaryContainer),
                label: 'المحفظة',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.onPrimaryContainer),
                label: 'حسابي',
              ),
            ],
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/orders')) return 1;
    if (location.startsWith('/wallet')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, bool isProvider) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/orders');
        break;
      case 2:
        context.go('/wallet');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}

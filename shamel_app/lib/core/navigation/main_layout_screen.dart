import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class MainLayoutScreen extends StatelessWidget {
  final Widget child;
  
  const MainLayoutScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
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
          onDestinationSelected: (int index) => _onItemTapped(index, context),
          backgroundColor: AppColors.surface,
          elevation: 0,
          indicatorColor: AppColors.primaryContainer,
          destinations: const [
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

  void _onItemTapped(int index, BuildContext context) {
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

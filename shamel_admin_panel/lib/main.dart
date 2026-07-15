import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';

import 'core/layouts/admin_layout.dart';
import 'features/auth/screens/admin_login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/services/screens/services_management_screen.dart';
import 'features/promotions/screens/promotions_management_screen.dart';
import 'features/disputes/screens/disputes_management_screen.dart';
import 'features/members/screens/members_management_screen.dart';
import 'features/providers/screens/providers_management_screen.dart';
import 'features/orders/screens/orders_management_screen.dart';
import 'features/finance/screens/finance_management_screen.dart';
import 'features/categories/screens/categories_management_screen.dart';
import 'features/requests/screens/requests_screen.dart';
import 'features/requests/screens/bids_blocks_screen.dart';
import 'features/settings/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const ProviderScope(child: AdminPanelApp()));
}
// Create a custom listenable for GoRouter to refresh on auth changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  // Use the listenable instead of ref.watch so the GoRouter instance doesn't get recreated
  final refreshNotifier = GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange);
  
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isAuth = Supabase.instance.client.auth.currentUser != null;
      final isLogin = state.uri.path == '/login';

      if (!isAuth && !isLogin) {
        return '/login';
      }

      if (isAuth && isLogin) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/services',
            builder: (context, state) => const ServicesManagementScreen(),
          ),
          GoRoute(
            path: '/promotions',
            builder: (context, state) => const PromotionsManagementScreen(),
          ),
          GoRoute(
            path: '/disputes',
            builder: (context, state) => const DisputesManagementScreen(),
          ),
          GoRoute(
            path: '/members',
            builder: (context, state) => const MembersManagementScreen(),
          ),
          GoRoute(
            path: '/providers',
            builder: (context, state) => const ProvidersManagementScreen(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrdersManagementScreen(),
          ),
          GoRoute(
            path: '/finance',
            builder: (context, state) => const FinanceManagementScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/categories',
            builder: (context, state) => const CategoriesManagementScreen(),
          ),
          GoRoute(
            path: '/requests',
            builder: (context, state) => const RequestsScreen(),
          ),
          GoRoute(
            path: '/bids_blocks',
            builder: (context, state) => const BidsBlocksScreen(),
          ),
        ],
      ),
    ],
  );
});

class AdminPanelApp extends ConsumerWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Shamel Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}

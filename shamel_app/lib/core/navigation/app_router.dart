import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';

// Navigation Layout
import 'main_layout_screen.dart';

// Auth
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';

// Home
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/provider_profile_screen.dart';
import '../../features/home/screens/category_providers_screen.dart';
import '../../features/home/screens/notifications_screen.dart';

// Orders
import '../../features/orders/screens/my_orders_screen.dart';
import '../../features/orders/screens/order_details_screen.dart';
import '../../features/orders/screens/order_edit_review_screen.dart';
import '../../features/orders/screens/service_rating_screen.dart';
import '../../features/orders/screens/booking_screen.dart';
import '../../features/home/providers/services_provider.dart';

// Categories
import '../../features/categories/screens/category_details_screen.dart';
import '../../features/categories/models/category_model.dart';

// Providers
import '../../features/providers/screens/providers_list_screen.dart';

// Wallet
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/wallet/screens/withdrawal_request_screen.dart';

// Profile
import '../../features/profile/screens/account_settings_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';

// Chat
import '../../features/chat/screens/messages_list_screen.dart';
import '../../features/chat/screens/live_chat_screen.dart';
import '../../features/chat/screens/chat_quote_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: AppRouter.rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.value?.session != null;
      final isSplash = state.uri.path == '/';
      final isLogin = state.uri.path == '/login';
      final isSignup = state.uri.path == '/signup';

      if (isSplash) return null; // Let splash screen handle itself (or redirect here)

      if (!isAuth && !isLogin && !isSignup) {
        return '/login';
      }

      if (isAuth && (isLogin || isSignup || isSplash)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      
      // Standalone full-screen routes (no bottom nav)
      GoRoute(
        path: '/provider/:id',
        name: 'provider_profile',
        builder: (context, state) => const ProviderProfileScreen(),
      ),
      GoRoute(
        path: '/category/:name',
        name: 'category_providers',
        builder: (context, state) => CategoryProvidersScreen(
          categoryName: state.pathParameters['name'] ?? 'مزودي الخدمة',
        ),
      ),
      GoRoute(
        path: '/booking',
        name: 'booking',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BookingScreen(
            service: extra?['service'] as ServiceModel?,
            provider: extra?['provider'] as Map<String, dynamic>?,
          );
        },
      ),
      GoRoute(
        path: '/category_details',
        name: 'category_details',
        builder: (context, state) {
          final category = state.extra as CategoryModel;
          return CategoryDetailsScreen(category: category);
        },
      ),
      GoRoute(
        path: '/providers_list',
        name: 'providers_list',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ProvidersListScreen(
            categoryId: extra?['categoryId'] as String?,
            categoryName: extra?['categoryName'] as String? ?? 'مزودي الخدمة',
          );
        },
      ),
      GoRoute(
        path: '/order_details/:id',
        name: 'order_details',
        builder: (context, state) {
          final order = state.extra as OrderModel?;
          return OrderDetailsScreen(order: order);
        },
      ),
      GoRoute(
        path: '/order_edit/:id',
        name: 'order_edit',
        builder: (context, state) => const OrderEditReviewScreen(),
      ),
      GoRoute(
        path: '/service_rating/:id',
        name: 'service_rating',
        builder: (context, state) => const ServiceRatingScreen(),
      ),
      GoRoute(
        path: '/withdraw',
        name: 'withdraw',
        builder: (context, state) => const WithdrawalRequestScreen(),
      ),
      GoRoute(
        path: '/live_chat/:id',
        name: 'live_chat',
        builder: (context, state) {
          final chatId = state.pathParameters['id']!;
          return LiveChatScreen(chatId: chatId);
        },
      ),
      GoRoute(
        path: '/chat_quote',
        name: 'chat_quote',
        builder: (context, state) => const ChatQuoteScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/edit_profile',
        name: 'edit_profile',
        builder: (context, state) => const EditProfileScreen(),
      ),

      // ShellRoute for tabs with BottomNavigationBar
      ShellRoute(
        navigatorKey: AppRouter.shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayoutScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/orders',
            name: 'orders',
            pageBuilder: (context, state) => const NoTransitionPage(child: MyOrdersScreen()),
          ),
          GoRoute(
            path: '/wallet',
            name: 'wallet',
            pageBuilder: (context, state) => const NoTransitionPage(child: WalletScreen()),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: AccountSettingsScreen()),
          ),
          // Chat list is also often a root level or accessed from profile/home, let's make it accessible
          GoRoute(
            path: '/messages',
            name: 'messages',
            pageBuilder: (context, state) => const NoTransitionPage(child: MessagesListScreen()),
          ),
        ],
      ),
    ],
  );
});

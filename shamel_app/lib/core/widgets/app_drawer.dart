import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Drawer(
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.onPrimaryContainer, width: 2),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.email ?? 'مستخدم ضيف',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  user?.phone ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: AppColors.primary),
            title: const Text('الرئيسية'),
            onTap: () {
              context.pop();
              context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.primary),
            title: const Text('حسابي'),
            onTap: () {
              context.pop();
              context.go('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.primary),
            title: const Text('الإعدادات'),
            onTap: () {
              context.pop();
              context.go('/profile');
            },
          ),
          const Divider(color: AppColors.surfaceVariant),
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.primary),
            title: const Text('المساعدة والدعم'),
            onTap: () {
              context.pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
            onTap: () async {
              context.pop();
              await ref.read(authControllerProvider).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

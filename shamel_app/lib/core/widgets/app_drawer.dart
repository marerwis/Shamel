import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
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
            child: profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Center(child: Text('خطأ في تحميل البيانات')),
              data: (profile) {
                final firstName = profile?['first_name'] ?? '';
                final lastName = profile?['last_name'] ?? '';
                final fullName = (firstName.isEmpty && lastName.isEmpty) ? 'مستخدم ضيف' : '$firstName $lastName';
                final avatarUrl = profile?['avatar_url'];
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.onPrimaryContainer, width: 2),
                        color: AppColors.surfaceContainerHigh,
                        image: avatarUrl != null && avatarUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(avatarUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (avatarUrl == null || avatarUrl.isEmpty)
                          ? const Icon(Icons.person, color: AppColors.outline, size: 30)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (user?.email != null)
                      Text(
                        user!.email!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onPrimaryContainer.withValues(alpha: 0.8),
                            ),
                      ),
                  ],
                );
              },
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

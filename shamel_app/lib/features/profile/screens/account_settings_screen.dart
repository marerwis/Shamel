import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../auth/providers/auth_provider.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final File file = File(image.path);
      final fileExtension = image.path.split('.').last;
      final fileName = '${user.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // Upload to Supabase Storage 'avatars' bucket
      await Supabase.instance.client.storage
          .from('avatars')
          .upload(fileName, file);

      // Get public URL
      final String publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Update profiles table
      await Supabase.instance.client
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', user.id);

      // Refresh profile data
      ref.invalidate(userProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الصورة الشخصية بنجاح!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء رفع الصورة: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              color: AppColors.onSurfaceVariant,
            );
          }
        ),
        title: const Text('حسابي', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('حدث خطأ في جلب البيانات: $err')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('الرجاء تسجيل الدخول'));
          }

          final firstName = profile['first_name'] ?? '';
          final lastName = profile['last_name'] ?? '';
          final phone = profile['phone'] ?? '';
          final avatarUrl = profile['avatar_url'];
          
          String? jobTitle;
          if (profile['provider_details'] != null && (profile['provider_details'] as List).isNotEmpty) {
             jobTitle = profile['provider_details'][0]['title'];
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceVariant),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.surfaceContainerLow, width: 4),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                              ],
                              color: AppColors.surfaceContainerHigh,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: avatarUrl != null && avatarUrl.isNotEmpty
                                ? Image.network(avatarUrl, fit: BoxFit.cover)
                                : const Icon(Icons.person, size: 48, color: AppColors.outline),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: InkWell(
                              onTap: _isUploading ? null : _pickAndUploadImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.surface, width: 2),
                                ),
                                child: _isUploading 
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Icon(Icons.camera_alt, color: AppColors.onPrimary, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('$firstName $lastName', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      if (jobTitle != null && jobTitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(jobTitle, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(phone, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.outline), textDirection: TextDirection.ltr),
                      if (user?.email != null) ...[
                        const SizedBox(height: 4),
                        Text(user!.email!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.outline)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Settings List
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context, 'إعدادات الحساب'),
                      _buildSettingsTile(
                        context,
                        title: 'تعديل البيانات الشخصية',
                        icon: Icons.person_outline,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primaryFixed.withOpacity(0.2),
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        context,
                        title: 'عناويننا المحفوظة',
                        icon: Icons.location_on,
                        iconColor: AppColors.secondary,
                        iconBg: AppColors.secondaryFixed.withOpacity(0.2),
                      ),
                      
                      _buildSectionHeader(context, 'الأمان والتفضيلات'),
                      _buildSettingsTile(
                        context,
                        title: 'التنبيهات',
                        icon: Icons.notifications_active,
                        iconColor: AppColors.onSurfaceVariant,
                        iconBg: AppColors.surfaceVariant,
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        context,
                        title: 'اللغة',
                        subtitle: 'العربية',
                        icon: Icons.language,
                        iconColor: AppColors.onSurfaceVariant,
                        iconBg: AppColors.surfaceVariant,
                        hideDivider: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authControllerProvider).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('تسجيل الخروج'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.errorContainer),
                      backgroundColor: AppColors.errorContainer.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: AppColors.surfaceVariant), top: BorderSide(color: AppColors.surfaceVariant)),
      ),
      child: Text(title, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    bool hideDivider = false,
  }) {
    return InkWell(
      onTap: () {
        if (title == 'تعديل البيانات الشخصية') {
          context.push('/edit_profile');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('هذه الميزة ستتوفر قريباً')),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.outline)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}

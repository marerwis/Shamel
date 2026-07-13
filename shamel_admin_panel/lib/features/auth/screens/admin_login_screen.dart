import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'الرجاء إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Sign in with Supabase
      await ref.read(authControllerProvider).login(email, password);
      
      // 2. Fetch the user's role to ensure they are an admin
      final role = await ref.refresh(userRoleProvider.future);
      
      if (role != 'admin' && role != 'super_admin') {
        // Not an admin, sign out immediately
        await ref.read(authControllerProvider).logout();
        setState(() => _errorMessage = 'عذراً، هذا الحساب لا يملك صلاحيات الإدارة.');
        return;
      }

      // Success, GoRouter will automatically redirect to /dashboard because of authState changes,
      // but we can manually push it to be safe
      if (mounted) {
        context.go('/dashboard');
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = 'بيانات الدخول غير صحيحة');
    } catch (e) {
      setState(() => _errorMessage = 'حدث خطأ غير متوقع: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Row(
        children: [
          // Left side: Graphic/Branding
          Expanded(
            flex: 5,
            child: Container(
              color: AppColors.primary,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: -100,
                    right: -100,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -50,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary.withOpacity(0.2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(60.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield, size: 80, color: Colors.white),
                        const SizedBox(height: 24),
                        Text(
                          'نظام إدارة شامل',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'تحكم كامل في المنصة، إدارة المزودين، تتبع الطلبات، ومتابعة الإيرادات من مكان واحد.',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Right side: Login Form
          Expanded(
            flex: 4,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تسجيل دخول الإدارة',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أدخل بيانات الاعتماد للوصول إلى لوحة التحكم',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 40),
                    
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Email Field
                    Text(
                      'البريد الإلكتروني',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'admin@shamel.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.outlineVariant),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Password Field
                    Text(
                      'كلمة المرور',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.outlineVariant),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading 
                            ? const SizedBox(
                                width: 24, height: 24, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : const Text('تسجيل الدخول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

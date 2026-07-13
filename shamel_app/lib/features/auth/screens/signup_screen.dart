import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isObscure = true;
  String _selectedRole = 'user';

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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo / Header
            const Icon(Icons.home_repair_service, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('إنشاء حساب جديد', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('سجل الآن لتستفيد من جميع خدماتنا', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: 32),

            // Role Selection
            Row(
              children: [
                Expanded(
                  child: _buildRoleCard(
                    title: 'مستخدم',
                    icon: Icons.person,
                    value: 'user',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRoleCard(
                    title: 'مزود خدمة',
                    icon: Icons.handyman,
                    value: 'provider',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Form
            _buildTextField(label: 'الاسم الكامل', icon: Icons.person_outline, keyboardType: TextInputType.name),
            const SizedBox(height: 16),
            _buildTextField(label: 'رقم الجوال', icon: Icons.phone_android, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField(label: 'البريد الإلكتروني (اختياري)', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'كلمة المرور',
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 32),

            // Submit
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('إنشاء الحساب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 24),
            
            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('لديك حساب بالفعل؟', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                TextButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    }
                  },
                  child: const Text('تسجيل الدخول', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({required String title, required IconData icon, required String value}) {
    final isSelected = _selectedRole == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outlineVariant, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword ? _isObscure : false,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.outline),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: AppColors.outline),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
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
          ),
        ),
      ],
    );
  }
}

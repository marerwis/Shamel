import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../../categories/providers/categories_provider.dart';
import '../../categories/models/category_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isObscure = true;
  String _selectedRole = 'user';
  String _selectedIdType = 'national_id'; // default
  String? _selectedCategoryId;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Provider Specific Controllers
  final _fatherNameController = TextEditingController();
  final _grandfatherNameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _titleController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fatherNameController.dispose();
    _grandfatherNameController.dispose();
    _idNumberController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال البريد الإلكتروني (مطلوب حالياً)')),
      );
      return;
    }

    if (_selectedRole == 'provider' && _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار تصنيف الخدمة')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authController = ref.read(authControllerProvider);
      await authController.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        fatherName: _selectedRole == 'provider' ? _fatherNameController.text.trim() : null,
        grandfatherName: _selectedRole == 'provider' ? _grandfatherNameController.text.trim() : null,
        idType: _selectedRole == 'provider' ? _selectedIdType : null,
        idNumber: _selectedRole == 'provider' ? _idNumberController.text.trim() : null,
        categoryId: _selectedRole == 'provider' ? _selectedCategoryId : null,
        title: _selectedRole == 'provider' ? _titleController.text.trim() : null,
      );

      if (mounted) {
        if (_selectedRole == 'provider') {
          _showProviderSuccessDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء الحساب بنجاح!')),
          );
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showProviderSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        content: const Text(
          'تم تسجيل طلبك كمزود خدمة بنجاح!\n\nسيتم مراجعة طلبك من قبل الإدارة، ولن يتم تفعيل حسابك كلياً إلا بعد الموافقة.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/home');
              },
              child: const Text('حسناً، فهمت'),
            ),
          ),
        ],
      ),
    );
  }

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
        child: Form(
          key: _formKey,
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
              
              if (_selectedRole == 'provider') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'تنويه: سيتم مراجعة طلبك من قبل الإدارة قبل الموافقة عليه.',
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 32),

              // Basic Info Form
              _buildTextField(label: 'الاسم الأول (أو الكامل)', icon: Icons.person_outline, keyboardType: TextInputType.name, controller: _nameController),
              
              // Provider Specific Info
              if (_selectedRole == 'provider') ...[
                const SizedBox(height: 16),
                _buildTextField(label: 'اسم الأب', icon: Icons.person_outline, controller: _fatherNameController),
                const SizedBox(height: 16),
                _buildTextField(label: 'اسم الجد', icon: Icons.person_outline, controller: _grandfatherNameController),
                const SizedBox(height: 16),
                _buildTextField(label: 'المسمى الوظيفي (مثال: طبيب، سباك، نجار)', icon: Icons.work_outline, controller: _titleController),
                const SizedBox(height: 16),
                Text('نوع الهوية', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('بطاقة هوية'),
                        value: 'national_id',
                        groupValue: _selectedIdType,
                        onChanged: (val) => setState(() => _selectedIdType = val!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('جواز سفر'),
                        value: 'passport',
                        groupValue: _selectedIdType,
                        onChanged: (val) => setState(() => _selectedIdType = val!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: _selectedIdType == 'passport' ? 'رقم جواز السفر' : 'رقم الهوية', 
                  icon: Icons.badge_outlined, 
                  controller: _idNumberController,
                ),
                const SizedBox(height: 16),
                Text('تصنيف الخدمة', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                _buildCategoryDropdown(),
              ],

              const SizedBox(height: 16),
              _buildTextField(label: 'رقم الجوال', icon: Icons.phone_android, keyboardType: TextInputType.phone, controller: _phoneController),
              const SizedBox(height: 16),
              _buildTextField(label: 'البريد الإلكتروني', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, controller: _emailController),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'كلمة المرور',
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 32),

              // Submit
              Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleSignUp(ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('إنشاء الحساب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  );
                }
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
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer(
      builder: (context, ref, child) {
        final asyncCats = ref.watch(allCategoriesProvider);
        
        return asyncCats.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('خطأ في جلب التصنيفات', style: TextStyle(color: Colors.red)),
          data: (categories) {
            return DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                prefixIcon: const Icon(Icons.category_outlined, color: AppColors.outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              hint: const Text('اختر التصنيف (مثال: الطب)'),
              value: _selectedCategoryId,
              items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (val) {
                setState(() => _selectedCategoryId = val);
              },
              validator: (value) {
                if (_selectedRole == 'provider' && (value == null || value.isEmpty)) {
                  return 'الرجاء اختيار تصنيف';
                }
                return null;
              },
            );
          },
        );
      },
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
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? _isObscure : false,
          keyboardType: keyboardType,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'هذا الحقل مطلوب';
            }
            return null;
          },
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

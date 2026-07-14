import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../members/providers/members_provider.dart';

class ProvidersManagementScreen extends ConsumerStatefulWidget {
  const ProvidersManagementScreen({super.key});

  @override
  ConsumerState<ProvidersManagementScreen> createState() => _ProvidersManagementScreenState();
}

class _ProvidersManagementScreenState extends ConsumerState<ProvidersManagementScreen> {
  String _searchQuery = '';
  String _statusFilter = 'الكل';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إدارة مزودي الخدمة',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
        ),
        const SizedBox(height: 32),
        
        // Search & Filters
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'ابحث بالاسم أو المسمى الوظيفي...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  value: _statusFilter,
                  items: ['الكل', 'active', 'pending', 'suspended'].map((e) {
                    String label = e;
                    if (e == 'الكل') label = 'الكل';
                    if (e == 'active') label = 'نشط';
                    if (e == 'pending') label = 'قيد الانتظار / المراجعة';
                    if (e == 'suspended') label = 'موقوف';
                    return DropdownMenuItem(value: e, child: Text(label));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _statusFilter = val ?? 'الكل';
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // List
        Expanded(
          child: _buildProvidersList(),
        ),
      ],
    );
  }

  Widget _buildProvidersList() {
    final asyncData = ref.watch(providersListProvider);
    
    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('حدث خطأ: $err', style: const TextStyle(color: Colors.red))),
      data: (providers) {
        // Filter by search
        var filtered = providers.where((p) {
          final matchName = (p.fullName ?? '').toLowerCase().contains(_searchQuery);
          final matchTitle = (p.title ?? '').toLowerCase().contains(_searchQuery);
          return matchName || matchTitle;
        }).toList();

        // Filter by status
        if (_statusFilter != 'الكل') {
          filtered = filtered.where((p) => p.status == _statusFilter).toList();
        }

        if (filtered.isEmpty) {
          return const Center(child: Text('لا توجد بيانات مطابقة للبحث'));
        }
        
        return _buildProvidersTable(filtered);
      },
    );
  }

  Widget _buildProvidersTable(List<MemberModel> providers) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceContainerLow),
          dataRowMinHeight: 70,
          dataRowMaxHeight: 70,
          columns: const [
            DataColumn(label: Text('مزود الخدمة', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('المسمى الوظيفي', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('رقم الهاتف', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: providers.map((provider) {
            
            // Status UI
            Color statusColor = Colors.grey;
            String statusText = provider.status;
            if (provider.status == 'active') {
              statusColor = Colors.green;
              statusText = 'نشط';
            } else if (provider.status == 'pending') {
              statusColor = Colors.orange;
              statusText = 'بانتظار المراجعة';
            } else if (provider.status == 'suspended') {
              statusColor = Colors.red;
              statusText = 'موقوف';
            }

            final initial = (provider.fullName != null && provider.fullName!.isNotEmpty) 
                ? provider.fullName![0].toUpperCase() : '?';

            return DataRow(
              cells: [
                DataCell(Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryContainer,
                      backgroundImage: provider.avatarUrl != null ? NetworkImage(provider.avatarUrl!) : null,
                      child: provider.avatarUrl == null ? Text(
                        initial, 
                        style: const TextStyle(color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),
                      ) : null,
                    ),
                    const SizedBox(width: 12),
                    Text(provider.fullName ?? 'بدون اسم', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )),
                DataCell(Text(provider.title ?? 'غير محدد')),
                DataCell(Text(provider.phone ?? 'غير متوفر')),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                )),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye, color: AppColors.primary),
                      tooltip: 'عرض التفاصيل',
                      onPressed: () => _showProviderDetails(context, provider),
                    ),
                    
                    if (provider.status == 'pending') 
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: 'قبول وتفعيل',
                        onPressed: () => _updateStatus(context, provider.id, 'active'),
                      ),
                    
                    if (provider.status != 'suspended')
                      IconButton(
                        icon: const Icon(Icons.block, color: Colors.red),
                        tooltip: 'إيقاف مؤقت',
                        onPressed: () => _updateStatus(context, provider.id, 'suspended'),
                      ),

                    if (provider.status == 'suspended')
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.blue),
                        tooltip: 'استعادة',
                        onPressed: () => _updateStatus(context, provider.id, 'active'),
                      ),
                      
                    IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'حذف المزود',
                        onPressed: () => _deleteProvider(context, provider.id),
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showProviderDetails(BuildContext context, MemberModel provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تفاصيل مزود الخدمة', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('الاسم الكامل'),
                subtitle: Text(provider.fullName ?? 'غير متوفر'),
              ),
              ListTile(
                leading: const Icon(Icons.family_restroom),
                title: const Text('اسم الأب'),
                subtitle: Text(provider.fatherName ?? 'غير متوفر'),
              ),
              ListTile(
                leading: const Icon(Icons.elderly),
                title: const Text('اسم الجد'),
                subtitle: Text(provider.grandfatherName ?? 'غير متوفر'),
              ),
              ListTile(
                leading: const Icon(Icons.badge),
                title: Text(provider.idType == 'passport' ? 'رقم الجواز' : 'رقم الهوية'),
                subtitle: Text(provider.idNumber ?? 'غير متوفر'),
              ),
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text('المسمى الوظيفي'),
                subtitle: Text(provider.title ?? 'غير متوفر'),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('رقم الجوال'),
                subtitle: Text(provider.phone ?? 'غير متوفر'),
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('تاريخ التسجيل'),
                subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(provider.createdAt)),
              ),
            ],
          ),
        ),
        actions: [
          if (provider.status == 'pending')
             ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('موافقة وتفعيل'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref.read(membersProvider.notifier).updateMemberStatus(provider.id, 'active');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تفعيل مزود الخدمة')));
                  }
                },
             ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _updateStatus(BuildContext context, String id, String newStatus) {
    String actionName = '';
    if (newStatus == 'active') actionName = 'تفعيل هذا الحساب؟';
    if (newStatus == 'suspended') actionName = 'إيقاف هذا الحساب مؤقتاً؟';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الإجراء'),
        content: Text('هل أنت متأكد من أنك تريد $actionName'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref.read(membersProvider.notifier).updateMemberStatus(id, newStatus);
              if (success && ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تحديث حالة الحساب بنجاح')),
                );
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _deleteProvider(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المزود؟ سيتم حذف جميع بياناته ولا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success = await ref.read(membersProvider.notifier).deleteMember(id);
              if (success && ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم الحذف بنجاح')),
                );
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

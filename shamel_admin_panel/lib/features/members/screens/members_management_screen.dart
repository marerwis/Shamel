import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/members_provider.dart';

class MembersManagementScreen extends ConsumerStatefulWidget {
  const MembersManagementScreen({super.key});

  @override
  ConsumerState<MembersManagementScreen> createState() => _MembersManagementScreenState();
}

class _MembersManagementScreenState extends ConsumerState<MembersManagementScreen> {
  String _searchQuery = '';
  String _statusFilter = 'الكل';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'إدارة العملاء',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddMemberDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text('إضافة عضو جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
          ],
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
                    hintText: 'ابحث بالاسم أو رقم الهاتف...',
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
                  items: ['الكل', 'active', 'suspended'].map((e) {
                    String label = e;
                    if (e == 'الكل') label = 'الكل';
                    if (e == 'active') label = 'نشط';
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

        // Tab Views
        Expanded(
          child: _buildMembersTab(),
        ),
      ],
    );
  }

  Widget _buildMembersTab() {
    final asyncData = ref.watch(customersProvider);
    
    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('حدث خطأ: $err', style: const TextStyle(color: Colors.red))),
      data: (members) {
        // Filter by search
        var filtered = members.where((m) {
          final matchName = (m.fullName ?? '').toLowerCase().contains(_searchQuery);
          final matchPhone = (m.phone ?? '').contains(_searchQuery);
          return matchName || matchPhone;
        }).toList();

        // Filter by status
        if (_statusFilter != 'الكل') {
          filtered = filtered.where((m) => m.status == _statusFilter).toList();
        }

        if (filtered.isEmpty) {
          return const Center(child: Text('لا توجد بيانات مطابقة للبحث'));
        }
        
        return _buildMembersTable(filtered);
      },
    );
  }

  Widget _buildMembersTable(List<MemberModel> members) {
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
            DataColumn(label: Text('العميل', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('رقم الهاتف', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('تاريخ الانضمام', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: members.map((member) {
            
            // Status UI
            Color statusColor = Colors.grey;
            String statusText = member.status;
            if (member.status == 'active') {
              statusColor = Colors.green;
              statusText = 'نشط';
            } else if (member.status == 'suspended') {
              statusColor = Colors.red;
              statusText = 'موقوف';
            }

            final initial = (member.fullName != null && member.fullName!.isNotEmpty) 
                ? member.fullName![0].toUpperCase() : '?';
            final dateStr = DateFormat('yyyy-MM-dd').format(member.createdAt);

            return DataRow(
              cells: [
                DataCell(Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryContainer,
                      backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
                      child: member.avatarUrl == null ? Text(
                        initial, 
                        style: const TextStyle(color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),
                      ) : null,
                    ),
                    const SizedBox(width: 12),
                    Text(member.fullName ?? 'بدون اسم', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )),
                DataCell(Text(member.phone ?? 'غير متوفر')),
                DataCell(Text(dateStr)),
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
                    if (member.status != 'suspended')
                      IconButton(
                        icon: const Icon(Icons.block, color: Colors.red),
                        tooltip: 'إيقاف الحساب',
                        onPressed: () => _updateStatus(context, member.id, 'suspended'),
                      ),

                    if (member.status == 'suspended')
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.blue),
                        tooltip: 'استعادة الحساب',
                        onPressed: () => _updateStatus(context, member.id, 'active'),
                      ),
                      
                    IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'حذف العضو',
                        onPressed: () => _deleteMember(context, member.id),
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

  void _deleteMember(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا العضو؟ سيتم حذف جميع بياناته ولا يمكن التراجع عن هذا الإجراء.'),
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
  void _showAddMemberDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.person_add, color: AppColors.primary),
                SizedBox(width: 8),
                Text('إضافة عضو جديد'),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'الاسم الكامل',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailCtrl,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneCtrl,
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passCtrl,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('الرجاء تعبئة الحقول الإلزامية')),
                          );
                          return;
                        }
                        
                        setState(() => isLoading = true);
                        try {
                          final nameParts = nameCtrl.text.trim().split(' ');
                          await Supabase.instance.client.rpc('admin_create_user', params: {
                            'email': emailCtrl.text.trim(),
                            'password': passCtrl.text,
                            'role': 'user',
                            'first_name': nameParts.isNotEmpty ? nameParts.first : '',
                            'last_name': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
                          });
                          
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تمت إضافة العضو بنجاح!')),
                            );
                            ref.invalidate(membersProvider);
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('خطأ: $e')),
                            );
                          }
                        } finally {
                          if (ctx.mounted) {
                            setState(() => isLoading = false);
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('إضافة'),
              ),
            ],
          );
        },
      ),
    );
  }
}


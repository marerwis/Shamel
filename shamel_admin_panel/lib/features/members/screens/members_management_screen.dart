import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/members_provider.dart';

class MembersManagementScreen extends ConsumerStatefulWidget {
  const MembersManagementScreen({super.key});

  @override
  ConsumerState<MembersManagementScreen> createState() => _MembersManagementScreenState();
}

class _MembersManagementScreenState extends ConsumerState<MembersManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _statusFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'إدارة الأعضاء والمستخدمين',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        
        // Tabs
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'العملاء (Customers)'),
            Tab(text: 'مزودي الخدمة (Providers)'),
          ],
        ),
        const SizedBox(height: 24),
        
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
                  items: ['الكل', 'active', 'pending', 'suspended'].map((e) {
                    String label = e;
                    if (e == 'الكل') label = 'الكل';
                    if (e == 'active') label = 'نشط';
                    if (e == 'pending') label = 'قيد الانتظار';
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
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMembersTab(customersProvider, isProviderTab: false),
              _buildMembersTab(providersListProvider, isProviderTab: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersTab(Provider<AsyncValue<List<MemberModel>>> provider, {required bool isProviderTab}) {
    final asyncData = ref.watch(provider);
    
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
        
        return _buildMembersTable(filtered, isProviderTab: isProviderTab);
      },
    );
  }

  Widget _buildMembersTable(List<MemberModel> members, {required bool isProviderTab}) {
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
            DataColumn(label: Text('العضو', style: TextStyle(fontWeight: FontWeight.bold))),
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
            } else if (member.status == 'pending') {
              statusColor = Colors.orange;
              statusText = 'قيد الانتظار';
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
                    if (isProviderTab && member.status == 'pending') 
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: 'قبول وتفعيل المزود',
                        onPressed: () => _updateStatus(context, member.id, 'active'),
                      ),
                    
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
    if (newStatus == 'pending') actionName = 'جعل هذا الحساب قيد الانتظار؟';

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
}


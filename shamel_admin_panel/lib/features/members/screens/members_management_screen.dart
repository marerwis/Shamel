import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/members_provider.dart';

class MembersManagementScreen extends ConsumerStatefulWidget {
  const MembersManagementScreen({super.key});

  @override
  ConsumerState<MembersManagementScreen> createState() => _MembersManagementScreenState();
}

class _MembersManagementScreenState extends ConsumerState<MembersManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('إضافة عضو جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  value: 'الكل',
                  items: ['الكل', 'نشط', 'موقوف'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {},
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
              _buildCustomersTab(),
              _buildProvidersTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomersTab() {
    final asyncData = ref.watch(customersProvider);
    
    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      data: (members) {
        if (members.isEmpty) {
          return const Center(child: Text('لا يوجد عملاء حتى الآن'));
        }
        return _buildMembersTable(members);
      },
    );
  }

  Widget _buildProvidersTab() {
    final asyncData = ref.watch(providersListProvider);
    
    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      data: (members) {
        if (members.isEmpty) {
          return const Center(child: Text('لا يوجد مزودين حتى الآن'));
        }
        return _buildMembersTable(members);
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
            DataColumn(label: Text('العضو', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('رقم الهاتف', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('تاريخ الانضمام', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: members.map((member) {
            return DataRow(
              cells: [
                DataCell(Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        member.firstName[0], 
                        style: const TextStyle(color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${member.firstName} ${member.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )),
                DataCell(Text(member.phone ?? 'غير متوفر')),
                const DataCell(Text('منذ قليل')),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('نشط', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                )),
                DataCell(Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove_red_eye, color: AppColors.primary), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.block, color: Colors.orange), onPressed: () {}),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

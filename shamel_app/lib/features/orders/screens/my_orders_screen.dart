import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../providers/orders_provider.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['النشطة', 'المكتملة', 'الملغاة'];

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(userOrdersProvider);

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
              color: AppColors.primary,
            );
          }
        ),
        title: const Text('طلباتي', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ChoiceChip(
                      label: Text(_filters[index]),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedFilterIndex = index);
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceContainer,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      showCheckmark: false,
                      side: BorderSide.none,
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Orders List
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                // Filter logic
                List<OrderModel> filteredOrders = [];
                if (_selectedFilterIndex == 0) {
                  // Active (pending, accepted, in_progress)
                  filteredOrders = orders.where((o) => ['pending', 'accepted', 'in_progress'].contains(o.status)).toList();
                } else if (_selectedFilterIndex == 1) {
                  // Completed
                  filteredOrders = orders.where((o) => o.status == 'completed').toList();
                } else if (_selectedFilterIndex == 2) {
                  // Cancelled
                  filteredOrders = orders.where((o) => o.status == 'cancelled').toList();
                }

                if (filteredOrders.isEmpty) {
                  return const Center(child: Text('لا توجد طلبات في هذا القسم'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    return ref.refresh(userOrdersProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(context, order);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('خطأ في جلب الطلبات: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    String statusAr = order.status;
    Color statusColor = AppColors.onSurfaceVariant;
    Color statusBg = AppColors.surfaceVariant;
    IconData statusIcon = Icons.schedule;

    switch (order.status) {
      case 'pending':
        statusAr = 'قيد الانتظار';
        statusColor = Colors.orange;
        statusBg = Colors.orange.withOpacity(0.1);
        statusIcon = Icons.hourglass_empty;
        break;
      case 'accepted':
        statusAr = 'تم القبول';
        statusColor = Colors.blue;
        statusBg = Colors.blue.withOpacity(0.1);
        statusIcon = Icons.thumb_up;
        break;
      case 'in_progress':
        statusAr = 'قيد التنفيذ';
        statusColor = AppColors.primary;
        statusBg = AppColors.primaryContainer.withOpacity(0.1);
        statusIcon = Icons.sync;
        break;
      case 'completed':
        statusAr = 'مكتمل';
        statusColor = Colors.green;
        statusBg = Colors.green.withOpacity(0.1);
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusAr = 'ملغى';
        statusColor = Colors.red;
        statusBg = Colors.red.withOpacity(0.1);
        statusIcon = Icons.cancel;
        break;
    }

    final serviceName = order.service?['name'] ?? 'خدمة غير معروفة';
    final categoryName = order.service?['category'] ?? 'عام';
    // Format date properly in a real app, here simple slice
    final dateStr = '${order.scheduledAt.year}-${order.scheduledAt.month.toString().padLeft(2, '0')}-${order.scheduledAt.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerHigh,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.home_repair_service, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              // Name & Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(serviceName, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text(categoryName, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(statusAr, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            order.notes != null && order.notes!.isNotEmpty ? order.notes! : 'لا توجد ملاحظات.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.surfaceVariant),
          const SizedBox(height: 12),
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(dateStr, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
              TextButton(
                onPressed: () {
                  context.push('/order_details/${order.id}');
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('التفاصيل', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

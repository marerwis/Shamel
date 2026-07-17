import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../providers/orders_provider.dart';
import '../../requests/providers/requests_provider.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Force refresh the streams to ensure we don't see stale cache from before booking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(myRequestsStreamProvider);
      ref.invalidate(myOrdersStreamProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(myOrdersStreamProvider);
    final requestsAsync = ref.watch(myRequestsStreamProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'قيد الانتظار'),
              Tab(text: 'قيد التنفيذ'),
              Tab(text: 'مكتملة'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Pending Requests & Pending Orders
            Builder(
              builder: (context) {
                final isLoading = requestsAsync.isLoading || ordersAsync.isLoading;
                final requests = requestsAsync.value ?? [];
                final orders = ordersAsync.value ?? [];
                
                final pendingRequests = requests.where((r) => r['status'] == 'Pending_Broadcast').toList();
                final pendingOrders = orders.where((o) => o.status == 'pending').toList();
                
                if (isLoading && pendingRequests.isEmpty && pendingOrders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (pendingRequests.isEmpty && pendingOrders.isEmpty) {
                  return _buildEmptyState(context, 'لا توجد طلبات معلقة');
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(myRequestsStreamProvider);
                    ref.invalidate(myOrdersStreamProvider);
                  },
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    children: [
                      ...pendingRequests.map((req) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildRequestCard(context, req),
                      )),
                      ...pendingOrders.map((order) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildOrderCard(context, order),
                      )),
                    ],
                  ),
                );
              },
            ),
            
            // Tab 2: Active Orders (accepted, in_progress)
            ordersAsync.when(
              data: (orders) {
                final activeOrders = orders.where((o) => ['accepted', 'in_progress'].contains(o.status)).toList();
                if (activeOrders.isEmpty) {
                  return _buildEmptyState(context, 'لا توجد طلبات قيد التنفيذ');
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    return ref.refresh(myOrdersStreamProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: activeOrders.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = activeOrders[index];
                      return _buildOrderCard(context, order);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('خطأ في جلب الطلبات: $err')),
            ),
            
            // Tab 3: Completed/Cancelled Orders (completed, cancelled, disputed)
            ordersAsync.when(
              data: (orders) {
                final completedOrders = orders.where((o) => ['completed', 'cancelled', 'disputed'].contains(o.status)).toList();
                if (completedOrders.isEmpty) {
                  return _buildEmptyState(context, 'لا توجد طلبات مكتملة');
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    return ref.refresh(myOrdersStreamProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: completedOrders.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final order = completedOrders[index];
                      return _buildOrderCard(context, order);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('خطأ في جلب الطلبات: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: AppColors.outline.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تظهر هنا طلباتك عند توفرها',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.outline,
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

    final serviceName = order.service?['name'] ?? 'طلب عام مخصص';
    final categoryName = order.service?['category'] ?? 'حسب العرض';
    // Format date properly in a real app, here simple slice
    final dateStr = order.scheduledAt != null 
        ? '${order.scheduledAt!.year}-${order.scheduledAt!.month.toString().padLeft(2, '0')}-${order.scheduledAt!.day.toString().padLeft(2, '0')}'
        : '';

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
                  context.push('/order_details/${order.id}', extra: order);
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

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> req) {
    final statusAr = 'قيد الانتظار (في انتظار العروض)';
    final statusColor = Colors.orange;
    final statusBg = Colors.orange.withOpacity(0.1);
    final statusIcon = Icons.sensors; // Broadcast icon
    
    final desc = req['description'] ?? 'بدون وصف';
    final dateStr = req['created_at'] != null ? req['created_at'].toString().split('T')[0] : '';
    
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
                child: const Icon(Icons.campaign, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('طلب عام مخصص', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                    if (dateStr.isNotEmpty)
                      Text('تاريخ النشر: $dateStr', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 6),
                Text(statusAr, style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


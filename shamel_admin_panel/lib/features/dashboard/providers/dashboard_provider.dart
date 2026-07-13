import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardStats {
  final int totalRevenue;
  final int activeOrders;
  final int totalProviders;
  final int totalUsers;

  DashboardStats({
    required this.totalRevenue,
    required this.activeOrders,
    required this.totalProviders,
    required this.totalUsers,
  });
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final client = Supabase.instance.client;

  // Since we might not have real data yet, we do count queries. 
  // Get the count of rows by fetching only IDs and getting the length, 
  // or using the proper v2 .count() syntax.
  
  final usersRes = await client.from('profiles').select('id');
  final providersRes = await client.from('providers').select('profile_id');
  final ordersRes = await client.from('orders').select('id');

  // Simulating revenue calculation since we don't have completed orders yet
  final revenue = 0; 

  return DashboardStats(
    totalRevenue: revenue,
    activeOrders: ordersRes.length,
    totalProviders: providersRes.length,
    totalUsers: usersRes.length,
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final ordersProvider = StateNotifierProvider<OrdersNotifier, bool>((ref) {
  return OrdersNotifier();
});

class OrdersNotifier extends StateNotifier<bool> {
  OrdersNotifier() : super(false);
  final _client = Supabase.instance.client;

  Future<void> releaseMilestone(String milestoneId, String orderId, double amount, String providerId) async {
    state = true;
    try {
      // Release milestone means paying it from Escrow to Provider's Wallet
      await _client.rpc('release_milestone_payment', params: {
        'p_milestone_id': milestoneId,
        'p_order_id': orderId,
        'p_amount': amount,
        'p_provider_id': providerId,
      });
    } catch (e) {
      state = false;
      throw e;
    }
    state = false;
  }

  Future<void> raiseDispute(String orderId, String reason) async {
    state = true;
    try {
      final userId = _client.auth.currentUser!.id;
      await _client.from('disputes').insert({
        'order_id': orderId,
        'raised_by': userId,
        'reason': reason,
        'status': 'Open',
      });
      await _client.from('orders').update({'status': 'Disputed'}).eq('id', orderId);
    } catch (e) {
      state = false;
      throw e;
    }
    state = false;
  }
}

// Fetch orders for current user (customer or provider)
final myOrdersStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser!.id;

  return supabase
      .from('orders')
      .stream(primaryKey: ['id'])
      .or('customer_id.eq.$userId,provider_id.eq.$userId')
      .order('created_at', ascending: false);
});

// Fetch milestones for an order
final orderMilestonesStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, orderId) {
  final supabase = Supabase.instance.client;
  return supabase
      .from('order_milestones')
      .stream(primaryKey: ['id'])
      .eq('order_id', orderId)
      .order('milestone_number', ascending: true);
});

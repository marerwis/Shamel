import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderModel {
  final String id;
  final String providerId;
  final String userId;
  final String status;
  final double price;
  final String? serviceId;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final String? notes;
  final Map<String, dynamic>? provider;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? service;

  OrderModel({
    required this.id,
    required this.providerId,
    required this.userId,
    required this.status,
    required this.price,
    this.serviceId,
    required this.createdAt,
    this.scheduledAt,
    this.notes,
    this.provider,
    this.customer,
    this.service,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      providerId: json['provider_id'],
      userId: json['user_id'],
      status: json['status'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      serviceId: json['service_id'],
      createdAt: DateTime.parse(json['created_at']),
      scheduledAt: json['scheduled_at'] != null ? DateTime.parse(json['scheduled_at']) : null,
      notes: json['notes'],
      provider: json['provider'],
      customer: json['customer'],
      service: json['service'],
    );
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, bool>((ref) {
  return OrdersNotifier();
});

class OrdersNotifier extends StateNotifier<bool> {
  OrdersNotifier() : super(false);
  final _client = Supabase.instance.client;

  Future<String> createOrder({
    required String providerId,
    required double price,
    String? requestDescription,
    List<Map<String, dynamic>>? milestones,
    String? serviceId,
    String? address,
    DateTime? scheduledAt,
    String? notes,
  }) async {
    state = true;
    try {
      final customerId = _client.auth.currentUser!.id;
      final orderRes = await _client.from('orders').insert({
        'user_id': customerId,
        'provider_id': providerId,
        'status': 'Pending',
        'price': price,
        'service_id': serviceId,
        'scheduled_at': scheduledAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'notes': notes,
        // if we had an address column, we'd add it here, or notes.
      }).select().single();
      
      final orderId = orderRes['id'] as String;

      if (milestones != null && milestones.isNotEmpty) {
        final milestonesToInsert = milestones.map((m) => {
          'order_id': orderId,
          'milestone_number': m['milestone_number'],
          'description': m['description'],
          'amount': m['amount'],
          'status': 'Pending',
        }).toList();
        await _client.from('order_milestones').insert(milestonesToInsert);
      }
      
      state = false;
      return orderId;
    } on PostgrestException catch (e) {
      state = false;
      throw Exception('خطأ في قاعدة البيانات: ${e.message}');
    } catch (e) {
      state = false;
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  Future<void> releaseMilestone(String milestoneId, String orderId, double amount, String providerId) async {
    state = true;
    try {
      await _client.rpc('release_milestone_payment', params: {
        'p_milestone_id': milestoneId,
        'p_order_id': orderId,
        'p_amount': amount,
        'p_provider_id': providerId,
      });
    } on PostgrestException catch (e) {
      state = false;
      throw Exception('خطأ في قاعدة البيانات: ${e.message}');
    } catch (e) {
      state = false;
      throw Exception('حدث خطأ غير متوقع: $e');
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
    } on PostgrestException catch (e) {
      state = false;
      throw Exception('خطأ في قاعدة البيانات: ${e.message}');
    } catch (e) {
      state = false;
      throw Exception('حدث خطأ غير متوقع: $e');
    }
    state = false;
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    state = true;
    try {
      await _client.from('orders').update({'status': newStatus}).eq('id', orderId);
    } on PostgrestException catch (e) {
      state = false;
      throw Exception('خطأ في قاعدة البيانات: ${e.message}');
    } catch (e) {
      state = false;
      throw Exception('حدث خطأ غير متوقع: $e');
    }
    state = false;
  }

  Future<void> completeDelivery(String orderId, String providerId, double price) async {
    state = true;
    try {
      // Execute Wallet Credit
      if (price > 0) {
        await _client.rpc('process_wallet_transaction', params: {
          'p_user_id': providerId,
          'p_amount': price,
          'p_transaction_type': 'credit',
          'p_description': 'استلام أرباح طلب توصيل'
        });
      }
      // Update status to completed
      await _client.from('orders').update({'status': 'completed'}).eq('id', orderId);
    } on PostgrestException catch (e) {
      state = false;
      throw Exception('خطأ في قاعدة البيانات: ${e.message}');
    } catch (e) {
      state = false;
      throw Exception('حدث خطأ غير متوقع: $e');
    }
    state = false;
  }
}

final myOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) async* {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser!.id;

  final customerOrdersStream = supabase
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId);
      
  final providerOrdersStream = supabase
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('provider_id', userId);

  await for (final customerOrders in customerOrdersStream) {
    // This is a naive merge if the user can be both, 
    // but in Supabase flutter, stream builder with multiple eq is limited.
    // For simplicity, we just fetch from DB directly if we want a realtime view of both,
    final res = await supabase.from('orders').select('*, service:services(*), provider:profiles!orders_provider_id_fkey(*), customer:profiles!user_id(*)').or('user_id.eq.$userId,provider_id.eq.$userId').order('created_at', ascending: false);
    yield res.map((e) => OrderModel.fromJson(e)).toList();
  }
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

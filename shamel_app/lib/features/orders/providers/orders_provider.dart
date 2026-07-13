import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String? serviceId;
  final String status;
  final double? price;
  final String address;
  final DateTime scheduledAt;
  final String? notes;
  final DateTime createdAt;
  final Map<String, dynamic>? service;

  OrderModel({
    required this.id,
    required this.customerId,
    this.serviceId,
    required this.status,
    this.price,
    required this.address,
    required this.scheduledAt,
    this.notes,
    required this.createdAt,
    this.service,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customerId: json['customer_id'],
      serviceId: json['service_id'],
      status: json['status'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      address: json['address'],
      scheduledAt: DateTime.parse(json['scheduled_at']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      service: json['services'], // Supabase join
    );
  }
}

class OrderController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> createOrder({
    required String customerId,
    required String serviceId,
    required double price,
    required String address,
    required DateTime scheduledAt,
    String? notes,
  }) async {
    await _client.from('orders').insert({
      'customer_id': customerId,
      'service_id': serviceId,
      'status': 'pending',
      'price': price,
      'address': address,
      'scheduled_at': scheduledAt.toIso8601String(),
      'notes': notes,
    });
  }
}

final orderControllerProvider = Provider<OrderController>((ref) {
  return OrderController();
});

final userOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final response = await Supabase.instance.client
      .from('orders')
      .select('*, services(name, category, icon_url)')
      .eq('customer_id', user.id)
      .order('created_at', ascending: false);

  return (response as List).map((data) => OrderModel.fromJson(data)).toList();
});

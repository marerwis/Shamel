import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String providerId;
  final String? serviceId;
  final String status;
  final double? price;
  final String address;
  final DateTime? scheduledAt;
  final String? notes;
  final DateTime createdAt;
  final Map<String, dynamic>? service;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? provider;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.providerId,
    this.serviceId,
    required this.status,
    this.price,
    required this.address,
    this.scheduledAt,
    this.notes,
    required this.createdAt,
    this.service,
    this.customer,
    this.provider,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customerId: json['customer_id'],
      providerId: json['provider_id'],
      serviceId: json['service_id'],
      status: json['status'] ?? 'pending',
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      address: json['address'] ?? '',
      scheduledAt: json['scheduled_at'] != null ? DateTime.parse(json['scheduled_at']) : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      service: json['services'],
      customer: json['customer'], // Need to alias in query
      provider: json['provider'], // Need to alias in query
    );
  }
}

final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<OrderModel>>(() {
  return OrdersNotifier();
});

class OrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  FutureOr<List<OrderModel>> build() async {
    return _fetchOrders();
  }

  Future<List<OrderModel>> _fetchOrders() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return [];

    final isProvider = user.role == 'provider';

    final response = await _client
        .from('orders')
        .select('''
          *,
          services(id, title, price, image_url),
          customer:profiles!customer_id(id, full_name, avatar_url, phone),
          provider:profiles!provider_id(id, full_name, avatar_url, phone)
        ''')
        .eq(isProvider ? 'provider_id' : 'customer_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((data) => OrderModel.fromJson(data)).toList();
  }

  Future<void> fetchOrders() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchOrders());
  }

  Future<bool> createOrder({
    required String providerId,
    String? serviceId,
    required double price,
    required String address,
    DateTime? scheduledAt,
    String? notes,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    try {
      await _client.from('orders').insert({
        'customer_id': user.id,
        'provider_id': providerId,
        'service_id': serviceId,
        'status': 'pending',
        'price': price,
        'address': address,
        'scheduled_at': scheduledAt?.toIso8601String(),
        'notes': notes,
      });
      await fetchOrders();
      return true;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _client.from('orders').update({'status': newStatus}).eq('id', orderId);
      await fetchOrders();
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }
}

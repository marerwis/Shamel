import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String? providerId;
  final String? serviceId;
  final String status;
  final double? price;
  final String address;
  final DateTime scheduledAt;
  final String? notes;

  OrderModel({
    required this.id,
    required this.customerId,
    this.providerId,
    this.serviceId,
    required this.status,
    this.price,
    required this.address,
    required this.scheduledAt,
    this.notes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customerId: json['customer_id'],
      providerId: json['provider_id'],
      serviceId: json['service_id'],
      status: json['status'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      address: json['address'],
      scheduledAt: DateTime.parse(json['scheduled_at']),
      notes: json['notes'],
    );
  }
}

final ordersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final response = await Supabase.instance.client
      .from('orders')
      .select()
      .order('created_at', ascending: false);
      
  return (response as List).map((data) => OrderModel.fromJson(data)).toList();
});

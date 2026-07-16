import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceModel {
  final String id;
  final String title;
  final String? categoryId;
  final String? description;
  final double price;
  final String? providerId;

  ServiceModel({
    required this.id,
    required this.title,
    this.categoryId,
    this.description,
    required this.price,
    this.providerId,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      title: json['title'] ?? json['name'] ?? 'بدون اسم',
      categoryId: json['category_id'],
      description: json['description'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : (json['base_price'] != null ? (json['base_price'] as num).toDouble() : 0.0),
      providerId: json['provider_id'],
    );
  }
}

final appServicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final response = await Supabase.instance.client
      .from('services')
      .select()
      .order('created_at', ascending: false);
      
  return (response as List).map((data) => ServiceModel.fromJson(data)).toList();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model
class ServiceModel {
  final String id;
  final String title;
  final String? description;
  final double price;
  final String? categoryId;
  final String? categoryName;
  final String providerId;
  final String? providerName;

  ServiceModel({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.categoryId,
    this.categoryName,
    required this.providerId,
    this.providerName,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['category_id'],
      categoryName: json['categories'] != null ? json['categories']['name'] : null,
      providerId: json['provider_id'],
      providerName: json['profiles'] != null ? json['profiles']['full_name'] : null,
    );
  }
}

// Provider
final servicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final response = await Supabase.instance.client
      .from('services')
      .select('*, categories(name), profiles(full_name)')
      .order('created_at', ascending: false);
      
  return (response as List).map((data) => ServiceModel.fromJson(data)).toList();
});

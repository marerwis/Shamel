import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model
class ServiceModel {
  final String id;
  final String name;
  final String category;
  final bool isActive;
  final double basePrice;

  ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.isActive,
    required this.basePrice,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      isActive: json['is_active'] ?? true,
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Provider
final servicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final response = await Supabase.instance.client
      .from('services')
      .select()
      .order('created_at', ascending: false);
      
  return (response as List).map((data) => ServiceModel.fromJson(data)).toList();
});

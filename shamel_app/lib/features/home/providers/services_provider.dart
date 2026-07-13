import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceModel {
  final String id;
  final String name;
  final String category;
  final String? description;
  final double basePrice;

  ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    required this.basePrice,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      basePrice: (json['base_price'] as num).toDouble(),
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

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
final servicesProvider = AsyncNotifierProvider<ServicesNotifier, List<ServiceModel>>(() {
  return ServicesNotifier();
});

class ServicesNotifier extends AsyncNotifier<List<ServiceModel>> {
  @override
  Future<List<ServiceModel>> build() async {
    return _fetchServices();
  }

  Future<List<ServiceModel>> _fetchServices() async {
    final response = await Supabase.instance.client
        .from('services')
        .select('*, categories(name), profiles(full_name)')
        .order('created_at', ascending: false);
        
    return (response as List).map((data) => ServiceModel.fromJson(data)).toList();
  }

  Future<bool> addService({
    required String title,
    required double price,
    String? categoryId,
    String? providerId,
  }) async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client.from('services').insert({
        'title': title,
        'price': price,
        'category_id': categoryId,
        'provider_id': providerId ?? currentUserId,
      });
      ref.invalidateSelf();
      return true;
    } catch (e) {
      print('Add Service Error: $e');
      return false;
    }
  }

  Future<bool> deleteService(String id) async {
    try {
      await Supabase.instance.client.from('services').delete().eq('id', id);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      print('Delete Service Error: $e');
      return false;
    }
  }
}

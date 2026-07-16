import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PromotionModel {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final String? targetUrl;
  final bool isActive;
  final DateTime createdAt;

  PromotionModel({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    this.targetUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      targetUrl: json['target_url'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

final promotionsProvider = AsyncNotifierProvider<PromotionsNotifier, List<PromotionModel>>(() {
  return PromotionsNotifier();
});

class PromotionsNotifier extends AsyncNotifier<List<PromotionModel>> {
  @override
  Future<List<PromotionModel>> build() async {
    return _fetchPromotions();
  }

  Future<List<PromotionModel>> _fetchPromotions() async {
    final response = await Supabase.instance.client
        .from('promotions')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((e) => PromotionModel.fromJson(e)).toList();
  }

  Future<String?> addPromotion({
    required String title,
    String? description,
    required String imageUrl,
    String? targetUrl,
    bool isActive = true,
  }) async {
    try {
      await Supabase.instance.client.from('promotions').insert({
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'target_url': targetUrl,
        'is_active': isActive,
      });
      ref.invalidateSelf();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deletePromotion(String id) async {
    try {
      await Supabase.instance.client.from('promotions').delete().eq('id', id);
      ref.invalidateSelf();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> togglePromotionStatus(String id, bool isActive) async {
    try {
      await Supabase.instance.client.from('promotions').update({'is_active': isActive}).eq('id', id);
      ref.invalidateSelf();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

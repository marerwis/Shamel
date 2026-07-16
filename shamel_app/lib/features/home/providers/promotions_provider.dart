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

final activePromotionsProvider = FutureProvider<List<PromotionModel>>((ref) async {
  final response = await Supabase.instance.client
      .from('promotions')
      .select()
      .eq('is_active', true)
      .order('created_at', ascending: false);

  return (response as List).map((e) => PromotionModel.fromJson(e)).toList();
});

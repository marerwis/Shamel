import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>(() {
  return CategoriesNotifier();
});

class CategoriesNotifier extends AsyncNotifier<List<CategoryModel>> {
  @override
  FutureOr<List<CategoryModel>> build() async {
    return _fetchCategories();
  }

  final _supabase = Supabase.instance.client;

  Future<List<CategoryModel>> _fetchCategories() async {
    final response = await _supabase
        .from('categories')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }

  Future<void> fetchCategories() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCategories());
  }

  Future<bool> addCategory(String name, {String? icon, String? parentId}) async {
    try {
      await _supabase.from('categories').insert({
        'name': name,
        'icon': icon,
        'parent_id': parentId,
      });
      ref.invalidateSelf();
      return true;
    } catch (e) {
      print('Add Category Error: $e');
      return false;
    }
  }

  Future<bool> updateCategory(String id, String name, {String? icon, String? parentId}) async {
    try {
      await _supabase.from('categories').update({
        'name': name,
        'icon': icon,
        'parent_id': parentId,
      }).eq('id', id);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      print('Update Category Error: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _supabase.from('categories').delete().eq('id', id);
      ref.invalidateSelf();
      return true;
    } catch (e) {
      print('Delete Category Error: $e');
      return false;
    }
  }
}

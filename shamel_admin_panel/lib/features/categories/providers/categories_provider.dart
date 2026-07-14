import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<CategoryModel>>>((ref) {
  return CategoriesNotifier();
});

class CategoriesNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  CategoriesNotifier() : super(const AsyncValue.loading()) {
    fetchCategories();
  }

  final _supabase = Supabase.instance.client;

  Future<void> fetchCategories() async {
    state = const AsyncValue.loading();
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .order('created_at', ascending: false);

      final categories = (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
          
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> addCategory(String name, {String? icon, String? parentId}) async {
    try {
      await _supabase.from('categories').insert({
        'name': name,
        'icon': icon,
        'parent_id': parentId,
      });
      await fetchCategories();
      return true;
    } catch (e) {
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
      await fetchCategories();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _supabase.from('categories').delete().eq('id', id);
      await fetchCategories();
      return true;
    } catch (e) {
      return false;
    }
  }
}

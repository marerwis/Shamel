
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

// Provider to fetch all root categories (categories with no parent)
final rootCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('categories')
      .select()
      .isFilter('parent_id', null)
      .order('created_at', ascending: true);
      
  return (response as List).map((e) => CategoryModel.fromJson(e)).toList();
});

// Provider to fetch ALL categories (including sub-categories)
final allCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('categories')
      .select()
      .order('name', ascending: true);
      
  return (response as List).map((e) => CategoryModel.fromJson(e)).toList();
});

// Provider to fetch subcategories for a given parentId
final subcategoriesProvider = FutureProvider.family<List<CategoryModel>, String>((ref, parentId) async {
  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('categories')
      .select()
      .eq('parent_id', parentId)
      .order('created_at', ascending: true);
      
  return (response as List).map((e) => CategoryModel.fromJson(e)).toList();
});
// Provider to search categories using ilike
final searchCategoriesProvider = FutureProvider.family<List<CategoryModel>, String>((ref, query) async {
  if (query.isEmpty) {
    return ref.watch(rootCategoriesProvider.future);
  }

  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('categories')
      .select()
      .ilike('name', '%\%')
      .order('created_at', ascending: true);
      
  return (response as List).map((e) => CategoryModel.fromJson(e)).toList();
});


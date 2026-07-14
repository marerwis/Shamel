import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final providersListProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, categoryId) async {
  final supabase = Supabase.instance.client;
  
  var query = supabase
      .from('profiles')
      .select('*, provider_details!inner(*)')
      .eq('role', 'provider')
      .eq('status', 'active');
      
  if (categoryId != null && categoryId.isNotEmpty) {
    query = query.eq('provider_details.category_id', categoryId);
  }
      
  final response = await query;
  return List<Map<String, dynamic>>.from(response);
});

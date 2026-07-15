import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final adminRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  
  // Fetch requests along with customer name and category name
  final response = await supabase
      .from('requests')
      .select('*, profiles(full_name), categories(name)')
      .order('created_at', ascending: false);
      
  return List<Map<String, dynamic>>.from(response);
});

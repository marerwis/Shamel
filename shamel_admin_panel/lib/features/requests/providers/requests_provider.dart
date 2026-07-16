import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final adminRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  
  try {
    // 1. Test basic fetch without joins first
    final basicResponse = await supabase.from('requests').select().limit(2);
    print('------ DEBUG REQUESTS BASIC FETCH ------');
    print('Basic Response Length: ${basicResponse.length}');
    print('Basic Response Data: $basicResponse');
    
    // 2. Fetch requests along with customer name and category name
    final response = await supabase
        .from('requests')
        .select('*, customer:profiles!customer_id(full_name), category:categories!category_id(name)')
        .order('created_at', ascending: false);
        
    print('------ DEBUG REQUESTS WITH JOINS ------');
    print('Join Response Length: ${response.length}');
    print('Join Response Data: $response');
    
    return List<Map<String, dynamic>>.from(response);
  } catch (e, stack) {
    print('------ DEBUG REQUESTS ERROR ------');
    print('Error: $e');
    print('Stack: $stack');
    rethrow;
  }
});

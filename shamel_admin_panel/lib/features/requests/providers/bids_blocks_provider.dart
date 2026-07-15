import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final adminBidsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('bids')
      .select('*, profiles(full_name), requests(description, categories(name))')
      .order('created_at', ascending: false);
      
  return List<Map<String, dynamic>>.from(response);
});

final adminBlocksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('temporary_blocks')
      .select('*, customer:profiles!customer_id(full_name), provider:profiles!provider_id(full_name)')
      .order('created_at', ascending: false);
      
  return List<Map<String, dynamic>>.from(response);
});

class AdminBlocksNotifier extends StateNotifier<bool> {
  AdminBlocksNotifier() : super(false);
  final _client = Supabase.instance.client;

  Future<void> removeBlock(String blockId) async {
    state = true;
    try {
      await _client.from('temporary_blocks').delete().eq('id', blockId);
    } catch (e) {
      state = false;
      throw e;
    }
    state = false;
  }
}

final adminBlocksNotifierProvider = StateNotifierProvider<AdminBlocksNotifier, bool>((ref) {
  return AdminBlocksNotifier();
});

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

class AdminBlocksNotifier extends Notifier<bool> {
  final _client = Supabase.instance.client;

  @override
  bool build() {
    return false;
  }

  Future<void> removeBlock(String blockId) async {
    state = true;
    try {
      await _client.from('temporary_blocks').delete().eq('id', blockId);
    } catch (e) {
      state = false;
      rethrow;
    }
    state = false;
  }
}

final adminBlocksNotifierProvider = NotifierProvider<AdminBlocksNotifier, bool>(() {
  return AdminBlocksNotifier();
});

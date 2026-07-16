import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

final notificationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final response = await Supabase.instance.client
      .from('notifications')
      .select()
      .eq('user_id', user.id)
      .order('created_at', ascending: false);
      
  return List<Map<String, dynamic>>.from(response);
});

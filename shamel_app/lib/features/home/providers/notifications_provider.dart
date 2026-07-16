import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

final notificationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield [];
    return;
  }

  final stream = Supabase.instance.client
      .from('notifications')
      .stream(primaryKey: ['id'])
      .eq('user_id', user.id)
      .order('created_at', ascending: false);
      
  await for (final data in stream) {
    yield List<Map<String, dynamic>>.from(data);
  }
});

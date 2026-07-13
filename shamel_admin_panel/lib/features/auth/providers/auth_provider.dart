import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provides the current Supabase auth state
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// Provides the currently logged-in User
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateProvider);
  return Supabase.instance.client.auth.currentUser;
});

// Provides the role of the logged in user
final userRoleProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  try {
    final response = await Supabase.instance.client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();
        
    return response?['role'] as String?;
  } catch (e) {
    return null;
  }
});

class AuthController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> login(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

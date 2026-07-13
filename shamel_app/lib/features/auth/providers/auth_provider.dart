import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provides the current Supabase auth state (signed in, signed out, etc.)
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// Provides the currently logged-in User object, or null if unauthenticated.
final currentUserProvider = Provider<User?>((ref) {
  // Watch the auth state stream so this provider updates when auth state changes
  ref.watch(authStateProvider); 
  return Supabase.instance.client.auth.currentUser;
});

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();
      
  return response;
});

// A provider for a simple Auth Controller to handle login/register/logout actions
class AuthController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> login(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> registerCustomer({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final response = await _client.auth.signUp(email: email, password: password);
    
    if (response.user != null) {
      // Insert profile data
      await _client.from('profiles').insert({
        'id': response.user!.id,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'role': 'customer',
      });
    }
    
    return response;
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

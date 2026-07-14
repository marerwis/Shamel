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
      .select('*, provider_details(*)')
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

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String role,
    required String fullName,
    String? phone,
    String? fatherName,
    String? grandfatherName,
    String? idType,
    String? idNumber,
    String? categoryId,
    String? title,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'role': role,
        'full_name': fullName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (fatherName != null && fatherName.isNotEmpty) 'father_name': fatherName,
        if (grandfatherName != null && grandfatherName.isNotEmpty) 'grandfather_name': grandfatherName,
        if (idType != null && idType.isNotEmpty) 'id_type': idType,
        if (idNumber != null && idNumber.isNotEmpty) 'id_number': idNumber,
        if (categoryId != null && categoryId.isNotEmpty) 'category_id': categoryId,
        if (title != null && title.isNotEmpty) 'title': title,
      },
    );
  }


  Future<void> logout() async {
    await _client.auth.signOut();
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

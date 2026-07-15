import 'package:supabase/supabase.dart';
void main() async {
  const supabaseUrl = 'https://ahhmkwhrbwlyteinwlwb.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoaG1rd2hyYndseXRlaW53bHdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4ODkyMTMsImV4cCI6MjA5OTQ2NTIxM30.gZ86XXc7UpdDKk_Jjz7drlzXKxum_2LX9gJwaZVdWdI';
  final client = SupabaseClient(
    supabaseUrl,
    supabaseAnonKey,
    authOptions: const AuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );
  try {
    final email = 'test_new_user12345@test.com';
    print('Trying to sign up $email');
    final res = await client.auth.signUp(
      email: email,
      password: 'Password123!',
      data: {'role': 'user'}
    );
    print('Success: ${res.user?.id}');
  } catch (e) {
    print('Error: $e');
  }
}


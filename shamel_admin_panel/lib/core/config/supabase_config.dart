import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Replace 'YOUR_SUPABASE_ANON_KEY' with the actual anon key from Supabase Dashboard
  static const String supabaseUrl = 'https://ahhmkwhrbwlyteinwlwb.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_i_KjXmlciD4idLmtpkC6Xw_6_CMLBm0';

  static Future<void> initialize() async {
    // Only initialize if the key is provided
    if (supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY') {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://ahhmkwhrbwlyteinwlwb.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_i_KjXmlciD4idLmtpkC6Xw_6_CMLBm0';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}

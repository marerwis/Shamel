import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Replace 'YOUR_SUPABASE_ANON_KEY' with the actual anon key from Supabase Dashboard
  static const String supabaseUrl = 'https://ahhmkwhrbwlyteinwlwb.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoaG1rd2hyYndseXRlaW53bHdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4ODkyMTMsImV4cCI6MjA5OTQ2NTIxM30.gZ86XXc7UpdDKk_Jjz7drlzXKxum_2LX9gJwaZVdWdI';

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

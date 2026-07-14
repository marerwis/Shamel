import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://ahhmkwhrbwlyteinwlwb.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoaG1rd2hyYndseXRlaW53bHdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4ODkyMTMsImV4cCI6MjA5OTQ2NTIxM30.gZ86XXc7UpdDKk_Jjz7drlzXKxum_2LX9gJwaZVdWdI';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}

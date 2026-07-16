import 'package:supabase/supabase.dart';

void main() async {
  await Supabase.initialize(url: 'https://ahhmkwhrbwlyteinwlwb.supabase.co', anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoaG1rd2hyYndseXRlaW53bHdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4ODkyMTMsImV4cCI6MjA5OTQ2NTIxM30.gZ86XXc7UpdDKk_Jjz7drlzXKxum_2LX9gJwaZVdWdI');
  final supabase = Supabase.instance.client;
  try {
    final res = await supabase.from('notifications').select().limit(1);
    print(res);
  } catch (e) {
    print('Error: $e');
  }
}

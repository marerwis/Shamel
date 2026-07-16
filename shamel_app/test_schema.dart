import 'package:supabase/supabase.dart';
import 'lib/core/config/supabase_config.dart';

void main() async {
  final supabase = SupabaseClient(SupabaseConfig.supabaseUrl, SupabaseConfig.supabaseAnonKey);
  try {
    final cat = await supabase.from('categories').select().limit(1);
    print('categories: $cat');
    final srv = await supabase.from('services').select().limit(1);
    print('services: $srv');
  } catch (e) {
    print('error: $e');
  }
}


import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final envLines = File('.env').readAsLinesSync();
  String? url;
  String? key;
  for (var line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1];
    if (line.startsWith('SUPABASE_SERVICE_ROLE_KEY=')) key = line.split('=')[1];
    if (key == null && line.startsWith('SUPABASE_ANON_KEY=')) key = line.split('=')[1];
  }
  
  final client = SupabaseClient(url!, key!);
  
  if (args.isEmpty) {
    print('Please provide an SQL file to run.');
    return;
  }
  
  final sqlFile = File(args.first);
  if (!sqlFile.existsSync()) {
    print('SQL file not found: ${args.first}');
    return;
  }
  
  final sql = sqlFile.readAsStringSync();
  
  try {
    // We can use the rpc 'exec_sql' if we created one, or we can just print instructions.
    // Wait, Supabase Dart client does NOT have a way to run arbitrary DDL SQL directly 
    // without an RPC function that executes arbitrary SQL (which is dangerous).
    // Let me just tell the user to execute it manually or I will create an exec_sql RPC if they already have one.
    
    // Check if we can execute via REST API
    final response = await client.rpc('exec_sql', params: {'sql_query': sql});
    print('SQL executed successfully: $response');
  } catch (e) {
    print('Failed to execute SQL via RPC. If exec_sql does not exist, you must run it manually in Supabase Dashboard.');
    print('Error: $e');
  }
  
  print('Done!');
  exit(0);
}

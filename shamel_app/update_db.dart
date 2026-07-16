
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final envLines = File('assets/.env').readAsLinesSync();
  String? url;
  String? key;
  for (var line in envLines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1];
    if (line.startsWith('SUPABASE_SERVICE_ROLE_KEY=')) key = line.split('=')[1];
    if (key == null && line.startsWith('SUPABASE_ANON_KEY=')) key = line.split('=')[1];
  }
  
  final client = SupabaseClient(url!, key!);
  
  print('Fetching requests...');
  final requests = await client.from('requests').select('id, category_id').eq('status', 'Pending_Broadcast');
  print('Found ' + requests.length.toString() + ' requests.');
  
  for(var req in requests) {
    final catId = req['category_id'];
    var currentCatId = catId;
    while(true) {
      final cat = await client.from('categories').select('parent_id').eq('id', currentCatId).maybeSingle();
      if(cat != null && cat['parent_id'] != null) {
        currentCatId = cat['parent_id'];
      } else {
        break;
      }
    }
    
    if(currentCatId != catId) {
      print('Updating request ' + req['id'] + ' from ' + catId + ' to ' + currentCatId);
      await client.from('requests').update({'category_id': currentCatId}).eq('id', req['id']);
    }
  }

  print('Done!');
  exit(0);
}


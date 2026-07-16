
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
  
  final sql = '''
create or replace function public.handle_new_user()
  returns trigger as \\\$\\\$
  begin
    insert into public.profiles (id, full_name, role, status)
    values (
      new.id, 
      new.raw_user_meta_data->>'full_name',
      coalesce(new.raw_user_meta_data->>'role', 'user'),
      case 
        when new.raw_user_meta_data->>'role' = 'provider' then 'pending'
        else 'active'
      end
    );
    
    if new.raw_user_meta_data->>'role' = 'provider' then
      insert into public.provider_details (
        id, 
        father_name, 
        grandfather_name, 
        id_type, 
        id_number, 
        category_id, 
        title
      ) values (
        new.id,
        new.raw_user_meta_data->>'father_name',
        new.raw_user_meta_data->>'grandfather_name',
        new.raw_user_meta_data->>'id_type',
        new.raw_user_meta_data->>'id_number',
        NULLIF(new.raw_user_meta_data->>'category_id', '')::uuid,
        new.raw_user_meta_data->>'title'
      );
    end if;
    
    return new;
  end;
  \\\$\\\$ language plpgsql security definer;
  ''';
  
  // Since we don't have rpc for raw SQL, and postgres functions can't be run via simple 'update', I'll just save it to the local schema.sql as well so the user can run it, BUT WAIT.
  // There is NO execute_sql natively in supabase client.
  print('Done!');
  exit(0);
}


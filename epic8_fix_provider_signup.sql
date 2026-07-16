-- =========================================
-- EPIC 8: FIX PROVIDER SIGNUP (TRIGGER)
-- =========================================

-- The original handle_new_user trigger had a bug where the 'id_number' column
-- was missing from the INSERT column list for provider_details, which shifted 
-- the values and caused category_id to be NULL or cast to UUID incorrectly.

create or replace function public.handle_new_user()
  returns trigger as $BODY
  begin
    insert into public.profiles (id, full_name, role, status)
    values (
      new.id, 
      new.raw_user_meta_data->>'full_name',
      (coalesce(new.raw_user_meta_data->>'role', 'user'))::public.user_role,
      case 
        when new.raw_user_meta_data->>'role' = 'provider' then 'pending'
        else 'active'
      end
    )
    on conflict (id) do update set
      full_name = EXCLUDED.full_name,
      role = EXCLUDED.role,
      status = EXCLUDED.status;
    
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
        nullif(new.raw_user_meta_data->>'category_id', '')::uuid,
        new.raw_user_meta_data->>'title'
      )
      on conflict (id) do update set
        father_name = EXCLUDED.father_name,
        grandfather_name = EXCLUDED.grandfather_name,
        id_type = EXCLUDED.id_type,
        id_number = EXCLUDED.id_number,
        category_id = EXCLUDED.category_id,
        title = EXCLUDED.title;
    end if;
    
    return new;
  end;
  $BODY language plpgsql security definer;

-- Drop any old conflicting triggers
drop trigger if exists on_auth_user_created on auth.users;

-- Re-create the correct trigger
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- OPTIONAL FIX: If there are existing providers with NULL category_id, you can assign them a default category 
-- (e.g., the first category in your table) using a query like this in the SQL Editor:
-- UPDATE public.provider_details SET category_id = (SELECT id FROM public.categories LIMIT 1) WHERE category_id IS NULL;


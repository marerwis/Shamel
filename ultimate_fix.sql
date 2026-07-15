-- Skipping ALTER COLUMN TYPE to avoid policy dependency errors

-- 2. Ensure all needed columns exist
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS full_name text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url text;

-- 3. Update the trigger to explicitly cast to public.user_role
create or replace function public.handle_new_user()
returns trigger as $$
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
$$ language plpgsql security definer;

-- 4. Drop any old conflicting triggers
drop trigger if exists on_auth_user_created on auth.users;
drop trigger if exists create_profile_on_signup on auth.users;
drop trigger if exists on_auth_users_insert on auth.users;
drop trigger if exists handle_new_user on auth.users;

-- 5. Re-create the correct trigger
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

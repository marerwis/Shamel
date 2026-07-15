-- Run this block in the Supabase SQL Editor and see if it throws an error!
-- It simulates what the trigger is trying to do.
do $$
begin
  insert into public.profiles (id, full_name, role, status)
  values (
    '00000000-0000-0000-0000-000000000000'::uuid, 
    'Test User',
    'admin'::user_role,
    'active'
  );
end
$$;

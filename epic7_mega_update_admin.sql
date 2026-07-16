-- ==============================================================================
-- 3. Create function to allow Admin Panel to create users directly
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION public.admin_create_user(
  p_email text,
  p_password text,
  p_full_name text,
  p_role text,
  p_phone text DEFAULT NULL
) RETURNS uuid AS $$
DECLARE
  new_user_id uuid;
  encrypted_pw text;
BEGIN
  -- Generate a new UUID
  new_user_id := gen_random_uuid();
  
  -- Encrypt password
  encrypted_pw := crypt(p_password, gen_salt('bf'));

  -- Insert into auth.users (Requires SECURITY DEFINER to bypass restrictions)
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at
  )
  VALUES (
    '00000000-0000-0000-0000-000000000000',
    new_user_id,
    'authenticated',
    'authenticated',
    p_email,
    encrypted_pw,
    now(),
    '{"provider":"email","providers":["email"]}',
    json_build_object('full_name', p_full_name, 'role', p_role, 'phone', p_phone),
    now(),
    now()
  );

  RETURN new_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

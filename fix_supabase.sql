-- 1. Create a function to check if the current user is an admin or super_admin
CREATE OR REPLACE FUNCTION public.is_admin() RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Drop existing Orders RLS policies if any (to avoid conflicts)
DROP POLICY IF EXISTS "Users view own orders." ON public.orders;
DROP POLICY IF EXISTS "Users can insert own orders." ON public.orders;
DROP POLICY IF EXISTS "Users can update own orders." ON public.orders;
DROP POLICY IF EXISTS "Admins see all orders" ON public.orders;

-- 3. Recreate Orders RLS policies correctly
CREATE POLICY "Users view own orders" 
ON public.orders FOR SELECT USING (auth.uid() = customer_id OR auth.uid() = provider_id OR public.is_admin());

CREATE POLICY "Users insert own orders" 
ON public.orders FOR INSERT WITH CHECK (auth.uid() = customer_id OR public.is_admin());

CREATE POLICY "Users update own orders" 
ON public.orders FOR UPDATE USING (auth.uid() = customer_id OR auth.uid() = provider_id OR public.is_admin());

-- 4. Make mmr664@gmail.com a Super Admin
-- This updates the profile role for the specific user by looking up their email in auth.users
UPDATE public.profiles
SET role = 'super_admin'
WHERE id = (SELECT id FROM auth.users WHERE email = 'mmr664@gmail.com');

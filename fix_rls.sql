CREATE OR REPLACE FUNCTION public.is_admin() RETURNS boolean AS $$$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
  );
END;
$$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE POLICY "Admins see all orders" ON public.orders FOR SELECT USING (public.is_admin());
CREATE POLICY "Admins insert orders" ON public.orders FOR INSERT WITH CHECK (public.is_admin());
CREATE POLICY "Admins update orders" ON public.orders FOR UPDATE USING (public.is_admin());
CREATE POLICY "Admins delete orders" ON public.orders FOR DELETE USING (public.is_admin());

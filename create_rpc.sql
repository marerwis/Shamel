CREATE OR REPLACE FUNCTION public.approve_provider(p_provider_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles SET status = 'active' WHERE id = p_provider_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

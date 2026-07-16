CREATE OR REPLACE FUNCTION public.admin_approve_provider(p_provider_id uuid, p_category_id uuid DEFAULT NULL)
RETURNS void AS $$
BEGIN
  -- Update provider status to active
  UPDATE public.profiles
  SET status = 'active'
  WHERE id = p_provider_id;
  
  -- Update category_id if provided
  IF p_category_id IS NOT NULL THEN
    UPDATE public.provider_details
    SET category_id = p_category_id
    WHERE id = p_provider_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

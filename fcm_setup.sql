-- 1. Add fcm_token to profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- 2. Create RPC to find available providers for a given category
CREATE OR REPLACE FUNCTION public.get_available_providers(p_category_id UUID)
RETURNS TABLE (
  provider_id UUID,
  fcm_token TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id, 
    p.fcm_token
  FROM public.profiles p
  JOIN public.provider_details pd ON pd.id = p.id
  WHERE 
    pd.category_id = p_category_id
    AND p.role = 'provider'
    AND p.status = 'active'
    AND p.fcm_token IS NOT NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

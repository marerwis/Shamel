-- Epic 5: Gamification & Retention

-- Add badges fields to profiles table
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS is_fast BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS is_clean BOOLEAN DEFAULT false;

-- Add a function for Admin to update provider badges easily
CREATE OR REPLACE FUNCTION admin_update_provider_badges(
    p_provider_id UUID,
    p_is_premium BOOLEAN,
    p_is_fast BOOLEAN,
    p_is_clean BOOLEAN
)
RETURNS VOID AS $$
BEGIN
    UPDATE public.profiles
    SET 
        is_premium = p_is_premium,
        is_fast = p_is_fast,
        is_clean = p_is_clean
    WHERE id = p_provider_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

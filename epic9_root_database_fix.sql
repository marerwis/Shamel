-- Epic 9: Root Database Fix
-- Add missing columns to requests table and update accept_direct_request RPC

-- 1. Add missing columns to public.requests
ALTER TABLE public.requests ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE public.requests ADD COLUMN IF NOT EXISTS scheduled_at TIMESTAMPTZ;
ALTER TABLE public.requests ADD COLUMN IF NOT EXISTS notes TEXT;

-- 2. Update the RPC function to correctly map data from requests to orders
CREATE OR REPLACE FUNCTION public.accept_direct_request(p_request_id UUID, p_provider_id UUID)
RETURNS boolean AS $$
DECLARE
    v_user_id UUID;
    v_service_id UUID;
    v_price NUMERIC(10,2);
    v_address TEXT;
    v_scheduled_at TIMESTAMPTZ;
    v_notes TEXT;
BEGIN
    UPDATE public.requests
    SET status = 'Accepted'
    WHERE id = p_request_id AND status = 'Pending_Broadcast'
    RETURNING user_id, service_id, COALESCE(price, 0), address, scheduled_at, notes
    INTO v_user_id, v_service_id, v_price, v_address, v_scheduled_at, v_notes;

    IF FOUND THEN
        -- Insert into orders using data extracted from requests
        INSERT INTO public.orders (id, user_id, provider_id, service_id, status, total_amount, address, scheduled_at, notes, created_at)
        VALUES (p_request_id, v_user_id, p_provider_id, v_service_id, 'accepted', v_price, v_address, v_scheduled_at, v_notes, now())
        ON CONFLICT (id) DO NOTHING;
        
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

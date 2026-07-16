-- Update requests table to include price and service_id
ALTER TABLE public.requests ADD COLUMN IF NOT EXISTS price NUMERIC(10,2) DEFAULT 0;
ALTER TABLE public.requests ADD COLUMN IF NOT EXISTS service_id UUID REFERENCES public.services(id);

-- Update RPC to use the price from the requests table
CREATE OR REPLACE FUNCTION public.accept_direct_request(p_request_id UUID, p_provider_id UUID)
RETURNS boolean AS $$
DECLARE
    affected_rows INT;
    v_user_id UUID;
    v_scheduled_date DATE;
    v_scheduled_time TIME;
    v_category_id UUID;
    v_price NUMERIC(10,2);
BEGIN
    UPDATE public.requests
    SET status = 'Accepted', provider_id = p_provider_id
    WHERE id = p_request_id AND status = 'Pending_Broadcast'
    RETURNING user_id, scheduled_date, scheduled_time, category_id, COALESCE(price, 0)
    INTO v_user_id, v_scheduled_date, v_scheduled_time, v_category_id, v_price;

    IF FOUND THEN
        -- Insert into orders automatically
        INSERT INTO public.orders (id, user_id, provider_id, status, total_amount, created_at, category_id, scheduled_date, scheduled_time)
        VALUES (p_request_id, v_user_id, p_provider_id, 'Pending', v_price, now(), v_category_id, v_scheduled_date, v_scheduled_time)
        ON CONFLICT (id) DO NOTHING;
        
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Epic 13: Remove Scheduled Date/Time completely from the database roots

-- 1. Remove scheduled_at column from requests and orders to avoid any future constraints or errors
ALTER TABLE public.requests DROP COLUMN IF EXISTS scheduled_at;
ALTER TABLE public.requests DROP COLUMN IF EXISTS scheduled_date;
ALTER TABLE public.requests DROP COLUMN IF EXISTS scheduled_time;

ALTER TABLE public.orders DROP COLUMN IF EXISTS scheduled_at;
ALTER TABLE public.orders DROP COLUMN IF EXISTS scheduled_date;
ALTER TABLE public.orders DROP COLUMN IF EXISTS scheduled_time;

-- 2. Update the accept_direct_request RPC to NOT read or write scheduled_at
CREATE OR REPLACE FUNCTION public.accept_direct_request(p_request_id UUID, p_provider_id UUID)
RETURNS boolean AS $$
DECLARE
    v_user_id UUID;
    v_service_id UUID;
    v_price NUMERIC(10,2);
    v_address TEXT;
    v_notes TEXT;
BEGIN
    -- 1. تحديث حالة الطلب إلى Accepted
    UPDATE public.requests
    SET status = 'Accepted'
    WHERE id = p_request_id AND status = 'Pending_Broadcast'
    RETURNING user_id, service_id, COALESCE(price, 0), address, notes
    INTO v_user_id, v_service_id, v_price, v_address, v_notes;

    IF FOUND THEN
        -- 2. إدراج الطلب في جدول orders بالأسماء الصحيحة وبدون التاريخ
        INSERT INTO public.orders (
            request_id, 
            user_id, 
            provider_id, 
            service_id, 
            status, 
            price, 
            address, 
            notes, 
            created_at
        )
        VALUES (
            p_request_id, 
            v_user_id, 
            p_provider_id, 
            v_service_id, 
            'accepted', 
            v_price, 
            v_address, 
            v_notes, 
            now()
        );
        
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

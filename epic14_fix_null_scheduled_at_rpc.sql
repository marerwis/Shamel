-- Epic 14: Fix Accept Direct Request RPC for Old Requests with NULL scheduled_at

-- الدالة السابقة كانت تفشل لأن الطلبات القديمة كان عمود scheduled_at فيها فارغاً (null)،
-- وجدول orders يرفض القيم الفارغة في هذا العمود.
-- الحل: إضافة COALESCE(scheduled_at, now()) لضمان إدخال التاريخ الحالي إذا كان الطلب القديم لا يحتوي على تاريخ.

CREATE OR REPLACE FUNCTION public.accept_direct_request(p_request_id UUID, p_provider_id UUID)
RETURNS boolean AS $$
DECLARE
    v_user_id UUID;
    v_scheduled_at TIMESTAMPTZ;
    v_service_id UUID;
    v_price NUMERIC(10,2);
    v_address TEXT;
    v_notes TEXT;
BEGIN
    -- 1. تحديث حالة الطلب إلى Accepted وجلب البيانات
    UPDATE public.requests
    SET status = 'Accepted'
    WHERE id = p_request_id AND status = 'Pending_Broadcast'
    RETURNING user_id, scheduled_at, service_id, COALESCE(price, 0), address, notes
    INTO v_user_id, v_scheduled_at, v_service_id, v_price, v_address, v_notes;

    IF FOUND THEN
        -- 2. إدراج الطلب في جدول orders 
        -- استخدام COALESCE لضمان عدم إرسال null إلى جدول orders حتى لو كان الطلب قديماً
        INSERT INTO public.orders (
            request_id, 
            user_id, 
            provider_id, 
            service_id, 
            status, 
            price, 
            address, 
            scheduled_at, 
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
            COALESCE(v_scheduled_at, now()), -- السر هنا!
            v_notes, 
            now()
        );
        
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

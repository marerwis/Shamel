-- Epic 12: Fix accept_direct_request RPC & Wallet Balance Calculation

-- 1. إصلاح دالة قبول الطلب لتطابق أسماء الأعمدة الحقيقية في القاعدة (لا يوجد scheduled_date بل scheduled_at)
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
    -- 1. تحديث حالة الطلب إلى Accepted
    UPDATE public.requests
    SET status = 'Accepted'
    WHERE id = p_request_id AND status = 'Pending_Broadcast'
    RETURNING user_id, scheduled_at, service_id, COALESCE(price, 0), address, notes
    INTO v_user_id, v_scheduled_at, v_service_id, v_price, v_address, v_notes;

    IF FOUND THEN
        -- 2. إدراج الطلب في جدول orders بالأسماء الصحيحة
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
            v_scheduled_at, 
            v_notes, 
            now()
        );
        
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 2. تصحيح احتساب الرصيد ليتضمن (admin_credit)
-- لاحظت في الصورة أن السي بانل القديم كان يضع 'admin_credit' بدلاً من 'credit'، لذا لم يتم احتسابه!
INSERT INTO public.wallets (user_id, balance)
SELECT 
    user_id,
    COALESCE(SUM(CASE WHEN transaction_type LIKE '%credit%' THEN amount ELSE 0 END), 0) - 
    COALESCE(SUM(CASE WHEN transaction_type LIKE '%debit%' THEN amount ELSE 0 END), 0) as calculated_balance
FROM public.wallet_transactions
GROUP BY user_id
ON CONFLICT (user_id) DO UPDATE
SET balance = EXCLUDED.balance;

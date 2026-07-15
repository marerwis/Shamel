-- Epic 4: Financials & Admin Wallet

-- 1. App Settings Table (Key-Value pair)
CREATE TABLE IF NOT EXISTS public.app_settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Insert default commission settings
INSERT INTO public.app_settings (key, value, description)
VALUES 
    ('commission_rates', '{"default_rate": 0.10, "premium_rate": 0.05}', 'نسبة عمولة التطبيق العادية وللمميزين')
ON CONFLICT (key) DO NOTHING;

-- RLS for App Settings
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read app settings" ON public.app_settings FOR SELECT USING (true);
CREATE POLICY "Only admins can update app settings" ON public.app_settings
    FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- 2. Add is_premium to profiles if not exists
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS is_premium BOOLEAN DEFAULT false;

-- 3. Admin Wallet Table
CREATE TABLE IF NOT EXISTS public.admin_wallet (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    total_revenue NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Initialize admin wallet if empty
INSERT INTO public.admin_wallet (total_revenue)
SELECT 0.0 WHERE NOT EXISTS (SELECT 1 FROM public.admin_wallet);

-- RLS for Admin Wallet
ALTER TABLE public.admin_wallet ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Only admins can read admin wallet" ON public.admin_wallet
    FOR SELECT USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- 4. Withdrawal Requests Table
CREATE TABLE IF NOT EXISTS public.withdrawal_requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    provider_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    bank_name TEXT NOT NULL,
    iban TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Pending', -- Pending, Approved, Rejected
    admin_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS for Withdrawal Requests
ALTER TABLE public.withdrawal_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Providers can view own withdrawal requests" ON public.withdrawal_requests
    FOR SELECT USING (auth.uid() = provider_id);
CREATE POLICY "Admins can view all withdrawal requests" ON public.withdrawal_requests
    FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- 5. Updated RPC for release_milestone_payment with dynamic commission
CREATE OR REPLACE FUNCTION release_milestone_payment(
    p_milestone_id UUID,
    p_order_id UUID,
    p_amount NUMERIC,
    p_provider_id UUID
)
RETURNS VOID AS $$
DECLARE
    v_is_premium BOOLEAN;
    v_commission_rate NUMERIC;
    v_commission_amount NUMERIC;
    v_provider_net NUMERIC;
    v_rates JSONB;
BEGIN
    -- 1. Check if milestone is already paid
    IF EXISTS (SELECT 1 FROM public.order_milestones WHERE id = p_milestone_id AND status = 'Paid') THEN
        RAISE EXCEPTION 'هذه الدفعة تم سدادها مسبقاً.';
    END IF;

    -- 2. Mark milestone as Paid
    UPDATE public.order_milestones SET status = 'Paid' WHERE id = p_milestone_id;

    -- 3. Get provider's premium status
    SELECT is_premium INTO v_is_premium FROM public.profiles WHERE id = p_provider_id;

    -- 4. Get dynamic commission rates
    SELECT value INTO v_rates FROM public.app_settings WHERE key = 'commission_rates';
    
    IF v_is_premium THEN
        v_commission_rate := (v_rates->>'premium_rate')::NUMERIC;
    ELSE
        v_commission_rate := (v_rates->>'default_rate')::NUMERIC;
    END IF;

    -- 5. Calculate amounts
    v_commission_amount := ROUND(p_amount * v_commission_rate, 2);
    v_provider_net := p_amount - v_commission_amount;

    -- 6. Update customer's pending balance
    UPDATE public.wallets
    SET pending_balance = pending_balance - p_amount
    WHERE user_id = (SELECT customer_id FROM public.orders WHERE id = p_order_id);

    -- 7. Add net amount to provider's wallet
    INSERT INTO public.wallets (user_id, balance, pending_balance)
    VALUES (p_provider_id, v_provider_net, 0.0)
    ON CONFLICT (user_id) 
    DO UPDATE SET balance = public.wallets.balance + v_provider_net;

    -- 8. Add commission to Admin Wallet
    UPDATE public.admin_wallet SET total_revenue = total_revenue + v_commission_amount;

    -- 9. Release from escrow
    INSERT INTO public.escrow_transactions (order_id, amount, status)
    VALUES (p_order_id, p_amount, 'Released');

    -- 10. If all milestones are Paid, mark Order as Completed
    IF NOT EXISTS (SELECT 1 FROM public.order_milestones WHERE order_id = p_order_id AND status = 'Pending') THEN
        UPDATE public.orders SET status = 'Completed' WHERE id = p_order_id;
    END IF;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. RPC for Provider to request withdrawal
CREATE OR REPLACE FUNCTION request_withdrawal(
    p_amount NUMERIC,
    p_bank_name TEXT,
    p_iban TEXT
)
RETURNS VOID AS $$
DECLARE
    v_provider_id UUID;
    v_balance NUMERIC;
BEGIN
    v_provider_id := auth.uid();

    -- Check balance
    SELECT balance INTO v_balance FROM public.wallets WHERE user_id = v_provider_id;
    IF v_balance < p_amount THEN
        RAISE EXCEPTION 'الرصيد غير كافٍ.';
    END IF;

    -- Deduct from balance and move to pending (so they can't double-spend)
    UPDATE public.wallets
    SET balance = balance - p_amount,
        pending_balance = pending_balance + p_amount
    WHERE user_id = v_provider_id;

    -- Insert request
    INSERT INTO public.withdrawal_requests (provider_id, amount, bank_name, iban, status)
    VALUES (v_provider_id, p_amount, p_bank_name, p_iban, 'Pending');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. RPC for Admin to handle withdrawal request
CREATE OR REPLACE FUNCTION admin_handle_withdrawal(
    p_request_id UUID,
    p_status TEXT -- 'Approved' or 'Rejected'
)
RETURNS VOID AS $$
DECLARE
    v_req RECORD;
BEGIN
    SELECT * INTO v_req FROM public.withdrawal_requests WHERE id = p_request_id;
    
    IF v_req.status != 'Pending' THEN
        RAISE EXCEPTION 'الطلب تمت معالجته مسبقاً.';
    END IF;

    IF p_status = 'Approved' THEN
        -- Simply remove from pending_balance since it's paid out externally
        UPDATE public.wallets
        SET pending_balance = pending_balance - v_req.amount
        WHERE user_id = v_req.provider_id;

        UPDATE public.withdrawal_requests SET status = 'Approved' WHERE id = p_request_id;
    ELSIF p_status = 'Rejected' THEN
        -- Return to balance
        UPDATE public.wallets
        SET balance = balance + v_req.amount,
            pending_balance = pending_balance - v_req.amount
        WHERE user_id = v_req.provider_id;

        UPDATE public.withdrawal_requests SET status = 'Rejected' WHERE id = p_request_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


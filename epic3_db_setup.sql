-- Epic 3: Wallet & Escrow
-- 1. Create Wallets Table
CREATE TABLE IF NOT EXISTS public.wallets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE,
    balance NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
    pending_balance NUMERIC(10, 2) NOT NULL DEFAULT 0.0, -- Amount in escrow
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Wallet Trigger
CREATE TRIGGER update_wallets_updated_at
    BEFORE UPDATE ON public.wallets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLS for Wallets
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own wallet" ON public.wallets
    FOR SELECT USING (auth.uid() = user_id);

-- 2. Create Orders Table
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    request_id UUID NOT NULL REFERENCES public.requests(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.profiles(id),
    provider_id UUID NOT NULL REFERENCES public.profiles(id),
    bid_id UUID NOT NULL REFERENCES public.bids(id),
    total_amount NUMERIC(10, 2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'Escrow_Locked', -- Escrow_Locked, In_Progress, Disputed, Completed, Cancelled
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS for Orders
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Customers can view their orders" ON public.orders
    FOR SELECT USING (auth.uid() = customer_id);
CREATE POLICY "Providers can view their orders" ON public.orders
    FOR SELECT USING (auth.uid() = provider_id);
CREATE POLICY "Admins can view all orders" ON public.orders
    FOR SELECT USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- 3. Create Order Milestones Table (for 3-part payments)
CREATE TABLE IF NOT EXISTS public.order_milestones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    milestone_number INT NOT NULL, -- 1, 2, 3
    description TEXT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'Pending', -- Pending, Paid
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS for Milestones
ALTER TABLE public.order_milestones ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Customers can view milestones of their orders" ON public.order_milestones
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND o.customer_id = auth.uid())
    );
CREATE POLICY "Providers can view milestones of their orders" ON public.order_milestones
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND o.provider_id = auth.uid())
    );

-- 4. Create Escrow Transactions Table
CREATE TABLE IF NOT EXISTS public.escrow_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'Held', -- Held, Released, Refunded
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS for Escrow
ALTER TABLE public.escrow_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Customers can view escrow of their orders" ON public.escrow_transactions
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND o.customer_id = auth.uid())
    );
CREATE POLICY "Providers can view escrow of their orders" ON public.escrow_transactions
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND o.provider_id = auth.uid())
    );
CREATE POLICY "Admins can view escrow" ON public.escrow_transactions
    FOR SELECT USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));


-- 5. Create Disputes Table
CREATE TABLE IF NOT EXISTS public.disputes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    raised_by UUID NOT NULL REFERENCES public.profiles(id),
    reason TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Open', -- Open, Resolved_Customer, Resolved_Provider
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger for Disputes
CREATE TRIGGER update_disputes_updated_at
    BEFORE UPDATE ON public.disputes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLS for Disputes
ALTER TABLE public.disputes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Involved parties can view dispute" ON public.disputes
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND (o.customer_id = auth.uid() OR o.provider_id = auth.uid()))
    );
CREATE POLICY "Admins can manage disputes" ON public.disputes
    FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));
-- RPC to Accept Bid, Create Order, lock Escrow, and generate Milestones
CREATE OR REPLACE FUNCTION accept_bid_and_create_order(
    p_bid_id UUID,
    p_request_id UUID,
    p_provider_id UUID,
    p_total_amount NUMERIC
)
RETURNS VOID AS $$
DECLARE
    v_customer_id UUID;
    v_order_id UUID;
    v_customer_balance NUMERIC;
BEGIN
    v_customer_id := auth.uid();

    -- 1. Check if customer has enough balance
    SELECT balance INTO v_customer_balance FROM public.wallets WHERE user_id = v_customer_id;
    IF v_customer_balance < p_total_amount THEN
        RAISE EXCEPTION 'رصيد المحفظة غير كافٍ. يرجى شحن الرصيد.';
    END IF;

    -- 2. Deduct from balance and add to pending_balance
    UPDATE public.wallets
    SET balance = balance - p_total_amount,
        pending_balance = pending_balance + p_total_amount
    WHERE user_id = v_customer_id;

    -- 3. Mark Bid and Request as Accepted, Reject other bids
    UPDATE public.bids SET status = 'Accepted' WHERE id = p_bid_id;
    UPDATE public.bids SET status = 'Rejected' WHERE request_id = p_request_id AND id != p_bid_id;
    UPDATE public.requests SET status = 'Accepted' WHERE id = p_request_id;

    -- 4. Create Order
    INSERT INTO public.orders (request_id, customer_id, provider_id, bid_id, total_amount, status)
    VALUES (p_request_id, v_customer_id, p_provider_id, p_bid_id, p_total_amount, 'Escrow_Locked')
    RETURNING id INTO v_order_id;

    -- 5. Create Escrow Transaction
    INSERT INTO public.escrow_transactions (order_id, amount, status)
    VALUES (v_order_id, p_total_amount, 'Held');

    -- 6. Create Milestones (3 equal parts for simplicity)
    INSERT INTO public.order_milestones (order_id, milestone_number, description, amount)
    VALUES 
        (v_order_id, 1, 'الدفعة الأولى (مقدمة)', ROUND(p_total_amount / 3.0, 2)),
        (v_order_id, 2, 'الدفعة الثانية (أثناء العمل)', ROUND(p_total_amount / 3.0, 2)),
        (v_order_id, 3, 'الدفعة الأخيرة (عند التسليم)', p_total_amount - (ROUND(p_total_amount / 3.0, 2) * 2));

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- Function to automatically create a wallet for a new user if they don't have one
-- This will run whenever we need to check, or we can just trigger it on profile creation.
-- Since profiles might already exist, let's just create an RPC to initialize a wallet for the current user.
CREATE OR REPLACE FUNCTION initialize_my_wallet()
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.wallets (user_id, balance, pending_balance)
    VALUES (auth.uid(), 1000.00, 0.0) -- Give 1000 mock balance for testing
    ON CONFLICT (user_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- Epic 2 & 3: Bidding, Negotiation, Wallet, Escrow, and Disputes
-- ==============================================================================

-- 1. Temporary Blocks Table
CREATE TABLE IF NOT EXISTS public.temporary_blocks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    provider_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    request_id UUID REFERENCES public.requests(id) ON DELETE CASCADE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.temporary_blocks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view blocks related to them" ON public.temporary_blocks
    FOR SELECT USING (auth.uid() = user_id OR auth.uid() = provider_id);
CREATE POLICY "Admins can manage blocks" ON public.temporary_blocks
    FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- 2. Escrow Transactions (For milestone payments)
CREATE TABLE IF NOT EXISTS public.escrow_transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id),
    provider_id UUID REFERENCES public.profiles(id),
    total_amount DECIMAL(12, 2) NOT NULL,
    amount_released DECIMAL(12, 2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'locked' CHECK (status IN ('locked', 'partially_released', 'fully_released', 'refunded', 'disputed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.escrow_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Participants can view escrow" ON public.escrow_transactions
    FOR SELECT USING (auth.uid() = user_id OR auth.uid() = provider_id);
CREATE POLICY "Admins can manage escrow" ON public.escrow_transactions
    FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- 3. Disputes
CREATE TABLE IF NOT EXISTS public.disputes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
    raised_by UUID REFERENCES public.profiles(id),
    reason TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'open' CHECK (status IN ('open', 'investigating', 'resolved_customer', 'resolved_provider', 'split')),
    admin_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE
);

ALTER TABLE public.disputes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Participants can view their disputes" ON public.disputes
    FOR SELECT USING (
        auth.uid() = raised_by OR 
        auth.uid() IN (SELECT user_id FROM public.orders WHERE id = order_id) OR
        auth.uid() IN (SELECT provider_id FROM public.orders WHERE id = order_id)
    );
CREATE POLICY "Participants can create disputes" ON public.disputes
    FOR INSERT WITH CHECK (
        auth.uid() = raised_by
    );
CREATE POLICY "Admins can manage disputes" ON public.disputes
    FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- 4. RPC: Accept Bid & Lock Escrow
-- Replaces old accept_bid_and_create_order to include escrow logic
CREATE OR REPLACE FUNCTION accept_bid_and_lock_escrow(
    p_bid_id UUID,
    p_request_id UUID,
    p_provider_id UUID,
    p_total_amount DECIMAL
) RETURNS UUID AS $$
DECLARE
    v_order_id UUID;
    v_user_id UUID;
BEGIN
    -- Get user ID
    SELECT user_id INTO v_user_id FROM public.requests WHERE id = p_request_id;
    
    -- Verify user has enough balance (if we are enforcing wallet balance)
    -- For now, we assume balance is handled via payment gateway, but if wallet:
    -- IF (SELECT balance FROM profiles WHERE id = v_user_id) < p_total_amount THEN
    --    RAISE EXCEPTION 'Insufficient wallet balance';
    -- END IF;

    -- Update bid and request
    UPDATE public.bids SET status = 'Accepted' WHERE id = p_bid_id;
    UPDATE public.bids SET status = 'Rejected' WHERE request_id = p_request_id AND id != p_bid_id;
    UPDATE public.requests SET status = 'In_Progress', assigned_to = p_provider_id WHERE id = p_request_id;

    -- Create order
    INSERT INTO public.orders (request_id, user_id, provider_id, status, total_amount)
    VALUES (p_request_id, v_user_id, p_provider_id, 'Pending', p_total_amount)
    RETURNING id INTO v_order_id;

    -- Lock funds in Escrow
    INSERT INTO public.escrow_transactions (order_id, user_id, provider_id, total_amount, status)
    VALUES (v_order_id, v_user_id, p_provider_id, p_total_amount, 'locked');

    -- Deduct from user wallet (Optional based on business logic)
    INSERT INTO public.wallet_transactions (user_id, amount, transaction_type, order_id)
    VALUES (v_user_id, -p_total_amount, 'payment', v_order_id);

    RETURN v_order_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

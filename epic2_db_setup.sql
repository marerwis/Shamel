-- Epic 2: Bidding & Negotiation
-- 1. Create Bids Table
CREATE TABLE IF NOT EXISTS public.bids (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    request_id UUID NOT NULL REFERENCES public.requests(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    price NUMERIC(10, 2) NOT NULL,
    net_profit NUMERIC(10, 2) NOT NULL, -- The amount the provider gets after commission
    status TEXT NOT NULL DEFAULT 'Pending', -- Pending, Accepted, Rejected
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(request_id, provider_id) -- A provider can only bid once per request
);

-- RLS for Bids
ALTER TABLE public.bids ENABLE ROW LEVEL SECURITY;

-- Customer can see bids on their own requests
CREATE POLICY "Customers can view bids on their requests" ON public.bids
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.requests r
            WHERE r.id = bids.request_id AND r.customer_id = auth.uid()
        )
    );

-- Provider can see their own bids
CREATE POLICY "Providers can view their own bids" ON public.bids
    FOR SELECT USING (auth.uid() = provider_id);

-- Provider can insert bids
CREATE POLICY "Providers can insert bids" ON public.bids
    FOR INSERT WITH CHECK (auth.uid() = provider_id);

-- Admins can view all bids
CREATE POLICY "Admins can view all bids" ON public.bids
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    );

-- Update Bids trigger
CREATE TRIGGER update_bids_updated_at
    BEFORE UPDATE ON public.bids
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


-- 2. Create Temporary Blocks Table
CREATE TABLE IF NOT EXISTS public.temporary_blocks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    request_id UUID REFERENCES public.requests(id) ON DELETE CASCADE,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(customer_id, provider_id)
);

-- RLS for temporary blocks
ALTER TABLE public.temporary_blocks ENABLE ROW LEVEL SECURITY;

-- Admins can do everything
CREATE POLICY "Admins can manage temporary blocks" ON public.temporary_blocks
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    );

-- Customers can insert blocks
CREATE POLICY "Customers can insert blocks" ON public.temporary_blocks
    FOR INSERT WITH CHECK (auth.uid() = customer_id);

-- Customers can view their blocks
CREATE POLICY "Customers can view their blocks" ON public.temporary_blocks
    FOR SELECT USING (auth.uid() = customer_id);

-- Providers can view blocks on them
CREATE POLICY "Providers can view blocks on them" ON public.temporary_blocks
    FOR SELECT USING (auth.uid() = provider_id);

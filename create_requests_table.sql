-- Epic 1: Task 1.1 - Create requests table
CREATE TABLE IF NOT EXISTS public.requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    images JSONB DEFAULT '[]'::jsonb, -- Store list of image URLs
    status TEXT NOT NULL DEFAULT 'Pending_Broadcast', -- Pending_Broadcast, Accepted, Completed, Cancelled
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Row Level Security (RLS)
ALTER TABLE public.requests ENABLE ROW LEVEL SECURITY;

-- Customers can view their own requests
CREATE POLICY "Customers can view own requests" ON public.requests
    FOR SELECT USING (auth.uid() = customer_id);

-- Customers can create requests
CREATE POLICY "Customers can create requests" ON public.requests
    FOR INSERT WITH CHECK (auth.uid() = customer_id);

-- Admins can view all requests
CREATE POLICY "Admins can view all requests" ON public.requests
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    );

-- Providers can view Pending_Broadcast requests in their category
-- This policy allows providers to see requests broadcasted to them
CREATE POLICY "Providers can view broadcasted requests" ON public.requests
    FOR SELECT USING (
        status = 'Pending_Broadcast' AND
        EXISTS (
            SELECT 1 FROM public.provider_details 
            WHERE provider_details.id = auth.uid() AND provider_details.category_id = requests.category_id
        )
    );

-- Trigger to update 'updated_at'
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_requests_updated_at ON public.requests;
CREATE TRIGGER update_requests_updated_at
    BEFORE UPDATE ON public.requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

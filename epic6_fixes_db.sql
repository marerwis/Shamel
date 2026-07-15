-- Add wallet_balance to profiles if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='profiles' AND column_name='wallet_balance') THEN
        ALTER TABLE public.profiles ADD COLUMN wallet_balance NUMERIC DEFAULT 0;
    END IF;
END $$;

-- Enable Realtime for requests, orders, and bids
DO $$
BEGIN
    ALTER TABLE public.requests REPLICA IDENTITY FULL;
    ALTER TABLE public.orders REPLICA IDENTITY FULL;
    ALTER TABLE public.bids REPLICA IDENTITY FULL;

    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'requests') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.requests;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'orders') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'bids') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.bids;
    END IF;
END $$;

-- Create storage bucket for categories if missing
INSERT INTO storage.buckets (id, name, public) 
VALUES ('categories_icons', 'categories_icons', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Drop policies if they exist so we can recreate them
DROP POLICY IF EXISTS "Public Access for Categories Icons" ON storage.objects;
DROP POLICY IF EXISTS "Auth Users Manage Categories Icons" ON storage.objects;

-- Allow public read access
CREATE POLICY "Public Access for Categories Icons" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'categories_icons');

-- Allow authenticated users to upload/update/delete (admins usually, but for simplicity allow authenticated)
CREATE POLICY "Auth Users Manage Categories Icons" 
ON storage.objects FOR ALL 
TO authenticated 
USING (bucket_id = 'categories_icons')
WITH CHECK (bucket_id = 'categories_icons');

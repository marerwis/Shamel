-- This script adds Row Level Security (RLS) policies to allow inserting and updating services

ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

-- Drop old policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "Enable read access for all users" ON public.services;
DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON public.services;
DROP POLICY IF EXISTS "Enable update access for authenticated users" ON public.services;
DROP POLICY IF EXISTS "Enable delete access for authenticated users" ON public.services;

-- 1. Allow everyone to read services
CREATE POLICY "Enable read access for all users" 
ON public.services FOR SELECT USING (true);

-- 2. Allow authenticated users (like Admin/Providers) to insert services
CREATE POLICY "Enable insert access for authenticated users" 
ON public.services FOR INSERT TO authenticated WITH CHECK (true);

-- 3. Allow authenticated users to update services
CREATE POLICY "Enable update access for authenticated users" 
ON public.services FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

-- 4. Allow authenticated users to delete services
CREATE POLICY "Enable delete access for authenticated users" 
ON public.services FOR DELETE TO authenticated USING (true);

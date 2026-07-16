
-- Enable RLS if not already enabled
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- Allow anyone (including anon) to read categories
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.categories;
CREATE POLICY "Allow anonymous read access" ON public.categories FOR SELECT USING (true);


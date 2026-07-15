ALTER TABLE public.orders DROP CONSTRAINT IF EXISTS orders_provider_id_fkey;
ALTER TABLE public.orders ADD CONSTRAINT orders_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES public.profiles(id);

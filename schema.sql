-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. Profiles Table Updates
-- Create table if it doesn't exist at all
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  full_name text,
  avatar_url text,
  phone text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Safely add 'role' and 'status' columns if they don't exist
do $$
begin
  if not exists (select 1 from information_schema.columns where table_schema='public' and table_name='profiles' and column_name='role') then
    alter table public.profiles add column role text default 'user' check (role in ('admin', 'provider', 'user'));
  end if;
  
  if not exists (select 1 from information_schema.columns where table_schema='public' and table_name='profiles' and column_name='status') then
    alter table public.profiles add column status text default 'active' check (status in ('active', 'pending', 'suspended'));
  end if;
end
$$;

-- Enable RLS
alter table public.profiles enable row level security;

-- Safely Drop existing policies to avoid duplicates
drop policy if exists "Public profiles are viewable by everyone." on profiles;
drop policy if exists "Users can insert their own profile." on profiles;
drop policy if exists "Users can update own profile." on profiles;

-- Create Policies for profiles
create policy "Public profiles are viewable by everyone." on profiles for select using (true);
create policy "Users can insert their own profile." on profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile." on profiles for update using (auth.uid() = id);

-- 1.5 Provider Details Table
drop table if exists public.provider_details cascade;
create table public.provider_details (
  id uuid references public.profiles(id) on delete cascade not null primary key,
  father_name text,
  grandfather_name text,
  id_type text check (id_type in ('national_id', 'passport')),
  id_number text,
  category_id uuid, -- Foreign key will be added later if needed, or left loose to avoid circular/hard dependency
  title text,
  id_image_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.provider_details enable row level security;
create policy "Provider details viewable by everyone." on provider_details for select using (true);
create policy "Providers can insert own details." on provider_details for insert with check (auth.uid() = id);
create policy "Providers can update own details." on provider_details for update using (auth.uid() = id);
create policy "Admins can manage provider details." on provider_details for all using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- 2. Categories Table (Hierarchy)
drop table if exists public.categories cascade;
create table public.categories (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  icon text,
  parent_id uuid references public.categories(id) on delete cascade,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.categories enable row level security;

create policy "Categories are viewable by everyone." on categories for select using (true);
create policy "Only admins can insert categories." on categories for insert with check (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);
create policy "Only admins can update categories." on categories for update using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);
create policy "Only admins can delete categories." on categories for delete using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- 3. Services Table
drop table if exists public.services cascade;
create table public.services (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  description text,
  price numeric not null default 0,
  image_url text,
  category_id uuid references public.categories(id) on delete set null,
  provider_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.services enable row level security;

create policy "Services are viewable by everyone." on services for select using (true);
create policy "Providers can insert own services." on services for insert with check (
  auth.uid() = provider_id and exists (select 1 from profiles where id = auth.uid() and role = 'provider' and status = 'active')
);
create policy "Providers can update own services." on services for update using (
  auth.uid() = provider_id
);
create policy "Providers can delete own services." on services for delete using (
  auth.uid() = provider_id
);
create policy "Admins can manage all services." on services for all using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- Trigger for new user
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, role, status)
  values (
    new.id, 
    new.raw_user_meta_data->>'full_name',
    coalesce(new.raw_user_meta_data->>'role', 'user'),
    case 
      when new.raw_user_meta_data->>'role' = 'provider' then 'pending'
      else 'active'
    end
  );
  
  -- If provider, insert into provider_details with additional metadata
  if new.raw_user_meta_data->>'role' = 'provider' then
    insert into public.provider_details (
      id, 
      father_name, 
      grandfather_name, 
      id_type, 
      id_number, 
      category_id, 
      title
    ) values (
      new.id,
      new.raw_user_meta_data->>'father_name',
      new.raw_user_meta_data->>'grandfather_name',
      new.raw_user_meta_data->>'id_type',
      new.raw_user_meta_data->>'id_number',
      (new.raw_user_meta_data->>'category_id')::uuid,
      new.raw_user_meta_data->>'title'
    );
  end if;
  
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 4. Orders Table
drop table if exists public.orders cascade;
create table public.orders (
  id uuid default uuid_generate_v4() primary key,
  customer_id uuid references public.profiles(id) on delete cascade not null,
  provider_id uuid references public.profiles(id) on delete cascade not null,
  service_id uuid references public.services(id) on delete set null,
  status text default 'pending' check (status in ('pending', 'accepted', 'rejected', 'in_progress', 'completed', 'cancelled', 'disputed')),
  price numeric not null default 0,
  address text,
  scheduled_at timestamp with time zone,
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.orders enable row level security;
create policy "Users can view own orders." on orders for select using (auth.uid() = customer_id or auth.uid() = provider_id or exists (select 1 from profiles where id = auth.uid() and role = 'admin'));
create policy "Customers can insert orders." on orders for insert with check (auth.uid() = customer_id);
create policy "Users can update own orders." on orders for update using (auth.uid() = customer_id or auth.uid() = provider_id or exists (select 1 from profiles where id = auth.uid() and role = 'admin'));

-- 5. Chats and Messages
drop table if exists public.chats cascade;
create table public.chats (
  id uuid default uuid_generate_v4() primary key,
  order_id uuid references public.orders(id) on delete cascade,
  customer_id uuid references public.profiles(id) on delete cascade not null,
  provider_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.chats enable row level security;
create policy "Users can view own chats." on chats for select using (auth.uid() = customer_id or auth.uid() = provider_id or exists (select 1 from profiles where id = auth.uid() and role = 'admin'));
create policy "Users can create chats." on chats for insert with check (auth.uid() = customer_id or auth.uid() = provider_id);

drop table if exists public.messages cascade;
create table public.messages (
  id uuid default uuid_generate_v4() primary key,
  chat_id uuid references public.chats(id) on delete cascade not null,
  sender_id uuid references public.profiles(id) on delete cascade not null,
  content text not null,
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.messages enable row level security;
create policy "Users can view messages of their chats." on messages for select using (
  exists (select 1 from chats where chats.id = messages.chat_id and (chats.customer_id = auth.uid() or chats.provider_id = auth.uid()))
  or exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);
create policy "Users can insert messages to their chats." on messages for insert with check (
  auth.uid() = sender_id and exists (select 1 from chats where chats.id = messages.chat_id and (chats.customer_id = auth.uid() or chats.provider_id = auth.uid()))
);
create policy "Users can update messages of their chats (mark read)." on messages for update using (
  exists (select 1 from chats where chats.id = messages.chat_id and (chats.customer_id = auth.uid() or chats.provider_id = auth.uid()))
);

-- 6. Wallet and Transactions
drop table if exists public.wallet_transactions cascade;
create table public.wallet_transactions (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  amount numeric not null,
  type text check (type in ('credit', 'debit')),
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.wallet_transactions enable row level security;
create policy "Users can view own transactions." on wallet_transactions for select using (auth.uid() = user_id or exists (select 1 from profiles where id = auth.uid() and role = 'admin'));
-- Only system (via functions or admin) should insert transactions in a real app, but for this MVP:
create policy "System can insert transactions." on wallet_transactions for insert with check (true);

drop table if exists public.withdrawal_requests cascade;
create table public.withdrawal_requests (
  id uuid default uuid_generate_v4() primary key,
  provider_id uuid references public.profiles(id) on delete cascade not null,
  amount numeric not null,
  status text default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.withdrawal_requests enable row level security;
create policy "Providers can view own requests." on withdrawal_requests for select using (auth.uid() = provider_id or exists (select 1 from profiles where id = auth.uid() and role = 'admin'));
create policy "Providers can insert requests." on withdrawal_requests for insert with check (auth.uid() = provider_id);
create policy "Admins can update requests." on withdrawal_requests for update using (exists (select 1 from profiles where id = auth.uid() and role = 'admin'));


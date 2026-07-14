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
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

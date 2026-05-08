-- MUHRA: منتجات + طلبات (الدفع عند الاستلام من التطبيق)
-- طبّق من Supabase → SQL → New query

create extension if not exists "pgcrypto";

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  collection_slug text not null,
  category text not null,
  price numeric(14, 2) not null,
  currency text not null default 'EUR',
  materials text[] not null default '{}',
  stones text[] not null default '{}',
  images text[] not null default '{}',
  description text not null default '',
  story text not null default '',
  related_slugs text[] not null default '{}',
  sizes text[],
  is_high_jewelry boolean not null default false,
  is_new boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  customer_name text not null,
  customer jsonb not null,
  items jsonb not null,
  subtotal numeric(14, 2) not null,
  subtotal_iqd numeric,
  shipping_fee_iqd numeric,
  total_iqd numeric,
  currency text not null,
  status text not null default 'pending',
  payment jsonb not null default '{"method":"cod"}'::jsonb
);

create index if not exists products_slug_idx on public.products (slug);
create index if not exists products_category_idx on public.products (category);
create index if not exists orders_created_idx on public.orders (created_at desc);

alter table public.products enable row level security;
alter table public.orders enable row level security;

drop policy if exists "products_public_select" on public.products;
create policy "products_public_select" on public.products for select using (true);

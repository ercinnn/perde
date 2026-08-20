-- Orders module: single table, order items embedded as JSONB
-- (no separate order_items table since items are always accessed through their parent order)

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  customer_name text not null,
  phone text not null,
  address text not null,
  order_date timestamptz not null,
  delivery_date timestamptz not null,
  delivery_type text not null default 'montaj',
  plan_time text not null default '09.00',
  items jsonb not null default '[]'::jsonb,
  deposit numeric not null default 0,
  discount numeric not null default 0,
  status text not null default 'bekliyor',
  created_at timestamptz not null default now()
);

alter table public.orders enable row level security;

-- All authenticated staff share the same order data (single-business app,
-- not multi-tenant), so policies check only that the caller is logged in.
create policy "orders_select_authenticated"
  on public.orders for select
  to authenticated
  using (true);

create policy "orders_insert_authenticated"
  on public.orders for insert
  to authenticated
  with check (true);

create policy "orders_update_authenticated"
  on public.orders for update
  to authenticated
  using (true)
  with check (true);

-- Stock module: stock items, suppliers (products embedded as JSONB,
-- always accessed through their parent supplier), and stock requests.

create table if not exists public.stock_items (
  id uuid primary key default gen_random_uuid(),
  code text not null default '',
  name text not null,
  brand text not null default '',
  category text not null default '',
  quantity numeric not null default 0,
  unit text not null default 'metre',
  min_stock numeric not null default 0,
  supplier_name text not null default '',
  purchase_price numeric not null default 0,
  description text not null default '',
  last_updated timestamptz not null default now()
);

create table if not exists public.suppliers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  contact_person text not null default '',
  phone text not null default '',
  email text not null default '',
  category text not null default '',
  address text not null default '',
  notes text not null default '',
  products jsonb not null default '[]'::jsonb
);

create table if not exists public.stock_requests (
  id uuid primary key default gen_random_uuid(),
  supplier_name text not null default '',
  product_name text not null,
  quantity numeric not null default 0,
  unit text not null default 'metre',
  delivery_date timestamptz not null,
  notes text not null default ''
);

alter table public.stock_items enable row level security;
alter table public.suppliers enable row level security;
alter table public.stock_requests enable row level security;

-- All authenticated staff share the same stock data (single-business app,
-- not multi-tenant), so policies check only that the caller is logged in.
create policy "stock_items_all_authenticated"
  on public.stock_items for all
  to authenticated
  using (true)
  with check (true);

create policy "suppliers_all_authenticated"
  on public.suppliers for all
  to authenticated
  using (true)
  with check (true);

create policy "stock_requests_all_authenticated"
  on public.stock_requests for all
  to authenticated
  using (true)
  with check (true);

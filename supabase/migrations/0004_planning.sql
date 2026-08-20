-- Planning module: weekly plan entries, pile fees, product feature price
-- add-ons, and dashboard task reminders. All flat tables.

create table if not exists public.weekly_plan_entries (
  id uuid primary key default gen_random_uuid(),
  date timestamptz not null,
  time text not null default '',
  customer_name text not null,
  description text not null default '',
  type text not null default 'montaj'
);

create table if not exists public.pile_fees (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  price numeric not null default 0
);

create table if not exists public.product_feature_prices (
  id uuid primary key default gen_random_uuid(),
  product_type text not null,
  option_name text not null,
  price numeric not null default 0,
  calc_type text not null default 'sabit'
);

create table if not exists public.task_reminders (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  due_date timestamptz,
  done boolean not null default false
);

alter table public.weekly_plan_entries enable row level security;
alter table public.pile_fees enable row level security;
alter table public.product_feature_prices enable row level security;
alter table public.task_reminders enable row level security;

-- All authenticated staff share the same planning data (single-business app,
-- not multi-tenant), so policies check only that the caller is logged in.
create policy "weekly_plan_entries_all_authenticated"
  on public.weekly_plan_entries for all
  to authenticated
  using (true)
  with check (true);

create policy "pile_fees_all_authenticated"
  on public.pile_fees for all
  to authenticated
  using (true)
  with check (true);

create policy "product_feature_prices_all_authenticated"
  on public.product_feature_prices for all
  to authenticated
  using (true)
  with check (true);

create policy "task_reminders_all_authenticated"
  on public.task_reminders for all
  to authenticated
  using (true)
  with check (true);

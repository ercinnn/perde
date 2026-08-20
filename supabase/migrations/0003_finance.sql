-- Finance module: receivables, debts, installment plans, payment reminders,
-- and cash records. All flat tables, no nested/embedded data.

create table if not exists public.receivables (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  total numeric not null default 0,
  remaining numeric not null default 0,
  due_date timestamptz not null,
  status text not null default 'bekliyor'
);

create table if not exists public.debts (
  id uuid primary key default gen_random_uuid(),
  supplier_name text not null,
  description text not null default '',
  total numeric not null default 0,
  remaining numeric not null default 0,
  due_date timestamptz not null,
  status text not null default 'bekliyor'
);

create table if not exists public.installment_plans (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  total_amount numeric not null default 0,
  installment_count integer not null default 1,
  start_date timestamptz not null
);

create table if not exists public.payment_reminders (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  due_date timestamptz not null,
  note text not null default ''
);

create table if not exists public.cash_records (
  id uuid primary key default gen_random_uuid(),
  type text not null,
  category text not null default '',
  amount numeric not null default 0,
  description text not null default '',
  time timestamptz not null
);

alter table public.receivables enable row level security;
alter table public.debts enable row level security;
alter table public.installment_plans enable row level security;
alter table public.payment_reminders enable row level security;
alter table public.cash_records enable row level security;

-- All authenticated staff share the same finance data (single-business app,
-- not multi-tenant), so policies check only that the caller is logged in.
create policy "receivables_all_authenticated"
  on public.receivables for all
  to authenticated
  using (true)
  with check (true);

create policy "debts_all_authenticated"
  on public.debts for all
  to authenticated
  using (true)
  with check (true);

create policy "installment_plans_all_authenticated"
  on public.installment_plans for all
  to authenticated
  using (true)
  with check (true);

create policy "payment_reminders_all_authenticated"
  on public.payment_reminders for all
  to authenticated
  using (true)
  with check (true);

create policy "cash_records_all_authenticated"
  on public.cash_records for all
  to authenticated
  using (true)
  with check (true);

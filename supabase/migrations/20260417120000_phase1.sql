-- Phase 1: households, members, expenses with RLS (pilot).
-- Apply in Supabase SQL Editor or via CLI. See docs/supabase_dev_setup.md

create extension if not exists "pgcrypto";

create table public.households (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'Household',
  created_at timestamptz not null default now()
);

create table public.household_members (
  household_id uuid not null references public.households (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  role text not null default 'member',
  primary key (household_id, user_id)
);

-- Cloud copy of app expenses (aligned with local Drift model + sync columns).
create table public.expenses (
  id uuid not null,
  household_id uuid not null references public.households (id) on delete cascade,
  auth_user_id uuid not null references auth.users (id) on delete cascade,
  amount_minor int not null,
  currency_code text not null,
  category_id text not null,
  budget_bucket text,
  note text,
  occurred_at bigint not null,
  created_at bigint not null,
  updated_at bigint not null,
  recurring_payment_id uuid,
  remote_id text,
  sync_status text,
  server_updated_at bigint,
  primary key (id)
);

create index expenses_household_updated on public.expenses (household_id, updated_at desc);

alter table public.households enable row level security;
alter table public.household_members enable row level security;
alter table public.expenses enable row level security;

-- Helper: households the current user belongs to.
create or replace function public.user_household_ids()
returns setof uuid
language sql
stable
security definer
set search_path = public
as $$
  select household_id from public.household_members where user_id = auth.uid();
$$;

-- households
create policy households_select_member
  on public.households for select
  using (id in (select public.user_household_ids()));

create policy households_insert_authenticated
  on public.households for insert
  with check (auth.role() = 'authenticated');

create policy households_update_member
  on public.households for update
  using (id in (select public.user_household_ids()));

-- household_members
create policy household_members_select_own
  on public.household_members for select
  using (user_id = auth.uid() or household_id in (select public.user_household_ids()));

create policy household_members_insert_self
  on public.household_members for insert
  with check (user_id = auth.uid());

create policy household_members_delete_self
  on public.household_members for delete
  using (user_id = auth.uid());

-- expenses
create policy expenses_select_member
  on public.expenses for select
  using (household_id in (select public.user_household_ids()));

create policy expenses_insert_member
  on public.expenses for insert
  with check (
    auth.uid() = auth_user_id
    and household_id in (select public.user_household_ids())
  );

create policy expenses_update_member
  on public.expenses for update
  using (household_id in (select public.user_household_ids()))
  with check (
    auth.uid() = auth_user_id
    and household_id in (select public.user_household_ids())
  );

create policy expenses_delete_member
  on public.expenses for delete
  using (household_id in (select public.user_household_ids()));

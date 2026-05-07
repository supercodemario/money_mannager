-- Household-scoped recurring payment templates and occurrences with RLS.

create table public.recurring_payments (
  id uuid not null,
  household_id uuid not null references public.households (id) on delete cascade,
  auth_user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  category_id text not null,
  amount_minor_suggested int not null,
  currency_code text not null,
  day_of_month int not null,
  end_month_key text,
  is_enabled boolean not null default true,
  is_deleted boolean not null default false,
  created_at bigint not null,
  updated_at bigint not null,
  remote_id text,
  sync_status text,
  server_updated_at bigint,
  primary key (id)
);

create table public.recurring_payment_occurrences (
  id uuid not null,
  household_id uuid not null references public.households (id) on delete cascade,
  recurring_payment_id uuid not null references public.recurring_payments (id) on delete cascade,
  month_key text not null,
  expense_id uuid references public.expenses (id) on delete set null,
  is_deleted boolean not null default false,
  created_at bigint not null,
  updated_at bigint not null,
  remote_id text,
  sync_status text,
  server_updated_at bigint,
  primary key (id),
  unique (household_id, recurring_payment_id, month_key)
);

create index recurring_payments_household_updated on public.recurring_payments (household_id, updated_at desc);
create index recurring_payment_occurrences_household_updated on public.recurring_payment_occurrences (household_id, updated_at desc);
create index recurring_payment_occurrences_template_month on public.recurring_payment_occurrences (recurring_payment_id, month_key);

alter table public.recurring_payments enable row level security;
alter table public.recurring_payment_occurrences enable row level security;

create policy recurring_payments_select_member
  on public.recurring_payments for select
  using (household_id in (select public.user_household_ids()));

create policy recurring_payments_insert_member
  on public.recurring_payments for insert
  with check (
    auth.uid() = auth_user_id
    and household_id in (select public.user_household_ids())
  );

create policy recurring_payments_update_member
  on public.recurring_payments for update
  using (household_id in (select public.user_household_ids()))
  with check (
    auth.uid() = auth_user_id
    and household_id in (select public.user_household_ids())
  );

create policy recurring_payments_delete_member
  on public.recurring_payments for delete
  using (household_id in (select public.user_household_ids()));

create policy recurring_payment_occurrences_select_member
  on public.recurring_payment_occurrences for select
  using (household_id in (select public.user_household_ids()));

create policy recurring_payment_occurrences_insert_member
  on public.recurring_payment_occurrences for insert
  with check (household_id in (select public.user_household_ids()));

create policy recurring_payment_occurrences_update_member
  on public.recurring_payment_occurrences for update
  using (household_id in (select public.user_household_ids()))
  with check (household_id in (select public.user_household_ids()));

create policy recurring_payment_occurrences_delete_member
  on public.recurring_payment_occurrences for delete
  using (household_id in (select public.user_household_ids()));

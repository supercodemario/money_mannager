-- Auth-user scoped expense profile preferences with RLS.

create table public.expense_profile_preferences (
  auth_user_id uuid primary key references auth.users (id) on delete cascade,
  monthly_income_minor int,
  monthly_savings_minor int,
  exclude_unpaid_recurring boolean not null default false,
  updated_at bigint not null,
  sync_status text,
  server_updated_at bigint
);

alter table public.expense_profile_preferences enable row level security;

create policy expense_profile_preferences_select_own
  on public.expense_profile_preferences for select
  using (auth_user_id = auth.uid());

create policy expense_profile_preferences_insert_own
  on public.expense_profile_preferences for insert
  with check (auth_user_id = auth.uid());

create policy expense_profile_preferences_update_own
  on public.expense_profile_preferences for update
  using (auth_user_id = auth.uid())
  with check (auth_user_id = auth.uid());

create policy expense_profile_preferences_delete_own
  on public.expense_profile_preferences for delete
  using (auth_user_id = auth.uid());

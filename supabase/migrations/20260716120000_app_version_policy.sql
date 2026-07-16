-- Force-update policy: public read of minimum Android build (anon + authenticated).
-- Ops: ship the Play build first, then raise min_build. Never set min_build above a live store build.
-- See openspec/changes/android-force-update-min-build/ops.md

create table public.app_version_policy (
  platform text primary key,
  min_build int not null check (min_build >= 1),
  store_url text not null,
  message text,
  updated_at timestamptz not null default now()
);

alter table public.app_version_policy enable row level security;

create policy app_version_policy_select_public
  on public.app_version_policy
  for select
  to anon, authenticated
  using (true);

-- Seed Android with min_build=1 so existing installs are not forced until ops raises it.
insert into public.app_version_policy (platform, min_build, store_url, message)
values (
  'android',
  1,
  'https://play.google.com/store/apps/details?id=com.nexkind.homelybudget',
  null
);

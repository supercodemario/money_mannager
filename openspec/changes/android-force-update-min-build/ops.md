# Force-update ops (Android)

## Raise the minimum build

1. Bump `pubspec.yaml` build number (`x.y.z+N`) and ship a Play Store release.
2. Wait until that build is available on Play for users.
3. In Supabase, update the Android policy row:

```sql
update public.app_version_policy
set min_build = <new_version_code>,
    updated_at = now()
where platform = 'android';
```

4. Never set `min_build` higher than a build that is live on Play.

## Lower / rollback

```sql
update public.app_version_policy
set min_build = <previous_or_1>,
    updated_at = now()
where platform = 'android';
```

## Optional message

```sql
update public.app_version_policy
set message = 'Please update to continue using homeRatio.',
    updated_at = now()
where platform = 'android';
```

Empty/`null` message → app shows default `AppStrings` copy.

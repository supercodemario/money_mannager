# Remote layer (`lib/data/remote`)

Supabase **data** and **auth** wrappers used only from `lib/sync/`, `lib/app/`, and bootstrap — **not** from `lib/features/`.

Feature screens talk to repositories and `CloudSyncController` via `AppServices`; repositories write to Drift; the sync orchestrator reacts to pending rows and calls this layer.

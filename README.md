# money_manager

A new Flutter project.

## Supabase (optional cloud sync)

Phase-1 sync uses [Supabase](https://supabase.com/) when credentials are provided at **compile time** (no `.env` in repo).

1. Copy `supabase.env.example` and fill in URL + anon key from the Supabase dashboard (**do not commit** real keys).
2. Run / build with defines, for example:

   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
   ```

3. Apply SQL from `supabase/migrations/` in the Supabase SQL editor (see `docs/supabase_dev_setup.md`).

Without these defines, the app runs **local-only** as before; Settings shows a short “not configured” message under **Cloud sync**.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

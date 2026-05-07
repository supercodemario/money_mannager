## 1. Setup

- [x] 1.1 Create `shell` feature folder structure (`bloc/`, `data/`, `models/`, `routes/`, `view/`) for bottom navigation
- [x] 1.2 Add/confirm shared string tokens for tab labels in `lib/share/tokens/app_strings.dart`

## 2. Bottom navigation UI

- [x] 2.1 Implement token-driven glass bottom navigation bar (blur + translucent surface + soft ambient shadow)
- [x] 2.2 Implement active tab styling (highlighted tile/gradient) and prominent center “Add” item

## 3. Shell integration

- [x] 3.1 Implement shell widget using `IndexedStack` to preserve tab state
- [x] 3.2 Wire app entrypoint to launch into the shell as the home experience

## 4. Verification

- [x] 4.1 Update widget tests to validate the app boots and the bottom nav is present
- [x] 4.2 Run `flutter test` and fix any regressions


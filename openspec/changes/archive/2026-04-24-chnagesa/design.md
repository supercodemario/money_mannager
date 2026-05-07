## Context

The add/edit recurring template screen (`AddRecurringPaymentScreen`) used `Scaffold` (default `resizeToAvoidBottomInset: true`) plus an `AnimatedPadding` whose bottom padding equaled `MediaQuery.viewInsetsOf(context).bottom`. That stacks the IME inset twice inside the subtree, producing a tall empty region above the keyboard on real hardware.

## Goals / Non-Goals

**Goals:**

- Apply the keyboard inset **once** so the scrollable body height matches the visible area above the IME.
- Preserve `SafeArea` and a single `ListView` for the form so users can scroll to every field while the keyboard is open.
- Avoid introducing app-wide `MaterialApp` or theme changes.

**Non-Goals:**

- Redesigning the recurring form, changing validation, or altering persistence.
- Standardizing every other screen’s keyboard handling (no cross-app refactor unless a follow-up change).

## Decisions

1. **Rely on default `Scaffold` resize for this screen**  
   **Rationale:** It is the framework default and matches the rest of the app (no global `resizeToAvoidBottomInset: false`).  
   **Alternative considered:** `resizeToAvoidBottomInset: false` on this `Scaffold` plus manual `viewInsets` padding — valid but adds a second pattern and is unnecessary here.

2. **Remove `AnimatedPadding` tied to `viewInsets`**  
   **Rationale:** Eliminates duplicate inset; `ListView` + default text-field scroll behavior is sufficient.  
   **Alternative considered:** Keep animation by padding with zero when using only scaffold resize — adds complexity without clear benefit.

## Risks / Trade-offs

- **[Risk] Focused field slightly clipped on unusual IME sizes** → **Mitigation:** `ListView` remains scrollable; `TextField` default `scrollPadding` still applies; re-test on iOS and Android.
- **[Risk] Future contributor re-adds `viewInsets` padding** → **Mitigation:** Recurring-payments spec requirement documents the single-inset expectation.

## Migration Plan

- None (UI-only; no schema or API migration).

## Open Questions

- None.

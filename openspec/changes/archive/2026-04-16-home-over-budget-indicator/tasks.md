## 1. Over-budget state detection and derived values

- [x] 1.1 Add explicit over-budget boolean/derived values in Home monthly spending card from existing spent vs spendable data.
- [x] 1.2 Compute and expose exceeded amount and exceeded percent values for over-budget state, with safe guards for unset/zero spendable guidance.

## 2. Home card UX and visual warning treatment

- [x] 2.1 Update status chip/content to show over-budget wording when spent exceeds guidance.
- [x] 2.2 Update monthly progress section to show warning red styling and include exceeded percent/amount messaging.
- [x] 2.3 Update monthly balance row to switch between remaining and overspent labels and show overspent amount in red when exceeded.

## 3. Strings and validation

- [x] 3.1 Add/update string tokens for over-budget and exceeded messaging (including meaningful savings label text).
- [x] 3.2 Keep non-exceed and limits-unset flows unchanged and verify copy remains coherent.

## 4. Verification

- [x] 4.1 Run `dart analyze` on touched dashboard and token files.
- [x] 4.2 Manually sanity-check Home card states: limits unset, on-track, and over-budget.

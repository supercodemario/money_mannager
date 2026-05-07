## Why

The current limits detail screen is functionally correct but does not match the approved Stitch v3 visual and interaction design. The mismatch reduces perceived quality and creates inconsistency with the product’s intended design language.

## What Changes

- Build a new limits detail screen presentation aligned to Stitch screen `Refined Expense Limits v3 (Percentage Goal)`.
- Include a repeatable Stitch asset retrieval step (download screenshot + HTML with `curl -L`) to ground implementation against the source design.
- Restructure the limits UI into Stitch v3 sections: prominent income card, side-by-side spendable summary cards, savings goal card with percentage goal interaction, recurring subtraction card, and updated save CTA.
- Keep existing limits persistence and calculation behavior intact while refining visual hierarchy and user interactions.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `expense-limits`: Refine limits detail screen presentation and interactions to match Stitch v3 while preserving guidance-only semantics and existing persistence behavior.

## Impact

- Affected code: `lib/features/settings/view/expense_limits_screen.dart` and potentially shared UI tokens/widgets used by this screen.
- Design references: Stitch project `12107255462624662036`, screen `8cc417ddb6a94343a7793468ef9ccc8a`.
- Process/tooling: implementation tasks include explicit `curl -L` download of hosted Stitch assets for verification.
- No backend/API changes and no database schema migration expected.

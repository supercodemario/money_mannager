# personal-household-expense-scope (delta)

## MODIFIED Requirements

### Requirement: Default expense household preference

The system SHALL persist a **default expense household** identifier for signed-in users, selected from the set containing the user’s personal household and all shared households where the user is a member. **New** expenses and recurring templates created while signed in SHALL use this default for `household_id` when valid. Cloud sync SHALL pull and push across **all** households the user belongs to and MUST NOT use this preference as the sole filter for sync pull scope. If the stored id is invalid (membership lost), the system SHALL fall back to the personal household for **new row** attribution and update persisted preference accordingly.

#### Scenario: User selects shared family as default for new expenses

- **WHEN** the user selects a shared household they belong to as default in preferences
- **THEN** subsequent **new** expenses SHALL be attributed to that household id until changed

#### Scenario: Sync includes all member households

- **WHEN** the user runs sync while a member of multiple households
- **THEN** the system SHALL sync expenses from every member household, not only the default expense household

#### Scenario: Fallback when membership ends

- **WHEN** the stored default points to a household the user no longer belongs to
- **THEN** the system SHALL clear or replace that preference with the personal household for new row attribution and continue sync for remaining memberships without throwing due to the invalid default alone

# recurring-payments-sync (delta)

## MODIFIED Requirements

### Requirement: Recurring templates and occurrences sync with household scope

Recurring payment templates and month occurrences SHALL sync to Supabase with the same membership-wide scope as expenses: pull incremental changes for **all** households the user belongs to (RLS-scoped), and push each pending row with its stored `household_id` and the signed-in user as `auth_user_id`. Sync MUST NOT be limited to a single active household id per cycle.

#### Scenario: Recurring pull spans all member households

- **WHEN** the user is a member of multiple households and recurring sync runs
- **THEN** the client SHALL merge recurring templates and occurrences from all member households into local storage

#### Scenario: Recurring push uses row household

- **WHEN** a pending recurring template is uploaded
- **THEN** the remote row SHALL include the template’s local `household_id` and the writer’s `auth_user_id`

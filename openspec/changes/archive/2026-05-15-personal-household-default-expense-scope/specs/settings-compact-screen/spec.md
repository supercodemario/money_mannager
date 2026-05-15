# settings-compact-screen (delta)

## MODIFIED Requirements

### Requirement: Preferences details screen includes regional preferences and category listing entry

The preferences details screen MUST include settings for Currency, Language, and Number Format, MUST provide an entry point to category listing management, and MUST include **default expense household** selection for signed-in users (personal household and shared households) per capability `personal-household-expense-scope`.

#### Scenario: Regional preferences are visible

- **WHEN** the user opens preferences details
- **THEN** the screen SHALL show Currency, Language, and Number Format controls

#### Scenario: Category listing entry is accessible

- **WHEN** the user is on preferences details
- **THEN** the screen SHALL provide navigation to category listing management

#### Scenario: Default expense household is configurable when signed in

- **WHEN** the user is signed in and opens preferences details
- **THEN** the screen SHALL present a control to select the default expense household among the personal household (e.g. labeled Self) and shared households the user belongs to


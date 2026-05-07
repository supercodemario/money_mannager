## MODIFIED Requirements

### Requirement: Limits detail screen captures inputs

The system MUST provide a **limits detail** screen reachable from Settings where the user can enter monthly income, optional monthly savings, and toggle exclude-unpaid-recurring, and save. The screen MUST show derived **spendable pool** and **indicative daily** when enough inputs exist to compute them. The limits detail screen MUST present these controls using the approved Stitch v3 composition: a prominent monthly income section, side-by-side spendable summary cards, a savings-goal card that supports percentage-goal adjustment, a recurring-subtraction toggle card, and a primary save action. Derived summaries MUST refresh in real time from the current on-screen inputs.

#### Scenario: Navigate from Settings Limits card

- **WHEN** the user opens the limits detail screen from the compact Settings Limits summary card
- **THEN** the user SHALL see limits inputs and saved values consistent with persistence

#### Scenario: Stitch v3 composition is present on limits detail

- **WHEN** the limits detail screen is rendered
- **THEN** the user SHALL see the Stitch v3 layout with monthly income section, spendable summary cards, savings-goal card with percentage control, recurring-subtraction toggle card, and primary save action

#### Scenario: Savings percentage interaction updates savings amount

- **WHEN** the user adjusts the savings percentage goal control on the limits detail screen
- **THEN** the screen SHALL update the savings amount input consistently with that percentage against the entered monthly income

#### Scenario: Limits summaries remain derived from current inputs

- **WHEN** the user changes income, savings, or recurring subtraction options
- **THEN** the monthly and daily spendable summaries SHALL update immediately from the current inputs while continuing to apply the same existing expense-limits derivation rules for the active month

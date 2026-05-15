## ADDED Requirements

### Requirement: Household family-details behavior remains satisfied under modular features

The user journeys and constraints described in **household-family-details** (signed-in access, member listing, owner-only add via scan, duplicate rejection, QR scan contract) SHALL remain satisfied when those screens are implemented across the **`household-flow-features`** module set. This requirement does not relax any existing SHALL in the baseline spec; it only ties modular packaging to those obligations.

#### Scenario: Owner add-member scan still enforced after modularization

- **WHEN** the current user is not the household owner and opens the family members experience from the modular feature set
- **THEN** the system SHALL still not complete the owner-only add-member scan flow in violation of the baseline household-family-details rules

#### Scenario: Modular navigation does not bypass signed-in gating

- **WHEN** the user is not signed in for cloud household management
- **THEN** the modular family list and related entrypoints SHALL still not expose the same management behavior as a signed-in household member, consistent with household-family-details

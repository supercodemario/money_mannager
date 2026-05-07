## ADDED Requirements

### Requirement: Categories carry a required 50/30/20 bucket
The system MUST persist a required bucket for every category with allowed values `needs`, `wants`, and `savings_debt`.

#### Scenario: New category requires bucket assignment
- **WHEN** the user creates a category
- **THEN** the category SHALL NOT be saved unless one of the three buckets is selected

#### Scenario: Existing categories are backfilled during rollout
- **WHEN** the app migrates to bucket-enabled categories
- **THEN** each existing category SHALL receive a deterministic bucket assignment so all categories remain classifiable

### Requirement: Category listing screen supports bucket management
The system MUST provide a category listing management screen that shows categories and their assigned buckets, and supports updating bucket assignment.

#### Scenario: Category list shows bucket label
- **WHEN** the user opens category listing management
- **THEN** each category row SHALL display its current bucket (Needs/Wants/Savings & Debt)

#### Scenario: User updates category bucket
- **WHEN** the user changes a category bucket in management
- **THEN** the new bucket assignment SHALL be persisted and used for subsequent expense classification

## ADDED Requirements

### Requirement: Preferences details follows layered feature structure

The preferences details screen implementation MUST follow the project feature layout for the `settings` feature: UI in `view/`, state and commands in `bloc/`, persistence and orchestration in `data/`, and state types in `models/`. The view layer MUST NOT call `AppServices`, repositories, or `SyncMetadataStore` directly except to construct the bloc’s dependencies at screen entry (e.g. `BlocProvider` create callback). Private reusable widgets for preferences details (e.g. dropdown rows) MUST live under `lib/features/settings/widgets/`.

#### Scenario: Screen entry wires bloc only

- **WHEN** `PreferencesDetailsScreen` is built
- **THEN** it SHALL provide a preferences-details bloc/cubit with injected repository dependencies and SHALL render UI via bloc-driven state

#### Scenario: Persistence goes through feature data layer

- **WHEN** regional preferences or default expense household are loaded or saved from preferences details
- **THEN** those operations SHALL be invoked from the preferences-details bloc via the feature `data/` repository, not from widget `setState` handlers calling global services directly

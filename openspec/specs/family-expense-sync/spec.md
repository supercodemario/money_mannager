# family-expense-sync (roadmap)

**Status:** **Deferred** — not implemented by the `local-expense-persistence` change. This file captures **target** behavior for a **future** proposal so requirements stay coherent when sync work starts.

---

## ADDED Requirements

### Requirement: Household members can contribute expenses from multiple devices

When the family sync capability is implemented, the system SHALL allow **multiple devices** and **multiple members** to create and update expenses that belong to a **shared household**, subject to authentication and authorization rules defined in that future change.

#### Scenario: Another member’s expense appears after sync

- **WHEN** a member on another device records an expense for the household and sync completes
- **THEN** another member’s device SHALL be able to show that expense in shared daily or monthly views according to sync rules

### Requirement: Daily and monthly aggregates reflect merged data

When family sync is implemented, views that summarize spend by **day** or **month** SHALL incorporate expenses from all synced members (within the product’s permission model), not only the local device’s offline queue.

#### Scenario: Monthly total includes family

- **WHEN** the user opens a monthly summary for a household
- **THEN** the total SHALL reflect expenses attributed to members of that household that have been merged via sync

### Requirement: Conflict handling is explicit

When family sync is implemented, concurrent edits to the same expense from different devices MUST be resolved by a **documented** strategy (e.g. last-write-wins, manual merge, or server authority). The exact strategy SHALL be specified in the sync change’s design.

#### Scenario: Conflicts are not silent data loss

- **WHEN** a conflict is detected
- **THEN** the system SHALL apply the chosen resolution strategy and MUST NOT silently discard updates without a defined rule

### Requirement: Local-first operation remains supported

When family sync is implemented, the app SHOULD remain usable **offline** for recording expenses; sync SHOULD reconcile when connectivity returns. (Normative details belong in the sync change.)

#### Scenario: Offline capture queues for later sync

- **WHEN** the user adds an expense while offline
- **THEN** the expense SHALL be stored locally and SHALL be eligible for upload when sync is available, per the sync change

## ADDED Requirements

### Requirement: Expenses mode switcher matches streamlined pill design

The Expenses tab MUST present the Daily, Monthly, and Recurring mode control as a full-width **pill-shaped track** with **inner padding** (equivalent to a thin inset from the track edge), a **rounded selection indicator** that occupies approximately one third of the inner width, and **labels** that reflect selected vs unselected states with sufficient contrast. The selection indicator MUST **move** between the three positions when the user changes mode using a short animated transition.

#### Scenario: User sees pill track and sliding selection

- **WHEN** the Expenses tab is displayed
- **THEN** the mode control SHALL show a continuous track with three equal segments and a single rounded indicator aligned to the active segment

#### Scenario: User changes mode and indicator animates

- **WHEN** the user switches from one mode to another
- **THEN** the selection indicator SHALL animate to the new segment position

### Requirement: Selection without segment icons

The active mode MUST be clear from the **sliding indicator** and **label contrast** alone. The mode control SHALL NOT require checkmarks or other icons on segment labels to communicate selection.

#### Scenario: No auxiliary selection icons

- **WHEN** any of Daily, Monthly, or Recurring is active
- **THEN** the mode control SHALL NOT show a check icon (or equivalent) on the segment labels

## REMOVED Requirements

### Requirement: Daily mode shows check affordance when active

**Reason:** Checkmark was redundant with the sliding pill and created asymmetric UX versus Monthly and Recurring.

**Migration:** None; visual-only change.

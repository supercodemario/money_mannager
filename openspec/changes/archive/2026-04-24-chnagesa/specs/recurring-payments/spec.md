## ADDED Requirements

### Requirement: Add or edit recurring template form respects the soft keyboard

The screen used to create or edit a recurring payment template MUST lay out correctly when the on-screen keyboard is visible. The implementation MUST NOT apply the keyboard’s bottom inset twice to the same subtree (for example, combining default `Scaffold` bottom resize with an additional full `MediaQuery.viewInsets.bottom` pad on the body). The form MUST remain scrollable so the user can reach title, amount, category, due date, end month (when shown), and save while the IME is open.

#### Scenario: No large dead band above keyboard

- **WHEN** the user focuses the template title or amount field on a device with the soft keyboard shown
- **THEN** the layout SHALL NOT reserve a second full keyboard-height empty band between the form content and the keyboard beyond what the framework’s single inset handling provides

#### Scenario: Form remains usable

- **WHEN** the soft keyboard is visible on the add or edit recurring template screen
- **THEN** the user SHALL be able to scroll to and interact with all primary controls (including save) without the keyboard permanently obscuring them with no way to scroll

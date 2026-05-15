## MODIFIED Requirements

### Requirement: Add member uses QR scan of invite payload

The **add member** flow SHALL use device camera scanning to read the **invite payload** defined in product/design (encoding the invitee’s stable identity, e.g. Supabase auth user id when the invitee is cloud-authenticated, otherwise a stable client profile id as approved by design). Successful scan SHALL trigger the server-authorized membership mutation path (e.g. RPC). The invite QR **MAY** be shown from **family list** or **household QR share** surfaces; it **SHALL NOT** be required to originate from the profile details screen.

#### Scenario: Successful scan leads to membership mutation attempt

- **WHEN** the owner completes a valid scan of an invite QR and the backend accepts the operation
- **THEN** the household SHALL gain the new member (or show an explicit server error)

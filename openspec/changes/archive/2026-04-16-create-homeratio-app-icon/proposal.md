## Why

The project needs a branded, production-ready app icon for `HomeRatio` that matches the provided Stitch design direction and can be used consistently across platforms. Defining this as an OpenSpec change ensures the asset acquisition flow (including hosted downloads) and icon deliverables are repeatable and reviewable.

## What Changes

- Add a new app-icon capability for HomeRatio that defines required visual composition, palette, and quality expectations from the supplied Stitch screen prompt.
- Define a reproducible workflow to retrieve Stitch-hosted image/code assets (via `curl -L`) and store them in the repository in a stable location.
- Add implementation tasks to produce and integrate the finalized app icon asset(s) from the Stitch source material.

## Capabilities

### New Capabilities
- `homeratio-app-icon`: Defines HomeRatio app icon requirements, source retrieval from Stitch-hosted URLs, and repository-ready asset outputs.

### Modified Capabilities
- None.

## Impact

- Affected areas: OpenSpec change artifacts, design assets directory, and app icon integration paths used by the app build.
- Tooling/process: Requires network retrieval of hosted Stitch assets with `curl -L`.
- No API contract changes expected; impact is primarily design-system/branding and build asset packaging.

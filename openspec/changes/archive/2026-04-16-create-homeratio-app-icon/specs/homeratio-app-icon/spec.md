## ADDED Requirements

### Requirement: HomeRatio app icon visual composition
The system MUST produce an app icon for `HomeRatio` that combines a modern minimalist house silhouette, an integrated percentage or ratio symbol, and a subtle upward-trending chart line woven into the roofline.

#### Scenario: Required icon elements are present
- **WHEN** the finalized app icon is reviewed
- **THEN** the icon SHALL visibly include a house silhouette, a percent/ratio cue, and an upward trend cue in the roofline

### Requirement: HomeRatio app icon style and palette
The app icon MUST follow the requested visual style of a high-quality 3D render with soft ambient-occlusion depth and MUST use a palette anchored to deep emerald green, slate grey, and clean white.

#### Scenario: Style and palette comply with brief
- **WHEN** the icon deliverable is validated against the design brief
- **THEN** the icon SHALL satisfy the 3D render/depth treatment and SHALL use emerald, slate, and white as dominant tones

### Requirement: Stitch artifact retrieval is reproducible
The workflow MUST support reproducible retrieval of hosted Stitch artifacts (images/code) for the icon source material using `curl -L`, with commands and destination paths documented in the change deliverables.

#### Scenario: Hosted assets are retrieved through curl
- **WHEN** an implementer executes the documented retrieval commands
- **THEN** the Stitch-hosted artifact files SHALL download successfully into the documented project asset path

### Requirement: Final icon output is repository-ready
The change MUST output a finalized icon asset in a stable repository location suitable for app integration and later platform-specific icon generation.

#### Scenario: Final icon is available for integration
- **WHEN** implementation tasks are complete
- **THEN** a final icon asset SHALL exist at the documented path and SHALL be ready to be referenced by app build configuration

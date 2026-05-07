## Context

The project needs a single high-quality app icon for `HomeRatio` based on a Stitch-provided screen brief for a professional and playful financial brand identity. The requested visual direction is a modern house silhouette with an integrated percent/ratio motif and subtle growth line in the roofline, using deep emerald green, slate grey, and white in a 3D render style. The team also wants deterministic retrieval of Stitch-hosted artifacts and related generated code using command-line download (`curl -L`) so assets can be versioned and reproduced.

## Goals / Non-Goals

**Goals:**
- Define a deterministic workflow to retrieve Stitch-hosted files for project `12107255462624662036`, screen `536b12fab59a46229d37725f0e20fa59`.
- Produce a finalized app icon output suitable for app integration and future export to platform icon sizes.
- Capture quality gates for composition, color usage, and readability so review is objective.

**Non-Goals:**
- Rebrand the rest of the app UI beyond icon-specific branding.
- Implement a full design-token overhaul.
- Automate all platform-specific icon resizing in this change unless needed by current implementation scope.

## Decisions

1. Use `curl -L` for hosted artifact retrieval.
   - Rationale: Follows the requested retrieval method and avoids dependency on a GUI flow for repeatability.
   - Alternative considered: manual browser download. Rejected because it is less reproducible and harder to script.

2. Store raw Stitch outputs and curated final icon as separate assets.
   - Rationale: Preserves traceability between source artifacts and final deliverable.
   - Alternative considered: keep only the final icon. Rejected because source context would be lost.

3. Keep icon validation criteria focused on brand semantics and small-size legibility.
   - Rationale: App icons must be identifiable at multiple sizes and maintain semantic cues (house + ratio + growth).
   - Alternative considered: visual-only subjective review. Rejected due to inconsistent acceptance outcomes.

## Risks / Trade-offs

- [Stitch URL availability or expiration] -> Mitigation: download and commit retrieved artifacts promptly; document retrieval command/output.
- [3D styling reduces legibility at small sizes] -> Mitigation: validate readability at common icon preview sizes and simplify depth/shadow if needed.
- [Ambiguity between percent and ratio symbol integration] -> Mitigation: prioritize a clear percent/ratio cue in silhouette and run design review against acceptance criteria.
- [Inconsistent color rendering across tools] -> Mitigation: use explicit palette values and verify output against target emerald/slate/white tones.

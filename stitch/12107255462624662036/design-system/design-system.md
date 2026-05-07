# Design System: The Financial Sanctuary

This design system is a bespoke framework crafted for a high-end, family-centric financial experience. It moves away from the rigid, cold grids of traditional banking and toward a "Soft Editorial" aesthetic—combining the authority of a premium lifestyle magazine with the warmth of a modern home.

## 1. Creative North Star: The Digital Sanctuary

The "Digital Sanctuary" philosophy centers on the idea that financial management shouldn't be stressful—it should be clarifying. We achieve this through **Organic Composition**: using generous whitespace (breathing room), sophisticated tonal layering, and intentional asymmetry to guide the eye. We are building a space that feels curated, not just calculated.

## 2. Colors: Tonal Clarity

Our palette uses sophisticated blues and greens to evoke "Financial Flow" and warm terracotta accents for human connection.

### The "No-Line" Rule

**Prohibit 1px solid borders for sectioning.** Boundaries must be defined solely through background color shifts or subtle tonal transitions. A `surface-container-low` card sitting on a `surface` background provides all the definition needed. Lines create visual noise; color shifts create harmony.

### Surface Hierarchy & Nesting

Treat the UI as a series of physical layers, like stacked sheets of frosted glass.

- **Level 0 (Base):** `surface` (#f8f9fa) - The foundation.
- **Level 1 (Sections):** `surface-container-low` (#f2f4f5) - Large structural areas.
- **Level 2 (Cards):** `surface-container-lowest` (#ffffff) - Individual interactive elements.
- **Level 3 (Pop-overs):** `surface-container-highest` (#dee3e5) - Temporary elevated states.

### The "Glass & Gradient" Rule

To escape the "flat" look, use **Glassmorphism** for floating action buttons or navigation bars. Use `surface` colors at 80% opacity with a `20px` backdrop-blur. For primary CTAs, apply a subtle linear gradient from `primary` (#01668b) to `primary_container` (#8ad2fc) at a 135-degree angle to add "soul" and depth.

## 3. Typography: Editorial Authority

We pair **Plus Jakarta Sans** (Display) with **Manrope** (Body) to create a balance between modern personality and technical legibility.

- **Display (Plus Jakarta Sans):** Used for big "Hero" numbers and monthly totals. The wide apertures feel welcoming.
- **Body (Manrope):** Chosen for its high x-height and clean geometric forms, ensuring expense lists are readable at a glance.
- **The Scale Rule:** Always over-emphasize the hierarchy. If a `headline-lg` is used for a balance, use a `label-md` in `on-surface-variant` for the secondary text to create high-contrast sophistication.

## 4. Elevation & Depth: Tonal Layering

Traditional drop shadows are forbidden. We use **Ambient Softness** to imply weight.

- **The Layering Principle:** Depth is achieved by stacking. Place a white card (`surface-container-lowest`) on a light grey background (`surface-container`) to create a soft, natural lift.
- **Ambient Shadows:** If an element must "float" (like a Modal), use a shadow with a 40px blur, 0px offset, and 6% opacity of the `on-surface` color (#2e3335). This mimics natural gallery lighting.
- **The Ghost Border:** If accessibility requires a stroke (e.g., in high-contrast mode), use `outline-variant` at **15% opacity**. Never use a 100% opaque border.

## 5. Components: The Primitive Set

### Buttons

- **Primary:** Uses the `xl` (1.5rem) roundedness. Gradient fill (Primary to Primary Container). No border.
- **Secondary:** `surface-container-high` fill with `on-primary-container` text.
- **Tertiary:** Transparent background, `primary` text, bold weight.

### Input Fields

- Avoid the "box" look. Use a `surface-container-low` fill with a `bottom-only` focus indicator using `primary` (2px). Labels should use `label-md` and sit 8px above the field.

### Cards & Lists (The "No-Divider" Mandate)

- **Forbid the use of divider lines.** To separate expense items, use 16px of vertical whitespace or alternating subtle background shifts.
- **Nesting:** A "Grocery" category card should be `surface-container-lowest` (#ffffff) to pop against the `surface` background.

### Custom Category Iconography

Icons should be "Enclosed Glyphs"—minimalist shapes inside soft-filled circles using the `secondary_container` or `tertiary_container` tones.

- **House:** `primary` glyph on `primary_container`.
- **Medical:** `error` glyph on `on-error-container` (softened).
- **Grocery:** `secondary` glyph on `secondary_container`.
- **Travel/Dining/Entertainment:** Use `tertiary` (warm accents) to distinguish "discretionary" spending from "fixed" bills.

### Relevant App-Specific Components

- **The "Family Member" Chip:** Circular avatars with a `secondary_fixed` border ring to indicate who made the purchase.
- **The Progress Track:** A thick 12px track using `surface-container-highest` with a `secondary` (green) fill to show budget remaining.

## 6. Do's and Don'ts

### Do

- **Do** use asymmetrical layouts (e.g., a large balance on the left, a small "View Trends" button tucked on the right).
- **Do** use `tertiary` (warm oranges/browns) for "Warning" or "Subscription" items to keep the vibe friendly rather than alarming.
- **Do** utilize the `xl` (1.5rem) corner radius for main containers to emphasize the "approachable" brand promise.

### Don't

- **Don't** use pure black (#000000) for text. Use `on-surface` (#2e3335) to maintain a premium, softer contrast.
- **Don't** use standard Material Design "Floating Action Buttons" in bright circles. Instead, use a wide, pill-shaped "Add Expense" button anchored at the bottom with a backdrop-blur.
- **Don't** crowd the screen. If a screen feels full, increase the `surface` padding. Luxury is defined by the space you don't use.
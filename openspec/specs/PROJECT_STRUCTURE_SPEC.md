# Project Structure Strict Spec

This document defines the mandatory directory structure and architectural layers for the project. All developers and AI agents must adhere to these rules.

## 1. Root Level Organization
All source code resides in the `lib/` directory, organized into three primary top-level folders:

- `lib/features/`: Domain-specific modules.
- `lib/core/`: Global infrastructure, networking, and utilities.
- `lib/share/`: Reusable UI components, design tokens, and shared widgets.

---

## 2. Feature Layer (`lib/features/`)
Each feature must be encapsulated in its own directory: `lib/features/<feature_name>/`.
The same layout applies to **every** feature so the project stays easy to navigate and review.

Inside each feature, the following sub-directories are **mandatory**:

| Directory | Responsibility |
| :--- | :--- |
| `bloc/` | State management logic (Blocs, Events, States). |
| `data/` | Data sources (Remote/Local) and Repository implementations. |
| `models/` | Data transfer objects and domain models. |
| `view/` | **Screens only**: route-level pages and their **composition** (wiring state, callbacks, layout). |
| `routes/` | Feature-specific route definitions and modules. |
| `widgets/` | **All other feature-scoped widgets** (sections, cards, lists, form chunks—not full screens). |

### 2.1 Strict `view/` vs `widgets/` rule (readability)

These rules are **mandatory**:

1. **Screens live in `view/`.** Each primary screen is typically one `StatelessWidget` / `StatefulWidget` (or a small set of closely related entry widgets) in `view/`.
2. **Child widgets live in `widgets/`.** Any additional `Widget` subclass defined for that feature—anything with its own `build` and a non-trivial subtree—**must** be implemented under `lib/features/<feature_name>/widgets/`, in one or more files. **Do not** define those classes in the same file as the screen in `view/`.
3. **Naming.** Prefer **public** widget class names (e.g. `DashboardBudgetHero`), not library-private `_Foo` types, so files under `widgets/` are clear and importable.
4. **Tiny exception.** Inline or private helpers are allowed in `view/` only when they are trivial (e.g. a one-off `Padding`/`SizedBox` wrapper or a few lines with no separate `Widget` class). If it grows beyond that, move it to `widgets/`.
5. **Cross-feature UI belongs in `share/`.** If a widget is used by **more than one** feature, it **must** live under `lib/share/widgets/` (or be split into a shared primitive there), not under a single feature’s `widgets/` folder.

6. **Common skeleton.** When adding a new feature, create the **same** folder set (`bloc/`, `data/`, `models/`, `view/`, `routes/`, `widgets/`) even if some folders are temporarily empty—this keeps the tree uniform across the whole project.

### Model Folder Convention
Models must follow a nested directory pattern:
`lib/features/<feature>/models/<model_name>/<model_name>.dart`

---

## 3. Core Layer (`lib/core/`)
The `core` directory contains code that is independent of any specific feature.

- `lib/core/network/`: API clients, interceptors, and network configuration.
- `lib/core/endpoints/`: Registry of all API endpoints.
- `lib/core/error/`: Global error handling and exceptions.
- `lib/core/utils/`: Generic utility functions.
- `lib/core/di/`: Dependency injection setup (if applicable).

---

## 4. Share Layer (`lib/share/`)
The `share` directory contains reusable UI elements and styling.

- `lib/share/tokens/`: Design tokens (Colors, Typography, Spacing, Shadows).
- `lib/share/widgets/`: Reusable atomic or molecular UI components used across multiple features.
- `lib/share/assets/`: Centralized asset constants (Icons, Image paths).

---

## 5. Routing Architecture
We use `auto_route` for navigation.

- **Feature Modules**: Each feature defines its routes in `<feature>/routes/`.
- **Registry**: Features register their routes into a central `RouteRegistry`.
- **Bootstrap**: The `AppRouter` pulls routes from the registry during initialization.
- **Exports**: All `@RoutePage` components must be exported via a central `lib/bootstrap_exports.dart` file.

---

## 6. Dependency Rules
1. **No Cross-Feature Imports**: `feature_a` must not import anything from `feature_b`. Common logic should be moved to `core` or `share`.
2. **Layered Flow**: `view` -> `bloc` -> `data`. The data layer should not depend on the UI layer.
3. **Token First**: UI must use tokens from `lib/share/tokens/`. Direct hex codes or raw pixel values are prohibited in feature views.

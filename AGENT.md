# Agent Development Guidelines & Learnings

This document summarizes the development process, architectural conventions, testing standards, and best practices established and practiced in the `iccm_eu_app` project.

---

## 1. Implementation Directory Structure (`lib/`)

The application code is structured in `lib/` with clear separation of concerns:

```
lib/
├── components/          # Reusable UI widgets and sub-views (e.g., list tiles, forms, overlays, buttons)
├── controls/            # Global UI controllers (drawer menu, navigation bar, overlay messages)
├── data/                # Data layer, state management, models, and services
│   ├── appProviders/    # App-level state providers (preferences, theme, navigation index, error handling)
│   ├── dataProviders/   # Domain data providers (events, speakers, tracks, rooms, gsheets integration)
│   ├── definitions/     # Application constants, dictionaries, and color definitions
│   ├── model/           # Data models and entities (EventData, SpeakerData, WebNotification, etc.)
│   ├── notifications/   # Push and local notification services (FCM, local notifications)
│   └── testData/        # Mock and fallback static test data
├── pages/               # Screen-level widgets and views (HomePage, EventsPage, PreferencesPage, etc.)
├── platform/            # Multiplatform abstractions (conditional imports for Web vs. Native/IO)
├── theme/               # Light and dark themes configuration
├── utils/               # Pure logic, helper functions, and utility classes (TextFunctions, DateFunctions, etc.)
└── main.dart            # Application entry point
```

### Architectural Principles
- **Decoupled Business Logic**: Keep business and formatting logic in `utils/` or data providers rather than embedding it inside UI widgets.
- **Multiplatform Compatibility**: Use `platform/` abstractions to isolate IO and Web specific dependencies.
- **State Management**: Data state is managed via providers under `data/appProviders/` and `data/dataProviders/`.

---

## 2. Test Directory Structure (`test/`)

The `test/` directory mirrors the `lib/` directory structure to make tests intuitive to locate and maintain:

```
test/
├── components/          # Widget and component tests (e.g., send_notification_form_test.dart)
├── data/                # Tests for data providers and services
│   ├── dataProvidersTests/   # Unit/mock tests for data providers (e.g., gsheets_provider_test.dart)
│   └── notificationsTests/   # Tests for notification services (e.g., fcm_notifications_service_test.dart)
└── utils/               # Unit tests for utility logic (e.g., text_functions_test.dart)
```

### Naming & Location Conventions
- Every test file corresponds to an implementation file and ends with `_test.dart`.
- Example:
  - Implementation: `lib/utils/text_functions.dart`
  - Test File: `test/utils/text_functions_test.dart`

---

## 3. Mandatory Test Coverage for Logic Implementations

Whenever a new logic function is introduced or an existing function is updated, a corresponding test must be created or updated in `test/`.

### Guidelines for Logic Function Tests
1. **Comprehensive Edge Case Coverage**:
   - Happy path / standard inputs.
   - Edge cases: empty strings, null values, special characters, whitespace, boundary limits.
   - Unexpected / invalid inputs (e.g., special characters, non-alphanumeric symbols).
2. **Structured Test Organization**:
   - Use `group()` to organize tests by class and method name (e.g., `group('TextFunctions.normalizeListKey Tests', () { ... })`).
   - Use clear `test()` descriptions stating the expected behavior.
3. **Automated Verification**:
   - All tests are executed using `flutter test` and verified in CI/CD pipeline (`.github/workflows/flutter-build.yml`).

---

## 4. Commit Message Proposals at Change Summaries

At the conclusion of any change summary or task completion, propose a clear, structured Git commit message following conventional commit standards.

### Commit Message Template
```text
<type>(<scope>): <short descriptive summary>

- <Detail 1: What was added or changed in implementation>
- <Detail 2: What tests were added or updated>
- <Detail 3: Any additional impact or refactoring details>
```

### Allowed Types
- `feat`: New feature added.
- `fix`: Bug fix.
- `test`: Adding or updating test cases.
- `refactor`: Code change that neither fixes a bug nor adds a feature.
- `docs`: Documentation changes.
- `chore`: Maintenance tasks or CI/CD updates.

---

## 5. Continuous Integration & Quality Standards

- **CI Pipeline**: Automated tests run on every push and pull request (`.github/workflows/flutter-build.yml`).
- **Code Style**: Ensure code complies with `analysis_options.yaml` and Flutter lint rules (`flutter analyze`).
- **Dry Runs**: Always run `flutter test` locally or verify that logic tests pass prior to submitting changes.

# Phase 4: Testing, QA & Best Practices - Complete Guide

This document explains all concepts from the FixIt Now testing infrastructure in detail.

---

## Table of Contents

1. [Testing Architecture](#phase-1-testing-architecture)
2. [Testing Dependencies](#phase-2-testing-dependencies)
3. [Unit Tests](#phase-3-unit-tests)
4. [Widget Tests](#phase-4-widget-tests)
5. [Test Helpers](#phase-5-test-helpers)
6. [Code Refactoring for Testability](#phase-6-code-refactoring-for-testability)
7. [Running Tests](#phase-7-running-tests)
8. [Test Results Summary](#phase-8-test-results-summary)
9. [QA Best Practices](#phase-9-qa-best-practices-implemented)
10. [Integration Test Structure](#phase-10-integration-test-structure)
11. [Future Improvements](#phase-11-future-improvements)
12. [Common Testing Patterns](#phase-12-common-testing-patterns)

---

## Phase 1: Testing Architecture

### Overview

This section establishes the **folder structure** for organizing tests in the project. A well-organized test structure is crucial for maintainability and finding tests quickly.

### The Test Folder Structure

```
test/
├── helpers/
│   └── test_helpers.dart          # Shared utilities & factory functions
├── unit/
│   ├── models/
│   │   ├── user_model_test.dart   # Tests for UserModel
│   │   └── ticket_model_test.dart # Tests for TicketModel
│   ├── providers/
│   │   ├── auth_provider_test.dart    # Tests for AuthProvider
│   │   └── ticket_provider_test.dart  # Tests for TicketProvider
│   └── utils/
│       └── validators_test.dart   # Tests for form validators
├── widget/
│   └── widgets/
│       ├── ticket_card_test.dart      # Tests for TicketCard
│       ├── custom_button_test.dart    # Tests for CustomButton
│       └── custom_text_field_test.dart # Tests for CustomTextField
└── widget_test.dart               # Basic app smoke test

integration_test/
└── app_test.dart                  # End-to-end test scaffolding
```

### Key Concepts

1. **Three Types of Tests**:

   - **Unit Tests** (`test/unit/`) - Test individual pieces of logic in isolation (models, providers, validators)
   - **Widget Tests** (`test/widget/`) - Test UI components and their behavior
   - **Integration Tests** (`integration_test/`) - Test full app flows and user journeys

2. **Helpers Folder** (`test/helpers/`):

   - Contains reusable utilities like factory functions to create test data
   - Reduces code duplication across tests

3. **Separation by Feature**:

   - Tests are organized by what they're testing (models, providers, utils, widgets)
   - Makes it easy to find and maintain related tests

4. **Smoke Test** (`widget_test.dart`):
   - A quick sanity check that the app launches without crashing
   - Usually runs first to catch major issues early

### Why This Structure Matters

| Benefit                  | Description                                                     |
| ------------------------ | --------------------------------------------------------------- |
| **Discoverability**      | Easy to find tests for specific features                        |
| **Scalability**          | Structure grows naturally as you add features                   |
| **CI/CD Friendly**       | Can run specific test folders (e.g., `flutter test test/unit/`) |
| **Parallel Development** | Multiple devs can work on different test areas                  |

---

## Phase 2: Testing Dependencies

### Overview

This section covers the **packages/libraries** needed for testing in Flutter. These are added to the `dev_dependencies` section of `pubspec.yaml` (meaning they're only used during development, not in the final app).

### The Testing Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^6.0.0

  # Testing
  mockito: ^5.4.4
  build_runner: ^2.4.12
  fake_cloud_firestore: ^3.1.0
  firebase_auth_mocks: ^0.14.1
  google_sign_in_mocks: ^0.3.0
  network_image_mock: ^2.1.1
```

### Breaking Down Each Dependency

| Package                  | Purpose                                                                                  |
| ------------------------ | ---------------------------------------------------------------------------------------- |
| **flutter_test**         | Flutter's built-in testing framework. Provides `testWidgets()`, `expect()`, `find`, etc. |
| **integration_test**     | Flutter SDK package for end-to-end testing on real devices/emulators                     |
| **flutter_lints**        | Static code analysis rules (not testing per se, but ensures code quality)                |
| **mockito**              | Creates mock objects to simulate dependencies (e.g., fake API responses)                 |
| **build_runner**         | Code generation tool - required by mockito to generate mock classes                      |
| **fake_cloud_firestore** | In-memory fake Firestore database for testing without hitting real Firebase              |
| **firebase_auth_mocks**  | Mock Firebase Authentication - test login/logout without real auth                       |
| **google_sign_in_mocks** | Mock Google Sign-In flow for testing                                                     |
| **network_image_mock**   | Mocks network images so widget tests don't fail trying to load real images               |

### Key Concepts

#### 1. **SDK Dependencies vs Version Dependencies**

```yaml
# SDK dependency - comes from Flutter itself
integration_test:
  sdk: flutter

# Version dependency - from pub.dev
mockito: ^5.4.4
```

The `integration_test` package is part of Flutter SDK, so you use `sdk: flutter` instead of a version number.

#### 2. **Why Mock External Services?**

When testing, you don't want to:

- Hit real databases (slow, costs money, unpredictable)
- Require internet connection
- Create real user accounts
- Upload real images

**Mocks simulate** these services locally, making tests:

- ✅ Fast
- ✅ Reliable (no network failures)
- ✅ Free (no Firebase charges)
- ✅ Isolated (tests don't affect each other)

#### 3. **The Mockito + Build Runner Workflow**

```dart
// 1. Annotate classes you want to mock
@GenerateMocks([FirestoreService, StorageService])
void main() { ... }

// 2. Run build_runner to generate mocks
// $ flutter pub run build_runner build

// 3. Use generated mocks in tests
final mockService = MockFirestoreService();
when(mockService.getTickets()).thenReturn([...]);
```

#### 4. **Network Image Mocking**

Widget tests fail when trying to load network images. The `network_image_mock` package wraps tests to handle this:

```dart
await mockNetworkImagesFor(() async {
  await tester.pumpWidget(MyWidgetWithNetworkImage());
  // Now CachedNetworkImage works in tests!
});
```

### Why This Matters

Without these dependencies:

- Widget tests would crash trying to load images from URLs
- You'd need real Firebase projects for every test run
- Tests would be slow and unreliable
- You couldn't test authentication flows easily

---

## Phase 3: Unit Tests

### Overview

Unit tests verify **individual pieces of logic** in isolation - no UI, no external services, just pure Dart code. They're the fastest and most numerous tests in any codebase.

### 3.1 Model Tests

Models are data classes that represent entities in your app. Testing them ensures data integrity.

#### **UserModel Tests** (`test/unit/models/user_model_test.dart`)

Tests verify:

| What's Tested                              | Why It Matters                                                       |
| ------------------------------------------ | -------------------------------------------------------------------- |
| **Constructor**                            | Ensures required fields can't be null, optional fields have defaults |
| **Role checks** (`isAdmin`, `isUser`)      | Business logic for permissions                                       |
| **Serialization** (`fromMap()`, `toMap()`) | Data survives Firebase read/write                                    |
| **Immutability** (`copyWith()`)            | Safe data updates without mutation                                   |
| **Equality** (`==`, `hashCode`)            | Correct comparison in lists, sets, maps                              |
| **toString()**                             | Debugging output is useful                                           |

```dart
group('Role checks', () {
  test('isAdmin returns true for admin role', () {
    final adminUser = UserModel(
      uid: 'admin-uid',
      email: 'admin@example.com',
      name: 'Admin User',
      role: 'admin',
      createdAt: DateTime.now(),
    );

    expect(adminUser.isAdmin, isTrue);   // ✅ Should be true
    expect(adminUser.isUser, isFalse);   // ✅ Should be false
  });
});
```

#### **TicketModel Tests** (`test/unit/models/ticket_model_test.dart`)

This model is more complex with **enums** for category, priority, and status.

**Enum Testing:**

```dart
group('TicketStatus Enum', () {
  test('fromString is case insensitive', () {
    // All these should work the same
    expect(TicketStatus.fromString('open'), TicketStatus.open);
    expect(TicketStatus.fromString('OPEN'), TicketStatus.open);
    expect(TicketStatus.fromString('Open'), TicketStatus.open);
  });

  test('fromString returns open for unknown status', () {
    // Graceful fallback for bad data
    expect(TicketStatus.fromString('garbage'), TicketStatus.open);
  });
});
```

**Why test enums?**

- Data from Firebase might have inconsistent casing
- Unknown values shouldn't crash the app
- `displayName` property ensures proper UI labels

### 3.2 Validator Tests (`test/unit/utils/validators_test.dart`)

Validators are functions that check user input. They return `null` if valid, or an error message if invalid.

| Validator                 | Test Cases                                                                   |
| ------------------------- | ---------------------------------------------------------------------------- |
| `validateEmail`           | null, empty, invalid formats (`notanemail`, `missing@domain`), valid formats |
| `validatePassword`        | null, empty, too short (< 6 chars), valid (6+ chars)                         |
| `validateConfirmPassword` | null, empty, mismatch with original, exact match                             |
| `validateName`            | null, empty, too short (< 2 chars), valid names                              |
| `validateRequired`        | null, empty, any non-empty value                                             |
| `validateTitle`           | null, empty, < 5 chars, > 100 chars, valid length                            |
| `validateDescription`     | null, empty, < 10 chars, > 500 chars, valid length                           |

**Example Test:**

```dart
test('returns error for invalid email formats', () {
  expect(Validators.validateEmail('notanemail'), isNotNull);      // ❌ Invalid
  expect(Validators.validateEmail('missing@domain'), isNotNull);  // ❌ No TLD
  expect(Validators.validateEmail('@nodomain.com'), isNotNull);   // ❌ No local part
});

test('returns null for valid email formats', () {
  expect(Validators.validateEmail('test@example.com'), isNull);      // ✅ Valid
  expect(Validators.validateEmail('user.name@domain.org'), isNull);  // ✅ Valid
});
```

**Key Pattern:** `isNull` = valid, `isNotNull` = has error message

### 3.3 Provider Tests

Providers manage app state. Testing them ensures state changes correctly.

#### **AuthProvider Tests** (`test/unit/providers/auth_provider_test.dart`)

Tests verify:

- **AuthState enum** - All states exist (`initial`, `loading`, `authenticated`, `unauthenticated`, `error`)
- **Role-based properties** - `isAdmin`, `isUser` computed from `UserModel`
- **State helpers** - `isLoading`, `isAuthenticated` return correct booleans
- **Error handling** - Error codes are parsed correctly

#### **TicketProvider Tests** (`test/unit/providers/ticket_provider_test.dart`)

Tests verify:

- **Filter logic** - Open, In Progress, Resolved, All filters work correctly
- **Case sensitivity** - Filters match regardless of case
- **Ticket counts** - `Map<String, int>` returns correct counts per status
- **Test data generation** - Helper functions create valid test data

### Why Unit Tests Matter

| Benefit                | Explanation                                      |
| ---------------------- | ------------------------------------------------ |
| **Speed**              | Run in milliseconds (no UI rendering, no I/O)    |
| **Confidence**         | Catch bugs in logic before they reach UI         |
| **Documentation**      | Tests show how code should behave                |
| **Refactoring Safety** | Change implementation without breaking behavior  |
| **Edge Cases**         | Systematically test null, empty, boundary values |

### Unit Test Best Practices Used

1. **Group related tests** with `group()`:

   ```dart
   group('Role checks', () {
     test('isAdmin returns true for admin role', ...);
     test('isUser returns true for user role', ...);
   });
   ```

2. **Clear test names** that describe the expected behavior

3. **Test edge cases**: null, empty, boundary values, invalid inputs

4. **One assertion per test** (when practical) for clear failure messages

---

## Phase 4: Widget Tests

### Overview

Widget tests verify **UI components** render correctly and respond to user interactions. They're more comprehensive than unit tests but faster than integration tests because they don't need a real device.

### How Widget Tests Work

```dart
testWidgets('displays ticket title', (tester) async {
  // 1. Build the widget
  await tester.pumpWidget(createTestWidget(ticket: testTicket));

  // 2. Find elements
  expect(find.text('WiFi Not Working'), findsOneWidget);

  // 3. Interact (optional)
  await tester.tap(find.byType(Card));
  await tester.pump();  // Rebuild after interaction

  // 4. Verify result
  expect(tapped, isTrue);
});
```

**Key Methods:**
| Method | Purpose |
|--------|---------|
| `tester.pumpWidget()` | Builds and renders the widget |
| `tester.pump()` | Triggers a rebuild (after state changes) |
| `tester.pumpAndSettle()` | Waits for all animations to complete |
| `tester.tap()` | Simulates a tap gesture |
| `tester.enterText()` | Types text into a field |
| `find.text()` | Finds widget by text content |
| `find.byType()` | Finds widget by its type (e.g., `Card`) |
| `find.byKey()` | Finds widget by its Key |

### 4.1 TicketCard Widget Tests

**What's Tested:**

| Test Case                | What It Verifies                               |
| ------------------------ | ---------------------------------------------- |
| Title display            | Ticket title text appears                      |
| Category display         | Category label is shown                        |
| Status chip              | Correct chip for Open/In Progress/Resolved     |
| Status-specific styling  | Each status has different visual treatment     |
| Reporter name visibility | Toggle shows/hides reporter                    |
| Tap callback             | `onTap` function is called when card is tapped |
| Missing image handling   | Widget doesn't crash if image URL is null      |

**Example - Testing Tap Callback:**

```dart
testWidgets('calls onTap when card is tapped', (tester) async {
  var tapped = false;  // Track if callback was called

  await mockNetworkImagesFor(() async {
    await tester.pumpWidget(createTestWidget(
      ticket: testTicket,
      onTap: () => tapped = true,  // Set flag when tapped
    ));

    await tester.tap(find.byType(Card));  // Simulate tap
    await tester.pump();                   // Process the tap

    expect(tapped, isTrue);  // ✅ Callback was invoked
  });
});
```

**Note:** `mockNetworkImagesFor()` wraps the test to handle `CachedNetworkImage` widgets.

### 4.2 CustomButton Widget Tests

**What's Tested:**

| Test Case          | What It Verifies                           |
| ------------------ | ------------------------------------------ |
| Text display       | Button label is visible                    |
| onPressed callback | Callback fires when button is pressed      |
| Loading state      | Shows spinner, hides text, disables button |
| Icon display       | Optional icon appears correctly            |
| Custom dimensions  | Width/height parameters work               |
| Custom colors      | Background/text colors apply               |

**Button Types:**

```dart
enum ButtonType {
  primary,    // Filled button with primary color
  secondary,  // Filled button with secondary color
  outlined,   // Border-only button
  text,       // Text-only button (no background)
}
```

**Example - Testing Loading State:**

```dart
testWidgets('shows loading indicator when isLoading is true', (tester) async {
  await tester.pumpWidget(createTestWidget(
    child: CustomButton(
      text: 'Submit',
      onPressed: () {},
      isLoading: true,  // Enable loading state
    ),
  ));

  // Loading indicator should appear
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  // Text should be hidden
  expect(find.text('Submit'), findsNothing);
});
```

### 4.3 CustomTextField Widget Tests

**What's Tested:**

| Test Case           | What It Verifies                               |
| ------------------- | ---------------------------------------------- |
| Label & hint text   | Decorations display correctly                  |
| Prefix/suffix icons | Icons appear in correct positions              |
| Text input          | User can type and value is captured            |
| Password obscuring  | Text is hidden when `obscureText: true`        |
| Validation errors   | Error messages appear after validation fails   |
| onChange callback   | Callback fires on each keystroke               |
| Multi-line support  | `maxLines` parameter works                     |
| Disabled state      | Field is non-interactive when disabled         |
| Keyboard type       | Correct keyboard appears (email, number, etc.) |

**Specialized Widgets Tested:**

| Widget               | Purpose                                      |
| -------------------- | -------------------------------------------- |
| `EmailTextField`     | Pre-configured with email icon & keyboard    |
| `PasswordTextField`  | Has visibility toggle (show/hide password)   |
| `SearchTextField`    | Styled for search with magnifying glass icon |
| `MultilineTextField` | Expandable text area for long input          |

**Example - Testing Password Visibility Toggle:**

```dart
testWidgets('toggles password visibility', (tester) async {
  await tester.pumpWidget(createTestWidget(
    child: PasswordTextField(controller: TextEditingController()),
  ));

  // Initially obscured
  expect(find.byIcon(Icons.visibility), findsOneWidget);

  // Tap the visibility toggle
  await tester.tap(find.byIcon(Icons.visibility));
  await tester.pump();

  // Now showing (icon changed)
  expect(find.byIcon(Icons.visibility_off), findsOneWidget);
});
```

### Widget Test Helper Pattern

All widget tests use a helper function to wrap widgets in required ancestors:

```dart
Widget createTestWidget({required Widget child}) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}
```

**Why is this needed?**

- Many widgets need `MaterialApp` ancestor for theming
- `Scaffold` provides proper layout context
- Avoids repeating this boilerplate in every test

### Widget Tests vs Unit Tests

| Aspect            | Unit Tests   | Widget Tests                         |
| ----------------- | ------------ | ------------------------------------ |
| **Speed**         | Milliseconds | Seconds                              |
| **What's tested** | Pure logic   | UI + interactions                    |
| **Dependencies**  | None         | Widget tree, themes                  |
| **Finders**       | N/A          | `find.text()`, `find.byType()`       |
| **Interactions**  | N/A          | `tester.tap()`, `tester.enterText()` |

---

## Phase 5: Test Helpers

### Overview

Test helpers are **reusable utility functions** that create test data and reduce code duplication. They live in `test/helpers/test_helpers.dart` and are imported wherever needed.

### Why Use Test Helpers?

**Without helpers (repetitive and error-prone):**

```dart
// Test 1
final user = UserModel(
  uid: 'test-uid',
  email: 'test@example.com',
  name: 'Test User',
  role: 'user',
  createdAt: DateTime.now(),
);

// Test 2 - copy-paste the same thing
final user2 = UserModel(
  uid: 'test-uid',
  email: 'test@example.com',
  name: 'Test User',
  role: 'user',
  createdAt: DateTime.now(),
);
```

**With helpers (clean and maintainable):**

```dart
// Test 1
final user = createTestUser();

// Test 2
final user2 = createTestUser(name: 'Different Name');
```

### Factory Functions

#### 1. **createTestUser()**

Creates a `UserModel` with sensible defaults that can be overridden:

```dart
UserModel createTestUser({
  String uid = 'test-uid',
  String email = 'test@example.com',
  String name = 'Test User',
  String role = 'user',
  String? department,
  String? photoUrl,
  DateTime? createdAt,
});
```

**Usage Examples:**

```dart
// Default user
final user = createTestUser();

// Custom email
final user = createTestUser(email: 'custom@test.com');

// Admin user with department
final admin = createTestUser(
  role: 'admin',
  department: 'IT Support',
);
```

#### 2. **createTestAdmin()**

Shorthand for creating an admin user:

```dart
UserModel createTestAdmin({
  String uid = 'admin-uid',
  String email = 'admin@example.com',
  String name = 'Admin User',
});
```

**Why a separate function?**

- Admins are used frequently in tests
- Makes test intent clearer: `createTestAdmin()` vs `createTestUser(role: 'admin')`

#### 3. **createTestTicket()**

Creates a `TicketModel` with all fields having defaults:

```dart
TicketModel createTestTicket({
  String id = 'ticket-id',
  String title = 'Test Ticket',
  String description = 'This is a test ticket description',
  TicketCategory category = TicketCategory.it,
  TicketPriority priority = TicketPriority.medium,
  TicketStatus status = TicketStatus.open,
  String? imageUrl,
  String? assignedTo,
  // ... more options
});
```

**Usage Examples:**

```dart
// Default open ticket
final ticket = createTestTicket();

// Resolved high-priority ticket
final ticket = createTestTicket(
  status: TicketStatus.resolved,
  priority: TicketPriority.high,
);

// Ticket with specific category
final ticket = createTestTicket(
  category: TicketCategory.electrical,
  title: 'Light Not Working',
);
```

#### 4. **createTestTicketList()**

Creates multiple tickets for testing lists/grids:

```dart
List<TicketModel> createTestTicketList({
  int count = 5,
  String? userId,
});
```

**Usage:**

```dart
// Get 5 tickets (default)
final tickets = createTestTicketList();

// Get 10 tickets for a specific user
final userTickets = createTestTicketList(
  count: 10,
  userId: 'user-123',
);
```

**Why this is useful:**

- Testing pagination
- Testing empty states (pass `count: 0`)
- Testing list rendering performance

#### 5. **createTestTicketCounts()**

Creates a map of ticket counts by status:

```dart
Map<String, int> createTestTicketCounts({
  int open = 5,
  int inProgress = 3,
  int resolved = 10,
});
```

**Returns:**

```dart
{
  'open': 5,
  'inProgress': 3,
  'resolved': 10,
}
```

**Usage:**

```dart
// Test dashboard with custom counts
final counts = createTestTicketCounts(
  open: 15,
  inProgress: 7,
  resolved: 42,
);

expect(counts['open'], 15);
```

### Benefits of Test Helpers

| Benefit                         | Explanation                              |
| ------------------------------- | ---------------------------------------- |
| **DRY (Don't Repeat Yourself)** | Write factory once, use everywhere       |
| **Consistency**                 | All tests use the same valid test data   |
| **Maintainability**             | Model changes? Update one place          |
| **Readability**                 | Test code focuses on what's being tested |
| **Flexibility**                 | Override only what matters for each test |
| **Type Safety**                 | Factories return properly typed objects  |

### Best Practices for Test Helpers

1. **Use sensible defaults** - The default object should be valid and usable

2. **Make everything optional** - Tests should only specify what they care about

3. **Name clearly** - `createTestUser()` not `makeUser()` or `getUser()`

4. **Keep in one file** - Easy to find and import

5. **Document special cases** - If a parameter has side effects, document it

```dart
/// Creates a test ticket.
/// If [assignedTo] is provided, [status] defaults to inProgress.
TicketModel createTestTicket({...});
```

---

## Phase 6: Code Refactoring for Testability

### Overview

This section covers **Dependency Injection (DI)** - a design pattern that makes code testable by allowing you to swap real services with mock ones during testing.

### The Problem: Tight Coupling

When a class creates its own dependencies internally, it's **tightly coupled** and nearly impossible to test in isolation.

#### ❌ Before (Not Testable)

```dart
class TicketProvider extends ChangeNotifier {
  // Dependencies created INSIDE the class
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  Future<void> loadTickets() async {
    // This ALWAYS hits real Firebase - can't test without it!
    final tickets = await _firestoreService.getTickets();
    // ...
  }
}
```

**Why is this bad for testing?**

- `FirestoreService()` requires Firebase to be initialized
- Tests need network access and a real database
- Tests are slow, flaky, and expensive
- Can't test error scenarios (how do you make Firebase fail on demand?)

### The Solution: Dependency Injection

**Inject** dependencies from outside instead of creating them inside.

#### ✅ After (Testable)

```dart
class TicketProvider extends ChangeNotifier {
  late final FirestoreService _firestoreService;
  late final StorageService _storageService;

  /// Default constructor - uses real Firebase services (for production)
  TicketProvider() {
    _firestoreService = FirestoreService();
    _storageService = StorageService();
  }

  /// Test constructor - allows injecting mock services
  @visibleForTesting
  TicketProvider.forTesting({
    required FirestoreService firestoreService,
    required StorageService storageService,
  }) {
    _firestoreService = firestoreService;
    _storageService = storageService;
  }

  Future<void> loadTickets() async {
    // Now this can use REAL or MOCK service!
    final tickets = await _firestoreService.getTickets();
    // ...
  }
}
```

### How It Works

#### Production Code (unchanged):

```dart
// App still works exactly the same
final provider = TicketProvider();  // Uses real Firebase
```

#### Test Code (now possible):

```dart
// Create mock services
final mockFirestore = MockFirestoreService();
final mockStorage = MockStorageService();

// Configure mock behavior
when(mockFirestore.getTickets()).thenReturn([
  createTestTicket(title: 'Mock Ticket 1'),
  createTestTicket(title: 'Mock Ticket 2'),
]);

// Inject mocks into provider
final provider = TicketProvider.forTesting(
  firestoreService: mockFirestore,
  storageService: mockStorage,
);

// Test the provider with controlled data
await provider.loadTickets();
expect(provider.tickets.length, 2);
```

### Key Concepts

#### 1. **Named Constructors**

Dart allows multiple constructors with different names:

```dart
class TicketProvider {
  TicketProvider()           // Default (production)
  TicketProvider.forTesting  // Named (testing)
}
```

#### 2. **@visibleForTesting Annotation**

Marks a member as intended only for tests:

```dart
@visibleForTesting
TicketProvider.forTesting({...})
```

- IDE shows warning if used in non-test code
- Documents intent clearly
- Doesn't prevent usage (just advisory)

#### 3. **late Keyword**

`late` tells Dart the variable will be assigned before first use:

```dart
late final FirestoreService _firestoreService;

TicketProvider() {
  _firestoreService = FirestoreService();  // Assigned here
}
```

### What This Pattern Enables

| Capability              | Example                                      |
| ----------------------- | -------------------------------------------- |
| **Test success paths**  | Mock returns valid data                      |
| **Test error handling** | Mock throws exceptions                       |
| **Test edge cases**     | Mock returns empty list, null values         |
| **Test loading states** | Mock delays response                         |
| **Verify interactions** | Check if method was called with correct args |

**Example - Testing Error Handling:**

```dart
test('shows error when loading fails', () async {
  // Make the mock throw an error
  when(mockFirestore.getTickets())
      .thenThrow(Exception('Network error'));

  final provider = TicketProvider.forTesting(
    firestoreService: mockFirestore,
    storageService: mockStorage,
  );

  await provider.loadTickets();

  expect(provider.hasError, isTrue);
  expect(provider.errorMessage, contains('Network error'));
});
```

### Before vs After Summary

| Aspect              | Before (Tight Coupling) | After (Dependency Injection) |
| ------------------- | ----------------------- | ---------------------------- |
| **Dependencies**    | Created internally      | Injected from outside        |
| **Testing**         | Requires real Firebase  | Uses mock services           |
| **Speed**           | Slow (network calls)    | Fast (in-memory)             |
| **Reliability**     | Flaky (network issues)  | Consistent                   |
| **Cost**            | Firebase charges        | Free                         |
| **Production code** | Same                    | Same (unchanged)             |
| **Flexibility**     | None                    | Full control in tests        |

### Alternative DI Approaches

The document uses a simple approach, but other options exist:

| Approach                          | Pros                      | Cons                              |
| --------------------------------- | ------------------------- | --------------------------------- |
| **Named constructor** (used here) | Simple, no extra packages | Two constructors to maintain      |
| **Constructor injection**         | Single constructor        | Changes production code signature |
| **get_it package**                | Service locator pattern   | Extra dependency                  |
| **riverpod**                      | Built-in overrides        | Requires riverpod architecture    |

---

## Phase 7: Running Tests

### Overview

This section covers the **commands** used to run tests in Flutter, from running individual tests to generating coverage reports.

### Basic Commands

#### Run All Tests

```bash
flutter test
```

Runs every test file in the `test/` directory.

#### Run All Unit Tests Only

```bash
flutter test test/unit/
```

Runs only tests inside the `test/unit/` folder (skips widget tests).

#### Run All Widget Tests Only

```bash
flutter test test/widget/
```

Runs only widget tests.

#### Run a Specific Test File

```bash
flutter test test/unit/models/user_model_test.dart
```

Runs just one test file - useful when working on specific functionality.

### Coverage Reports

#### Generate Coverage Data

```bash
flutter test --coverage
```

This runs all tests and generates a coverage report at `coverage/lcov.info`.

**What is coverage?**

- Shows which lines of code were executed during tests
- Helps identify untested code paths
- Expressed as a percentage (e.g., 85% coverage)

#### Generate HTML Report (Visual)

```bash
# Generate the HTML from lcov data
genhtml coverage/lcov.info -o coverage/html

# Open in browser (macOS)
open coverage/html/index.html
```

**Note:** You need `lcov` installed for `genhtml`:

```bash
# macOS
brew install lcov

# Linux
sudo apt-get install lcov
```

### Command Summary Table

| Command                                  | What It Does                      |
| ---------------------------------------- | --------------------------------- |
| `flutter test`                           | Run all tests                     |
| `flutter test test/unit/`                | Run tests in a directory          |
| `flutter test path/to/file_test.dart`    | Run single test file              |
| `flutter test --coverage`                | Run tests + generate coverage     |
| `flutter test --name "test name"`        | Run tests matching a name pattern |
| `flutter test --plain-name "exact name"` | Run test with exact name          |
| `flutter test --reporter expanded`       | Verbose output (show each test)   |

### Useful Flags

#### `--reporter` - Control Output Format

```bash
# Compact (default) - dots for pass, F for fail
flutter test

# Expanded - shows each test name
flutter test --reporter expanded

# JSON - machine-readable output
flutter test --reporter json
```

**Expanded output example:**

```
✓ UserModel constructor creates user with required fields
✓ UserModel isAdmin returns true for admin role
✓ UserModel isUser returns true for user role
✓ Validators validateEmail returns error for null
...
```

#### `--name` / `--plain-name` - Filter Tests

```bash
# Run tests containing "email" in name
flutter test --name "email"

# Run test with exact name
flutter test --plain-name "validates email returns null for valid email"
```

#### `--fail-fast` - Stop on First Failure

```bash
flutter test --fail-fast
```

Stops running tests as soon as one fails. Useful for quick debugging.

#### `--concurrency` - Parallel Execution

```bash
# Run tests on 4 parallel isolates
flutter test --concurrency=4
```

Speeds up test runs on multi-core machines.

### Integration Tests

Integration tests run on a real device/emulator:

```bash
# Run on connected device
flutter test integration_test/app_test.dart

# Run on specific device
flutter test integration_test/ -d <device_id>
```

### Typical Workflow

```bash
# 1. Working on a feature - run related tests frequently
flutter test test/unit/models/ticket_model_test.dart

# 2. Before committing - run all tests
flutter test

# 3. For PR/CI - run with coverage
flutter test --coverage

# 4. Debug a failing test - run with expanded output
flutter test --reporter expanded --fail-fast
```

### Test Output Interpretation

| Symbol     | Meaning                       |
| ---------- | ----------------------------- |
| `.` or `✓` | Test passed                   |
| `F` or `✗` | Test failed                   |
| `E`        | Test had an error (exception) |
| `S`        | Test was skipped              |

**Example output:**

```
00:05 +96: All tests passed!
```

- `00:05` - Time elapsed (5 seconds)
- `+96` - 96 tests passed
- No `-X` means no failures

**Failed output:**

```
00:03 +45 -2: Some tests failed.
```

- 45 passed, 2 failed

---

## Phase 8: Test Results Summary

### Overview

This section provides a **snapshot of the test suite** - how many tests exist, what they cover, and their current status. This serves as documentation and a health check for the project.

### Test Count by Category

| Category               | Tests   | Status          |
| ---------------------- | ------- | --------------- |
| UserModel              | 18      | ✅ Pass         |
| TicketModel            | 28      | ✅ Pass         |
| TicketProvider Logic   | 11      | ✅ Pass         |
| AuthProvider Logic     | 12      | ✅ Pass         |
| Validators             | 26      | ✅ Pass         |
| CustomButton Widget    | 13      | ✅ Pass         |
| CustomTextField Widget | 20      | ✅ Pass         |
| TicketCard Widget      | 10      | ✅ Pass         |
| Basic Widget Tests     | 2       | ✅ Pass         |
| **Total**              | **140** | **✅ All Pass** |

### Understanding the Distribution

#### Test Pyramid

The test distribution follows the **test pyramid** pattern:

```
        /\
       /  \        Integration Tests (few)
      /----\           ↑ Slow, expensive
     /      \
    /--------\     Widget Tests (some)
   /          \        ↑ Medium speed
  /------------\
 /              \  Unit Tests (many)
/________________\     ↑ Fast, cheap
```

**This project's breakdown:**

- **Unit Tests**: 95 tests (68%)
  - Models: 46 tests
  - Providers: 23 tests
  - Validators: 26 tests
- **Widget Tests**: 45 tests (32%)
  - CustomButton: 13
  - CustomTextField: 20
  - TicketCard: 10
  - Smoke test: 2
- **Integration Tests**: Scaffolding ready (0 running)

### What Each Category Tests

#### **Model Tests (46 total)**

| Model       | Test Count | What's Covered                                              |
| ----------- | ---------- | ----------------------------------------------------------- |
| UserModel   | 18         | Constructor, serialization, equality, role checks, copyWith |
| TicketModel | 28         | Enums (3), constructor, serialization, equality, copyWith   |

**Why so many?** Models are the foundation - if they break, everything breaks.

#### **Provider Tests (23 total)**

| Provider       | Test Count | What's Covered                                             |
| -------------- | ---------- | ---------------------------------------------------------- |
| AuthProvider   | 12         | State enum, role properties, state helpers, error handling |
| TicketProvider | 11         | Filtering, case sensitivity, counts, test data             |

**Note:** These test the **logic** in providers, not Firebase integration.

#### **Validator Tests (26 total)**

| Validator               | Approx Tests | Scenarios                                   |
| ----------------------- | ------------ | ------------------------------------------- |
| validateEmail           | 4-5          | null, empty, invalid formats, valid formats |
| validatePassword        | 4            | null, empty, too short, valid               |
| validateConfirmPassword | 4            | null, empty, mismatch, match                |
| validateName            | 4            | null, empty, too short, valid               |
| validateRequired        | 3            | null, empty, valid                          |
| validateTitle           | 5            | null, empty, too short, too long, valid     |
| validateDescription     | 5            | null, empty, too short, too long, valid     |

**Why test validators thoroughly?** They protect data integrity and user experience.

#### **Widget Tests (45 total)**

| Widget          | Test Count | What's Covered                                                                          |
| --------------- | ---------- | --------------------------------------------------------------------------------------- |
| CustomButton    | 13         | Text, onPressed, loading, icon, dimensions, colors, types                               |
| CustomTextField | 20         | Label, hint, icons, input, obscure, validation, onChange, multiline, disabled, keyboard |
| TicketCard      | 10         | Title, category, status chips, reporter, tap, missing image                             |
| Smoke Test      | 2          | App launches without crashing                                                           |

### Why This Summary Matters

| Purpose               | Explanation                                |
| --------------------- | ------------------------------------------ |
| **Documentation**     | New developers see what's tested           |
| **Confidence**        | 140 passing tests = code works as expected |
| **Progress Tracking** | Compare over time (was 50, now 140)        |
| **Gap Analysis**      | See what's NOT tested (integration tests)  |
| **CI/CD Status**      | Quick pass/fail for pull requests          |

### Reading Test Results

When you run `flutter test`, you'll see:

```
00:08 +140: All tests passed!
```

This means:

- ⏱️ Took 8 seconds
- ✅ 140 tests passed
- ❌ 0 tests failed

If tests fail:

```
00:05 +138 -2: Some tests failed.

FAILED: test/unit/models/user_model_test.dart
  Expected: 'admin'
  Actual: 'user'

FAILED: test/widget/widgets/custom_button_test.dart
  Expected: find.byType(CircularProgressIndicator)
  Actual: zero widgets found
```

### Maintaining Test Health

| Metric      | Healthy | Warning  | Action Needed |
| ----------- | ------- | -------- | ------------- |
| Pass rate   | 100%    | 95-99%   | < 95%         |
| Run time    | < 30s   | 30s-2min | > 2min        |
| Coverage    | > 80%   | 60-80%   | < 60%         |
| Flaky tests | 0       | 1-2      | > 2           |

**Flaky test** = passes sometimes, fails sometimes (usually timing issues)

---

## Phase 9: QA Best Practices Implemented

### Overview

This section documents the **quality assurance principles** applied throughout the testing strategy. These are industry-standard practices that make tests reliable, maintainable, and valuable.

### 9.1 Test Organization

**Principle:** Tests should be easy to find and navigate.

| Practice               | Implementation                                            |
| ---------------------- | --------------------------------------------------------- |
| **Organized by type**  | Separate folders: `unit/`, `widget/`, `integration_test/` |
| **Grouped by feature** | `models/`, `providers/`, `widgets/` subfolders            |
| **Descriptive names**  | `user_model_test.dart`, not `test1.dart`                  |

**File naming convention:**

```
[feature]_test.dart

Examples:
  user_model_test.dart
  auth_provider_test.dart
  custom_button_test.dart
```

**Test naming convention:**

```dart
// Pattern: [action] [expected result] [condition]
test('returns error for invalid email formats', ...);
test('isAdmin returns true for admin role', ...);
test('calls onTap when card is tapped', ...);
```

### 9.2 Test Isolation

**Principle:** Each test should be independent - passing or failing regardless of other tests.

| Practice                    | Why It Matters                        |
| --------------------------- | ------------------------------------- |
| **Independent tests**       | Can run in any order                  |
| **setUp() / tearDown()**    | Fresh state for each test             |
| **No shared mutable state** | Tests don't interfere with each other |

**Example - Proper Setup:**

```dart
group('TicketProvider', () {
  late TicketProvider provider;
  late MockFirestoreService mockFirestore;

  setUp(() {
    // Fresh instances for EVERY test
    mockFirestore = MockFirestoreService();
    provider = TicketProvider.forTesting(
      firestoreService: mockFirestore,
      storageService: MockStorageService(),
    );
  });

  tearDown(() {
    // Clean up if needed
    provider.dispose();
  });

  test('test 1', () {
    // Uses fresh provider
  });

  test('test 2', () {
    // Also uses fresh provider - not affected by test 1
  });
});
```

**❌ Anti-pattern - Shared State:**

```dart
// BAD: Tests share the same instance
final provider = TicketProvider();  // Created once

test('test 1', () {
  provider.addTicket(...);  // Modifies shared state
});

test('test 2', () {
  // This test sees the ticket from test 1!
  // Will fail if run alone or in different order
});
```

### 9.3 Comprehensive Coverage

**Principle:** Test all important scenarios, not just the "happy path."

| Coverage Type         | Example                             |
| --------------------- | ----------------------------------- |
| **Happy path**        | Valid email returns null (no error) |
| **Edge cases**        | Empty string, null, boundary values |
| **Error conditions**  | Invalid format, too long/short      |
| **State transitions** | Loading → Success, Loading → Error  |

**Example - Comprehensive Email Validation:**

```dart
group('validateEmail', () {
  // Happy path
  test('returns null for valid email', () {
    expect(Validators.validateEmail('user@example.com'), isNull);
  });

  // Edge cases
  test('returns error for null', () {
    expect(Validators.validateEmail(null), isNotNull);
  });

  test('returns error for empty string', () {
    expect(Validators.validateEmail(''), isNotNull);
  });

  // Error conditions - various invalid formats
  test('returns error for missing @', () {
    expect(Validators.validateEmail('userexample.com'), isNotNull);
  });

  test('returns error for missing domain', () {
    expect(Validators.validateEmail('user@'), isNotNull);
  });

  test('returns error for missing TLD', () {
    expect(Validators.validateEmail('user@example'), isNotNull);
  });
});
```

### 9.4 Maintainability

**Principle:** Tests should be easy to update when code changes.

| Practice                     | Benefit                        |
| ---------------------------- | ------------------------------ |
| **Test helper functions**    | Reduce duplication             |
| **Factory functions**        | Centralized test data creation |
| **Reusable widget wrappers** | DRY widget test setup          |

**Helper Function Example:**

```dart
// Instead of repeating this in every widget test...
await tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: CustomButton(text: 'Click', onPressed: () {}),
    ),
  ),
);

// Create a helper
Widget createTestWidget({required Widget child}) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

// Now tests are cleaner
await tester.pumpWidget(createTestWidget(
  child: CustomButton(text: 'Click', onPressed: () {}),
));
```

**Factory Function Example:**

```dart
// If UserModel constructor changes (adds required field),
// update ONE function instead of 50 tests
UserModel createTestUser({
  String uid = 'test-uid',
  String email = 'test@example.com',
  String name = 'Test User',
  String role = 'user',
  String region = 'US',  // New field - add default here
});
```

### 9.5 Mock Strategy

**Principle:** Mock external dependencies, test real logic.

| Component          | Mock or Real? | Reason                                 |
| ------------------ | ------------- | -------------------------------------- |
| Firebase Firestore | Mock          | External service, slow, costs money    |
| Firebase Auth      | Mock          | External service, requires credentials |
| Network images     | Mock          | Network calls fail in test environment |
| Models             | Real          | Pure Dart, no dependencies             |
| Validators         | Real          | Pure functions, no dependencies        |
| Provider logic     | Real          | Core business logic to verify          |

**Mock Strategy Diagram:**

```
┌─────────────────────────────────────────────┐
│                 TEST                        │
│  ┌─────────────────────────────────────┐    │
│  │     Provider (REAL logic)           │    │
│  │  ┌─────────────┐ ┌───────────────┐  │    │
│  │  │ FirestoreService │ StorageService │  │    │
│  │  │    (MOCK)    │    (MOCK)      │  │    │
│  │  └─────────────┘ └───────────────┘  │    │
│  └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘

You test the REAL provider logic
with MOCK services injected
```

### Summary of QA Practices

| Practice            | What                                  | Why                     |
| ------------------- | ------------------------------------- | ----------------------- |
| **Organization**    | Logical folder structure              | Easy to find tests      |
| **Isolation**       | Independent tests with setUp/tearDown | Reliable, reproducible  |
| **Coverage**        | Happy path + edge cases + errors      | Catch bugs before users |
| **Maintainability** | Helpers, factories, DRY               | Easy to update          |
| **Mocking**         | Mock externals, test logic            | Fast, reliable, free    |

---

## Phase 10: Integration Test Structure

### Overview

Integration tests verify **complete user flows** by running the app on a real device or emulator. Unlike unit/widget tests that test pieces in isolation, integration tests ensure everything works together.

### What Are Integration Tests?

| Aspect           | Unit/Widget Tests      | Integration Tests      |
| ---------------- | ---------------------- | ---------------------- |
| **Scope**        | Single function/widget | Full app flow          |
| **Environment**  | Test framework         | Real device/emulator   |
| **Speed**        | Milliseconds           | Seconds to minutes     |
| **Dependencies** | Mocked                 | Real (or emulated)     |
| **Purpose**      | Verify logic           | Verify user experience |

### Integration Test Location

```
integration_test/
└── app_test.dart    # Main integration test file
```

**Note:** Integration tests live in `integration_test/` (at project root), NOT in `test/`.

### Scaffolding Structure

The document shows **prepared scaffolding** - test structure is in place but requires Firebase Emulator setup to actually run:

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fixit/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Launch Tests', () {
    testWidgets('App launches successfully', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify app started
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Auth Flow Tests', () {
    testWidgets('Login flow works correctly', (tester) async {
      // Requires Firebase emulator setup
      // TODO: Implement when emulator is configured
    });

    testWidgets('Registration flow works correctly', (tester) async {
      // Requires Firebase emulator setup
      // TODO: Implement when emulator is configured
    });
  });

  group('Ticket Flow Tests', () {
    testWidgets('Create ticket flow', (tester) async {
      // TODO: Test creating a new ticket
    });

    testWidgets('View ticket details', (tester) async {
      // TODO: Test viewing ticket details
    });

    testWidgets('Update ticket status', (tester) async {
      // TODO: Test admin changing ticket status
    });
  });
}
```

### Planned Test Flows

#### 1. **App Launch Verification**

```
Start App → Verify splash/loading → Land on correct screen
```

#### 2. **Authentication Flow**

```
Login:
  Open App → See Login Screen → Enter Credentials → Tap Login → See Dashboard

Registration:
  Open App → Tap Register → Fill Form → Submit → See Dashboard

Logout:
  Dashboard → Open Menu → Tap Logout → See Login Screen
```

#### 3. **Ticket Operations**

```
Create:
  Dashboard → Tap "+" → Fill Form → Submit → See new ticket in list

View:
  Dashboard → Tap Ticket → See Details Screen → Verify all info shown

Update Status (Admin):
  Details → Change Status → Save → Verify status updated
```

### Firebase Emulator Requirement

Integration tests need the **Firebase Emulator Suite** to avoid hitting production:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Start emulators
firebase emulators:start --only auth,firestore,storage
```

**Emulator configuration:**

```dart
// Before running tests
await Firebase.initializeApp();

// Point to local emulators instead of production
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
```

### Running Integration Tests

```bash
# Run on connected device
flutter test integration_test/app_test.dart

# Run on specific device
flutter test integration_test/ -d <device_id>

# Run on Chrome (web)
flutter test integration_test/ -d chrome
```

### Integration Test Patterns

#### Pattern 1: Navigate and Verify

```dart
testWidgets('navigates to ticket details', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  // Find and tap a ticket
  await tester.tap(find.text('WiFi Not Working'));
  await tester.pumpAndSettle();

  // Verify we're on details screen
  expect(find.text('Ticket Details'), findsOneWidget);
  expect(find.text('WiFi Not Working'), findsOneWidget);
});
```

#### Pattern 2: Fill Form and Submit

```dart
testWidgets('creates a new ticket', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  // Navigate to create screen
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  // Fill form
  await tester.enterText(
    find.byKey(Key('title_field')),
    'Printer Not Working',
  );
  await tester.enterText(
    find.byKey(Key('description_field')),
    'The office printer is jammed and needs repair.',
  );

  // Submit
  await tester.tap(find.text('Submit'));
  await tester.pumpAndSettle();

  // Verify ticket was created
  expect(find.text('Printer Not Working'), findsOneWidget);
});
```

#### Pattern 3: Authentication Flow

```dart
testWidgets('login with valid credentials', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  // Enter credentials
  await tester.enterText(
    find.byKey(Key('email_field')),
    'test@example.com',
  );
  await tester.enterText(
    find.byKey(Key('password_field')),
    'password123',
  );

  // Tap login
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();

  // Verify logged in
  expect(find.text('Dashboard'), findsOneWidget);
  expect(find.text('Login'), findsNothing);
});
```

### Why Scaffolding First?

| Reason            | Explanation                                       |
| ----------------- | ------------------------------------------------- |
| **Planning**      | Define what needs testing before writing tests    |
| **Structure**     | Establish patterns early                          |
| **Parallel work** | Others can implement while emulator is configured |
| **Documentation** | Shows intended test coverage                      |

### Integration Test vs E2E Test

| Term                 | Meaning in Flutter                             |
| -------------------- | ---------------------------------------------- |
| **Integration Test** | Official Flutter term for tests on real device |
| **E2E (End-to-End)** | Same thing, different terminology              |
| **Driver Test**      | Older Flutter term (deprecated)                |

---

## Phase 11: Future Improvements

### Overview

This section outlines **advanced testing techniques** and **CI/CD integration** that can be added to further strengthen the test suite. These are recommendations for when the project matures.

### Recommended Additions

#### 1. **Golden Tests (Visual Regression Testing)**

**What they do:** Capture screenshots of widgets and compare against saved "golden" images to detect unintended visual changes.

```dart
testWidgets('TicketCard matches golden image', (tester) async {
  await tester.pumpWidget(createTestWidget(
    child: TicketCard(ticket: testTicket),
  ));

  await expectLater(
    find.byType(TicketCard),
    matchesGoldenFile('goldens/ticket_card.png'),
  );
});
```

**Benefits:**
| Benefit | Description |
|---------|-------------|
| Catch visual bugs | Spacing, colors, fonts that change unexpectedly |
| Design consistency | Ensure UI matches design specs |
| Review changes | PR shows visual diff of what changed |

**Workflow:**

```bash
# Generate/update golden files
flutter test --update-goldens

# Run tests (compare against goldens)
flutter test
```

#### 2. **Performance Tests**

**What they do:** Measure how long widgets take to build and render, catching performance regressions.

```dart
testWidgets('TicketList builds in under 16ms', (tester) async {
  final stopwatch = Stopwatch()..start();

  await tester.pumpWidget(createTestWidget(
    child: TicketList(tickets: createTestTicketList(count: 100)),
  ));

  stopwatch.stop();

  // 16ms = one frame at 60fps
  expect(stopwatch.elapsedMilliseconds, lessThan(16));
});
```

**What to measure:**

- Widget build time
- Frame render time
- Scroll performance (jank)
- Memory usage

#### 3. **Accessibility Tests**

**What they do:** Verify the app is usable by people with disabilities (screen readers, large fonts, etc.).

```dart
testWidgets('CustomButton has semantic label', (tester) async {
  await tester.pumpWidget(createTestWidget(
    child: CustomButton(
      text: 'Submit Ticket',
      onPressed: () {},
    ),
  ));

  // Verify screen reader can announce the button
  expect(
    tester.getSemantics(find.byType(CustomButton)),
    matchesSemantics(label: 'Submit Ticket'),
  );
});
```

**WCAG Compliance checks:**
| Check | What It Verifies |
|-------|------------------|
| Semantic labels | Screen readers can announce elements |
| Touch targets | Buttons are large enough (48x48 minimum) |
| Color contrast | Text is readable against background |
| Focus order | Keyboard navigation makes sense |

#### 4. **E2E Tests with Firebase Emulators**

**What they do:** Test complete user journeys with a local Firebase instance.

```dart
setUpAll(() async {
  // Connect to local emulators
  await Firebase.initializeApp();
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
});

testWidgets('complete ticket lifecycle', (tester) async {
  // 1. Login as user
  // 2. Create ticket
  // 3. Verify ticket in list
  // 4. Login as admin
  // 5. Change ticket status
  // 6. Verify status updated
});
```

### CI/CD Integration

**What it does:** Runs tests automatically on every push/pull request.

#### GitHub Actions Example

```yaml
# .github/workflows/tests.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.16.0"

      - run: flutter pub get

      - run: flutter test --coverage

      - uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info
```

#### CI/CD Pipeline Stages

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Install   │ →  │  Analyze    │ →  │    Test     │ →  │   Report    │
│   deps      │    │  (lint)     │    │  (unit +    │    │  coverage   │
│             │    │             │    │   widget)   │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

**Commands in each stage:**

```bash
# Install
flutter pub get

# Analyze (lint)
flutter analyze

# Test
flutter test --coverage

# Report (upload to Codecov, Coveralls, etc.)
# Handled by action
```

#### Branch Protection Rules

Configure GitHub to require:

| Rule               | Purpose                               |
| ------------------ | ------------------------------------- |
| All tests passing  | Can't merge broken code               |
| Coverage threshold | Maintain minimum coverage (e.g., 80%) |
| Review required    | Human verification                    |
| Up-to-date branch  | Must rebase on main first             |

### Priority of Improvements

| Priority  | Improvement         | Effort | Value                          |
| --------- | ------------------- | ------ | ------------------------------ |
| 🔴 High   | CI/CD Integration   | Medium | Very High                      |
| 🔴 High   | E2E with Emulators  | High   | High                           |
| 🟡 Medium | Golden Tests        | Low    | Medium                         |
| 🟡 Medium | Accessibility Tests | Medium | Medium                         |
| 🟢 Low    | Performance Tests   | Medium | Low (unless perf issues exist) |

### When to Add Each

| Improvement       | When to Add                                       |
| ----------------- | ------------------------------------------------- |
| **CI/CD**         | Immediately - essential for team collaboration    |
| **E2E Tests**     | Before first production release                   |
| **Golden Tests**  | When UI stabilizes / design system is established |
| **Accessibility** | Before public release / if targeting enterprise   |
| **Performance**   | When users report slowness or for large lists     |

---

## Phase 12: Common Testing Patterns

### Overview

This section provides **reusable code patterns** that you'll use repeatedly when writing tests. Think of these as templates you can copy and adapt.

### Pattern 1: Widget Test Setup

**Problem:** Every widget test needs a `MaterialApp` wrapper, and repeating this is tedious.

**Solution:** Create a helper function:

```dart
Widget createTestWidget({required Widget child}) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}
```

**Usage:**

```dart
testWidgets('button displays text', (tester) async {
  await tester.pumpWidget(createTestWidget(
    child: CustomButton(text: 'Click Me', onPressed: () {}),
  ));

  expect(find.text('Click Me'), findsOneWidget);
});
```

**Extended version with theme and providers:**

```dart
Widget createTestWidget({
  required Widget child,
  ThemeData? theme,
  List<ChangeNotifierProvider>? providers,
}) {
  Widget result = MaterialApp(
    theme: theme ?? ThemeData.light(),
    home: Scaffold(body: child),
  );

  if (providers != null) {
    result = MultiProvider(providers: providers, child: result);
  }

  return result;
}
```

### Pattern 2: Network Image Mocking

**Problem:** `CachedNetworkImage` or `Image.network` fails in tests because there's no real network.

**Solution:** Wrap tests with `mockNetworkImagesFor()`:

```dart
import 'package:network_image_mock/network_image_mock.dart';

testWidgets('displays profile image', (tester) async {
  await mockNetworkImagesFor(() async {
    await tester.pumpWidget(createTestWidget(
      child: ProfileAvatar(imageUrl: 'https://example.com/photo.jpg'),
    ));

    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });
});
```

**How it works:**

- Intercepts HTTP image requests
- Returns a transparent 1x1 pixel image
- Widget renders without crashing

### Pattern 3: Provider Testing

**Problem:** Need to test widgets that depend on providers.

**Solution:** Wrap with `ChangeNotifierProvider` and inject mock/test providers:

```dart
testWidgets('displays ticket count from provider', (tester) async {
  // Create provider with mock services
  final ticketProvider = TicketProvider.forTesting(
    firestoreService: MockFirestoreService(),
    storageService: MockStorageService(),
  );

  // Pre-populate with test data
  ticketProvider.setTickets(createTestTicketList(count: 5));

  await tester.pumpWidget(
    ChangeNotifierProvider<TicketProvider>.value(
      value: ticketProvider,
      child: const MaterialApp(
        home: TicketDashboard(),
      ),
    ),
  );

  expect(find.text('5 tickets'), findsOneWidget);
});
```

### Pattern 4: Testing Callbacks

**Problem:** Verify that a callback (like `onTap`, `onPressed`) is actually called.

**Solution:** Use a flag or counter variable:

```dart
testWidgets('calls onPressed when button is tapped', (tester) async {
  var wasPressed = false;  // Track callback

  await tester.pumpWidget(createTestWidget(
    child: CustomButton(
      text: 'Submit',
      onPressed: () => wasPressed = true,  // Set flag
    ),
  ));

  // Before tap
  expect(wasPressed, isFalse);

  // Tap the button
  await tester.tap(find.text('Submit'));
  await tester.pump();

  // After tap
  expect(wasPressed, isTrue);
});
```

**With arguments:**

```dart
testWidgets('calls onTicketSelected with correct ticket', (tester) async {
  TicketModel? selectedTicket;

  await tester.pumpWidget(createTestWidget(
    child: TicketList(
      tickets: [testTicket],
      onTicketSelected: (ticket) => selectedTicket = ticket,
    ),
  ));

  await tester.tap(find.byType(TicketCard));
  await tester.pump();

  expect(selectedTicket, isNotNull);
  expect(selectedTicket!.id, testTicket.id);
});
```

### Pattern 5: Testing Async Operations

**Problem:** Widget shows loading state, then data. Need to test both.

**Solution:** Use `pump()` to control when the UI updates:

```dart
testWidgets('shows loading then data', (tester) async {
  await tester.pumpWidget(createTestWidget(
    child: DataWidget(),
  ));

  // Initial state: loading
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  expect(find.text('Data loaded'), findsNothing);

  // Let async operation complete
  await tester.pumpAndSettle();

  // Final state: data loaded
  expect(find.byType(CircularProgressIndicator), findsNothing);
  expect(find.text('Data loaded'), findsOneWidget);
});
```

| Method            | When to Use                                 |
| ----------------- | ------------------------------------------- |
| `pump()`          | Trigger single frame rebuild                |
| `pump(Duration)`  | Advance by specific time                    |
| `pumpAndSettle()` | Wait for all animations/futures to complete |

### Pattern 6: Testing Form Validation

**Problem:** Need to verify form validation messages appear.

**Solution:** Enter text, trigger validation, check for error:

```dart
testWidgets('shows error for invalid email', (tester) async {
  final formKey = GlobalKey<FormState>();

  await tester.pumpWidget(createTestWidget(
    child: Form(
      key: formKey,
      child: CustomTextField(
        label: 'Email',
        validator: Validators.validateEmail,
      ),
    ),
  ));

  // Enter invalid email
  await tester.enterText(find.byType(TextField), 'not-an-email');

  // Trigger validation
  formKey.currentState!.validate();
  await tester.pump();

  // Error message should appear
  expect(find.text('Please enter a valid email'), findsOneWidget);
});
```

### Pattern 7: Testing Navigation

**Problem:** Need to verify tapping something navigates to a new screen.

**Solution:** Check for the new screen's content:

```dart
testWidgets('navigates to detail screen on tap', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: TicketListScreen(),
    routes: {
      '/details': (context) => TicketDetailScreen(),
    },
  ));

  // Tap a ticket
  await tester.tap(find.text('WiFi Not Working'));
  await tester.pumpAndSettle();

  // Should now be on detail screen
  expect(find.text('Ticket Details'), findsOneWidget);
  expect(find.text('WiFi Not Working'), findsOneWidget);
});
```

### Quick Reference Table

| Pattern        | Use Case                   | Key Technique                        |
| -------------- | -------------------------- | ------------------------------------ |
| Widget Setup   | Every widget test          | Helper function with `MaterialApp`   |
| Network Images | Widgets with remote images | `mockNetworkImagesFor()`             |
| Providers      | State management testing   | `ChangeNotifierProvider.value()`     |
| Callbacks      | Verify interactions        | Boolean flag / captured variable     |
| Async          | Loading states             | `pump()` vs `pumpAndSettle()`        |
| Validation     | Form error messages        | `formKey.currentState!.validate()`   |
| Navigation     | Screen transitions         | Check for destination screen content |

---

## Summary

This document covered all 12 sections of the Testing & QA documentation:

| #   | Section                     | Key Takeaway                                         |
| --- | --------------------------- | ---------------------------------------------------- |
| 1   | Testing Architecture        | Organize tests by type (unit/widget/integration)     |
| 2   | Testing Dependencies        | Mock Firebase, images, and external services         |
| 3   | Unit Tests                  | Test models, validators, provider logic in isolation |
| 4   | Widget Tests                | Test UI rendering and user interactions              |
| 5   | Test Helpers                | Factory functions reduce duplication                 |
| 6   | Refactoring for Testability | Dependency injection enables mocking                 |
| 7   | Running Tests               | `flutter test` with various flags                    |
| 8   | Test Results                | 140 tests across all categories                      |
| 9   | QA Best Practices           | Isolation, coverage, maintainability                 |
| 10  | Integration Tests           | Scaffold for E2E testing with emulators              |
| 11  | Future Improvements         | Golden tests, CI/CD, accessibility                   |
| 12  | Common Patterns             | Reusable templates for testing                       |

**The testing foundation gives you:**

- ✅ Confidence that code works as expected
- ✅ Safety net for refactoring
- ✅ Documentation through tests
- ✅ Fast feedback during development

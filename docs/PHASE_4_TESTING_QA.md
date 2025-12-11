# Phase 4: Testing, Bugs & Refactoring, App QA Techniques

## Overview

This phase focuses on establishing a robust testing infrastructure, identifying bugs, refactoring code for testability, and implementing QA best practices for the FixIt Now application.

---

## 1. Testing Architecture

### Test Types Implemented

```
test/
├── helpers/
│   └── test_helpers.dart          # Test utilities & factories
├── unit/
│   ├── models/
│   │   ├── user_model_test.dart   # UserModel unit tests
│   │   └── ticket_model_test.dart # TicketModel unit tests
│   ├── providers/
│   │   ├── auth_provider_test.dart    # AuthProvider tests
│   │   └── ticket_provider_test.dart  # TicketProvider tests
│   └── utils/
│       └── validators_test.dart   # Form validator tests
├── widget/
│   └── widgets/
│       ├── ticket_card_test.dart      # TicketCard widget tests
│       ├── custom_button_test.dart    # CustomButton tests
│       └── custom_text_field_test.dart # CustomTextField tests
└── widget_test.dart               # App smoke test

integration_test/
└── app_test.dart                  # Integration test scaffolding
```

---

## 2. Testing Dependencies

Added to `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter # Flutter SDK integration tests
  flutter_lints: ^6.0.0

  # Testing
  mockito: ^5.4.4 # Mocking framework
  build_runner: ^2.4.12 # Code generation
  fake_cloud_firestore: ^3.1.0 # Firestore mocking
  firebase_auth_mocks: ^0.14.1 # Auth mocking
  google_sign_in_mocks: ^0.3.0 # Google Sign-In mocking
  network_image_mock: ^2.1.1 # Network image mocking
```

> **Note:** The `integration_test` package is part of the Flutter SDK and must be declared with `sdk: flutter` rather than a version number.

---

## 3. Unit Tests

### 3.1 Model Tests

#### UserModel Tests (`test/unit/models/user_model_test.dart`)

Tests cover:

- **Constructor**: Required and optional fields
- **Role checks**: `isAdmin`, `isUser` computed properties
- **Serialization**: `fromMap()`, `toMap()` conversions
- **Immutability**: `copyWith()` method
- **Equality**: `==` operator and `hashCode`
- **String representation**: `toString()`

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

    expect(adminUser.isAdmin, isTrue);
    expect(adminUser.isUser, isFalse);
  });
});
```

#### TicketModel Tests (`test/unit/models/ticket_model_test.dart`)

Tests cover:

- **Enums**: `TicketCategory`, `TicketPriority`, `TicketStatus`
  - `fromString()` parsing (case insensitive)
  - `displayName` property
  - Default values for unknown strings
- **Model construction**: All required and optional fields
- **Serialization**: `toMap()` conversion
- **Immutability**: `copyWith()` method
- **Equality**: Based on ticket ID

```dart
group('TicketStatus Enum', () {
  test('fromString is case insensitive', () {
    expect(TicketStatus.fromString('open'), TicketStatus.open);
    expect(TicketStatus.fromString('OPEN'), TicketStatus.open);
    expect(TicketStatus.fromString('in progress'), TicketStatus.inProgress);
  });

  test('fromString returns open for unknown status', () {
    expect(TicketStatus.fromString('Unknown'), TicketStatus.open);
  });
});
```

### 3.2 Validator Tests (`test/unit/utils/validators_test.dart`)

Comprehensive validation testing:

| Validator                 | Test Cases                                  |
| ------------------------- | ------------------------------------------- |
| `validateEmail`           | null, empty, invalid formats, valid formats |
| `validatePassword`        | null, empty, < 6 chars, valid (6+ chars)    |
| `validateConfirmPassword` | null, empty, mismatch, match                |
| `validateName`            | null, empty, < 2 chars, valid               |
| `validateRequired`        | null, empty, any non-empty                  |
| `validateTitle`           | null, empty, < 5 chars, > 100 chars, valid  |
| `validateDescription`     | null, empty, < 10 chars, > 500 chars, valid |

```dart
test('returns error for invalid email formats', () {
  expect(Validators.validateEmail('notanemail'), isNotNull);
  expect(Validators.validateEmail('missing@domain'), isNotNull);
  expect(Validators.validateEmail('@nodomain.com'), isNotNull);
});

test('returns null for valid email formats', () {
  expect(Validators.validateEmail('test@example.com'), isNull);
  expect(Validators.validateEmail('user.name@domain.org'), isNull);
});
```

### 3.3 Provider Tests

#### AuthProvider Tests (`test/unit/providers/auth_provider_test.dart`)

Tests cover:

- **AuthState enum**: All states present and indexed correctly
- **Role-based properties**: Using UserModel role checks
- **State helpers**: `isLoading`, `isAuthenticated` logic
- **Error handling**: Error code patterns

#### TicketProvider Tests (`test/unit/providers/ticket_provider_test.dart`)

Tests cover:

- **Filter logic**: Open, In Progress, Resolved, All filters
- **Case sensitivity**: Filter matching is case-insensitive
- **Ticket counts**: Map structure and values
- **Test data generation**: Helper functions validation

---

## 4. Widget Tests

### 4.1 TicketCard Widget (`test/widget/widgets/ticket_card_test.dart`)

```dart
testWidgets('displays ticket title', (tester) async {
  await mockNetworkImagesFor(() async {
    await tester.pumpWidget(createTestWidget(ticket: testTicket));
    expect(find.text('WiFi Not Working'), findsOneWidget);
  });
});

testWidgets('calls onTap when card is tapped', (tester) async {
  var tapped = false;

  await mockNetworkImagesFor(() async {
    await tester.pumpWidget(createTestWidget(
      ticket: testTicket,
      onTap: () => tapped = true,
    ));

    await tester.tap(find.byType(Card));
    await tester.pump();

    expect(tapped, isTrue);
  });
});
```

**Tests cover:**

- Title, category, status chip display
- Status-specific chip rendering (Open, In Progress, Resolved)
- Reporter name visibility toggle
- Tap callback invocation
- Graceful handling of missing image

### 4.2 CustomButton Widget (`test/widget/widgets/custom_button_test.dart`)

**Tests cover:**

- Text display
- onPressed callback
- Loading state (shows indicator, hides text, disables button)
- Icon display
- Custom dimensions
- Custom colors

**Button Types:**

- `ButtonType.primary` - Primary elevated button
- `ButtonType.secondary` - Secondary elevated button
- `ButtonType.outlined` - Outlined button style
- `ButtonType.text` - Text button style

### 4.3 CustomTextField Widget (`test/widget/widgets/custom_text_field_test.dart`)

**Tests cover:**

- Label and hint text display
- Prefix and suffix icons
- Text input acceptance
- Password obscuring
- Validation and error display
- onChange callback
- Multi-line support
- Disabled state
- Keyboard type

**Specialized Widget Tests:**

- `EmailTextField` - Email input with icon
- `PasswordTextField` - Password visibility toggle
- `SearchTextField` - Search input styling
- `MultilineTextField` - Multi-line text area

---

## 5. Test Helpers

### Test Data Factories (`test/helpers/test_helpers.dart`)

```dart
/// Creates a test UserModel with default or custom values
UserModel createTestUser({
  String uid = 'test-uid',
  String email = 'test@example.com',
  String name = 'Test User',
  String role = 'user',
  String? department,
  String? photoUrl,
  DateTime? createdAt,
});

/// Creates a test admin UserModel
UserModel createTestAdmin({
  String uid = 'admin-uid',
  String email = 'admin@example.com',
  String name = 'Admin User',
});

/// Creates a test TicketModel with default or custom values
TicketModel createTestTicket({
  String id = 'ticket-id',
  String title = 'Test Ticket',
  String description = 'This is a test ticket description',
  TicketCategory category = TicketCategory.it,
  TicketPriority priority = TicketPriority.medium,
  TicketStatus status = TicketStatus.open,
  // ... more options
});

/// Creates a list of test tickets for testing list views
List<TicketModel> createTestTicketList({int count = 5, String? userId});

/// Creates mock ticket counts map
Map<String, int> createTestTicketCounts({
  int open = 5,
  int inProgress = 3,
  int resolved = 10,
});
```

---

## 6. Code Refactoring for Testability

### 6.1 Dependency Injection Pattern

Refactored providers to support dependency injection for testing:

#### Before (Not Testable)

```dart
class TicketProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  // ...
}
```

#### After (Testable)

```dart
class TicketProvider extends ChangeNotifier {
  late final FirestoreService _firestoreService;
  late final StorageService _storageService;

  /// Default constructor - uses real Firebase services
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

  // ... rest of the class
}
```

This pattern allows:

- Production code continues to work unchanged
- Tests can inject mock services
- No Firebase initialization required in tests

---

## 7. Running Tests

### Run All Unit Tests

```bash
flutter test test/unit/
```

### Run Specific Test File

```bash
flutter test test/unit/models/user_model_test.dart
```

### Run with Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run Widget Tests

```bash
flutter test test/widget/
```

### Run All Tests

```bash
flutter test
```

---

## 8. Test Results Summary

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

---

## 9. QA Best Practices Implemented

### 9.1 Test Organization

- Tests organized by type (unit, widget, integration)
- Tests grouped by feature/component
- Clear, descriptive test names

### 9.2 Test Isolation

- Each test is independent
- `setUp()` and `tearDown()` for proper state management
- No shared mutable state between tests

### 9.3 Comprehensive Coverage

- Happy path testing
- Edge case testing (null, empty, boundary values)
- Error condition testing

### 9.4 Maintainability

- Test helper functions for common operations
- Factory functions for test data
- Reusable widget wrapper functions

### 9.5 Mock Strategy

- Network images mocked for widget tests
- Firebase services mockable via DI
- Real logic tested without external dependencies

---

## 10. Integration Test Structure

Integration tests scaffold prepared for:

- App launch verification
- Navigation flow testing
- Authentication flow (login, register, logout)
- Ticket operations (create, view, update status)

```dart
// integration_test/app_test.dart
group('Auth Flow Tests', () {
  testWidgets('Login flow works correctly', (tester) async {
    // Requires Firebase emulator setup
  });

  testWidgets('Registration flow works correctly', (tester) async {
    // Requires Firebase emulator setup
  });
});
```

---

## 11. Future Improvements

### Recommended Additions

1. **Golden Tests**: Visual regression testing for UI components
2. **Performance Tests**: Measure widget build times
3. **Accessibility Tests**: Ensure WCAG compliance
4. **E2E Tests**: Full user journey testing with Firebase emulators

### CI/CD Integration

```yaml
# Example GitHub Actions workflow
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
```

---

## 12. Common Testing Patterns

### Pattern 1: Widget Test Setup

```dart
Widget createTestWidget({required Widget child}) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}
```

### Pattern 2: Network Image Mocking

```dart
testWidgets('displays image', (tester) async {
  await mockNetworkImagesFor(() async {
    await tester.pumpWidget(createTestWidget());
    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });
});
```

### Pattern 3: Provider Testing

```dart
testWidgets('provider updates UI', (tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => TicketProvider.forTesting(
        firestoreService: MockFirestoreService(),
        storageService: MockStorageService(),
      ),
      child: const MyWidget(),
    ),
  );
  // ... assertions
});
```

---

## Summary

Phase 4 established a solid testing foundation for the FixIt Now application:

- ✅ **96 passing unit tests** covering models, validators, and provider logic
- ✅ **Widget tests** for core UI components
- ✅ **Test helpers** for consistent test data generation
- ✅ **Refactored code** for dependency injection and testability
- ✅ **Integration test scaffolding** ready for Firebase emulator testing
- ✅ **QA best practices** documented and implemented

The testing infrastructure ensures code quality, prevents regressions, and provides confidence for future development.

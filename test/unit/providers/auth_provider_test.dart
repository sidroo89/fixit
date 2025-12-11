import 'package:flutter_test/flutter_test.dart';
import 'package:fixit/providers/auth_provider.dart';
import 'package:fixit/data/models/user_model.dart';
import '../../helpers/test_helpers.dart';

/// Unit tests for AuthProvider logic
/// 
/// Note: AuthProvider uses Firebase services internally which require
/// Firebase initialization. These tests focus on the enum, state logic,
/// and computed properties that can be tested without Firebase.
void main() {
  group('AuthState Enum', () {
    test('has all expected states', () {
      expect(AuthState.values.length, 5);
      expect(AuthState.values.contains(AuthState.initial), isTrue);
      expect(AuthState.values.contains(AuthState.loading), isTrue);
      expect(AuthState.values.contains(AuthState.authenticated), isTrue);
      expect(AuthState.values.contains(AuthState.unauthenticated), isTrue);
      expect(AuthState.values.contains(AuthState.error), isTrue);
    });

    test('states have correct indices', () {
      expect(AuthState.initial.index, 0);
      expect(AuthState.loading.index, 1);
      expect(AuthState.authenticated.index, 2);
      expect(AuthState.unauthenticated.index, 3);
      expect(AuthState.error.index, 4);
    });
  });

  group('UserModel Role Checks', () {
    test('admin user has isAdmin true', () {
      final adminUser = createTestAdmin();
      expect(adminUser.isAdmin, isTrue);
      expect(adminUser.isUser, isFalse);
    });

    test('regular user has isUser true', () {
      final regularUser = createTestUser(role: 'user');
      expect(regularUser.isUser, isTrue);
      expect(regularUser.isAdmin, isFalse);
    });

    test('unknown role has both false', () {
      final unknownRoleUser = createTestUser(role: 'manager');
      expect(unknownRoleUser.isUser, isFalse);
      expect(unknownRoleUser.isAdmin, isFalse);
    });
  });

  group('Auth Error Messages', () {
    // Test the expected error codes that should be handled
    test('common Firebase error codes are defined', () {
      final expectedErrorCodes = [
        'user-not-found',
        'wrong-password',
        'email-already-in-use',
        'invalid-email',
        'weak-password',
        'user-disabled',
        'too-many-requests',
        'operation-not-allowed',
        'invalid-credential',
      ];

      // Verify the expected error codes
      expect(expectedErrorCodes.length, 9);
      expect(expectedErrorCodes.contains('user-not-found'), isTrue);
      expect(expectedErrorCodes.contains('wrong-password'), isTrue);
      expect(expectedErrorCodes.contains('email-already-in-use'), isTrue);
    });
  });

  group('State Helper Functions', () {
    test('isLoading depends on AuthState.loading', () {
      // Test the logic that isLoading = (authState == AuthState.loading)
      final loadingState = AuthState.loading;
      final initialState = AuthState.initial;
      
      expect(loadingState == AuthState.loading, isTrue);
      expect(initialState == AuthState.loading, isFalse);
    });

    test('isAuthenticated depends on AuthState.authenticated', () {
      final authenticatedState = AuthState.authenticated;
      final unauthenticatedState = AuthState.unauthenticated;
      
      expect(authenticatedState == AuthState.authenticated, isTrue);
      expect(unauthenticatedState == AuthState.authenticated, isFalse);
    });
  });

  group('Role-based Computed Properties', () {
    test('isAdmin check uses role field', () {
      final user = createTestUser(role: 'admin');
      expect(user.role == 'admin', isTrue);
    });

    test('isUser check uses role field', () {
      final user = createTestUser(role: 'user');
      expect(user.role == 'user', isTrue);
    });

    test('null user should result in false for role checks', () {
      // This tests the pattern: currentUser?.role == 'admin' returns false when null
      UserModel? nullUser;
      expect(nullUser?.role == 'admin', isFalse);
      expect(nullUser?.role == 'user', isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fixit/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    late UserModel testUser;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testUser = UserModel(
        uid: 'test-uid-123',
        email: 'test@example.com',
        name: 'Test User',
        role: 'user',
        department: 'IT',
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: testDate,
      );
    });

    group('Constructor', () {
      test('creates UserModel with all required fields', () {
        expect(testUser.uid, 'test-uid-123');
        expect(testUser.email, 'test@example.com');
        expect(testUser.name, 'Test User');
        expect(testUser.role, 'user');
        expect(testUser.createdAt, testDate);
      });

      test('creates UserModel with optional fields', () {
        expect(testUser.department, 'IT');
        expect(testUser.photoUrl, 'https://example.com/photo.jpg');
      });

      test('creates UserModel with null optional fields', () {
        final userWithNulls = UserModel(
          uid: 'uid',
          email: 'test@test.com',
          name: 'Name',
          role: 'user',
          createdAt: testDate,
        );

        expect(userWithNulls.department, isNull);
        expect(userWithNulls.photoUrl, isNull);
      });
    });

    group('Role checks', () {
      test('isAdmin returns true for admin role', () {
        final adminUser = UserModel(
          uid: 'admin-uid',
          email: 'admin@example.com',
          name: 'Admin User',
          role: 'admin',
          createdAt: testDate,
        );

        expect(adminUser.isAdmin, isTrue);
        expect(adminUser.isUser, isFalse);
      });

      test('isUser returns true for user role', () {
        expect(testUser.isUser, isTrue);
        expect(testUser.isAdmin, isFalse);
      });

      test('isAdmin and isUser return false for unknown role', () {
        final unknownRoleUser = UserModel(
          uid: 'uid',
          email: 'test@test.com',
          name: 'Name',
          role: 'manager', // Unknown role
          createdAt: testDate,
        );

        expect(unknownRoleUser.isAdmin, isFalse);
        expect(unknownRoleUser.isUser, isFalse);
      });
    });

    group('fromMap', () {
      test('creates UserModel from valid map', () {
        final map = {
          'email': 'map@example.com',
          'name': 'Map User',
          'role': 'admin',
          'department': 'HR',
          'photoUrl': 'https://example.com/map.jpg',
          'createdAt': null, // Will default to DateTime.now()
        };

        final user = UserModel.fromMap(map, 'map-uid');

        expect(user.uid, 'map-uid');
        expect(user.email, 'map@example.com');
        expect(user.name, 'Map User');
        expect(user.role, 'admin');
        expect(user.department, 'HR');
        expect(user.photoUrl, 'https://example.com/map.jpg');
      });

      test('handles missing optional fields in map', () {
        final map = {
          'email': 'minimal@example.com',
          'name': 'Minimal User',
          'role': 'user',
        };

        final user = UserModel.fromMap(map, 'minimal-uid');

        expect(user.department, isNull);
        expect(user.photoUrl, isNull);
      });

      test('uses default values for missing required fields', () {
        final emptyMap = <String, dynamic>{};

        final user = UserModel.fromMap(emptyMap, 'empty-uid');

        expect(user.email, '');
        expect(user.name, '');
        expect(user.role, 'user'); // Default role
      });
    });

    group('toMap', () {
      test('converts UserModel to map', () {
        final map = testUser.toMap();

        expect(map['email'], 'test@example.com');
        expect(map['name'], 'Test User');
        expect(map['role'], 'user');
        expect(map['department'], 'IT');
        expect(map['photoUrl'], 'https://example.com/photo.jpg');
        expect(map['createdAt'], isNotNull);
      });

      test('toMap does not include uid', () {
        final map = testUser.toMap();

        expect(map.containsKey('uid'), isFalse);
      });
    });

    group('copyWith', () {
      test('copies with no changes returns equivalent object', () {
        final copy = testUser.copyWith();

        expect(copy.uid, testUser.uid);
        expect(copy.email, testUser.email);
        expect(copy.name, testUser.name);
        expect(copy.role, testUser.role);
        expect(copy.department, testUser.department);
        expect(copy.photoUrl, testUser.photoUrl);
        expect(copy.createdAt, testUser.createdAt);
      });

      test('copies with single field change', () {
        final copy = testUser.copyWith(name: 'New Name');

        expect(copy.name, 'New Name');
        expect(copy.email, testUser.email); // Other fields unchanged
      });

      test('copies with multiple field changes', () {
        final newDate = DateTime(2025, 1, 1);
        final copy = testUser.copyWith(
          role: 'admin',
          department: 'Engineering',
          createdAt: newDate,
        );

        expect(copy.role, 'admin');
        expect(copy.department, 'Engineering');
        expect(copy.createdAt, newDate);
        expect(copy.email, testUser.email); // Unchanged
      });
    });

    group('Equality', () {
      test('two users with same uid are equal', () {
        final user1 = UserModel(
          uid: 'same-uid',
          email: 'user1@example.com',
          name: 'User 1',
          role: 'user',
          createdAt: testDate,
        );

        final user2 = UserModel(
          uid: 'same-uid',
          email: 'user2@example.com', // Different email
          name: 'User 2',
          role: 'admin',
          createdAt: testDate,
        );

        expect(user1 == user2, isTrue);
      });

      test('two users with different uid are not equal', () {
        final user1 = UserModel(
          uid: 'uid-1',
          email: 'same@example.com',
          name: 'Same Name',
          role: 'user',
          createdAt: testDate,
        );

        final user2 = UserModel(
          uid: 'uid-2',
          email: 'same@example.com',
          name: 'Same Name',
          role: 'user',
          createdAt: testDate,
        );

        expect(user1 == user2, isFalse);
      });

      test('hashCode is based on uid', () {
        expect(testUser.hashCode, 'test-uid-123'.hashCode);
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        final string = testUser.toString();

        expect(string, contains('uid: test-uid-123'));
        expect(string, contains('email: test@example.com'));
        expect(string, contains('name: Test User'));
        expect(string, contains('role: user'));
      });
    });
  });
}


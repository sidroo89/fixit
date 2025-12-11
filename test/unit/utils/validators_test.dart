import 'package:flutter_test/flutter_test.dart';
import 'package:fixit/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns error for null email', () {
        final result = Validators.validateEmail(null);
        expect(result, isNotNull);
      });

      test('returns error for empty email', () {
        final result = Validators.validateEmail('');
        expect(result, isNotNull);
      });

      test('returns error for invalid email formats', () {
        expect(Validators.validateEmail('notanemail'), isNotNull);
        expect(Validators.validateEmail('missing@domain'), isNotNull);
        expect(Validators.validateEmail('@nodomain.com'), isNotNull);
        expect(Validators.validateEmail('spaces in@email.com'), isNotNull);
        expect(Validators.validateEmail('no@dots'), isNotNull);
      });

      test('returns null for valid email formats', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
        expect(Validators.validateEmail('user.name@domain.org'), isNull);
        expect(Validators.validateEmail('user+tag@example.co.uk'), isNull);
        expect(Validators.validateEmail('user123@test.io'), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error for null password', () {
        final result = Validators.validatePassword(null);
        expect(result, isNotNull);
      });

      test('returns error for empty password', () {
        final result = Validators.validatePassword('');
        expect(result, isNotNull);
      });

      test('returns error for password shorter than 6 characters', () {
        expect(Validators.validatePassword('12345'), isNotNull);
        expect(Validators.validatePassword('abc'), isNotNull);
        expect(Validators.validatePassword('a'), isNotNull);
      });

      test('returns null for valid password (6+ characters)', () {
        expect(Validators.validatePassword('123456'), isNull);
        expect(Validators.validatePassword('password123'), isNull);
        expect(Validators.validatePassword('SecureP@ss!'), isNull);
      });
    });

    group('validateConfirmPassword', () {
      const password = 'testPassword123';

      test('returns error for null confirm password', () {
        final result = Validators.validateConfirmPassword(null, password);
        expect(result, isNotNull);
      });

      test('returns error for empty confirm password', () {
        final result = Validators.validateConfirmPassword('', password);
        expect(result, isNotNull);
      });

      test('returns error when passwords do not match', () {
        final result = Validators.validateConfirmPassword('differentPassword', password);
        expect(result, isNotNull);
      });

      test('returns null when passwords match', () {
        final result = Validators.validateConfirmPassword(password, password);
        expect(result, isNull);
      });
    });

    group('validateName', () {
      test('returns error for null name', () {
        final result = Validators.validateName(null);
        expect(result, isNotNull);
      });

      test('returns error for empty name', () {
        final result = Validators.validateName('');
        expect(result, isNotNull);
      });

      test('returns error for name shorter than 2 characters', () {
        expect(Validators.validateName('A'), isNotNull);
      });

      test('returns null for valid name (2+ characters)', () {
        expect(Validators.validateName('Jo'), isNull);
        expect(Validators.validateName('John'), isNull);
        expect(Validators.validateName('John Doe'), isNull);
      });
    });

    group('validateRequired', () {
      test('returns error for null value', () {
        final result = Validators.validateRequired(null);
        expect(result, isNotNull);
      });

      test('returns error for empty value', () {
        final result = Validators.validateRequired('');
        expect(result, isNotNull);
      });

      test('returns null for any non-empty value', () {
        expect(Validators.validateRequired('a'), isNull);
        expect(Validators.validateRequired('some value'), isNull);
        expect(Validators.validateRequired('   '), isNull); // whitespace counts
      });
    });

    group('validateTitle', () {
      test('returns error for null title', () {
        final result = Validators.validateTitle(null);
        expect(result, isNotNull);
      });

      test('returns error for empty title', () {
        final result = Validators.validateTitle('');
        expect(result, isNotNull);
      });

      test('returns error for title shorter than 5 characters', () {
        expect(Validators.validateTitle('Test'), isNotNull);
        expect(Validators.validateTitle('AB'), isNotNull);
      });

      test('returns error for title longer than 100 characters', () {
        final longTitle = 'A' * 101;
        final result = Validators.validateTitle(longTitle);
        expect(result, isNotNull);
      });

      test('returns null for valid title (5-100 characters)', () {
        expect(Validators.validateTitle('Valid Title'), isNull);
        expect(Validators.validateTitle('12345'), isNull);
        expect(Validators.validateTitle('A' * 100), isNull);
      });
    });

    group('validateDescription', () {
      test('returns error for null description', () {
        final result = Validators.validateDescription(null);
        expect(result, isNotNull);
      });

      test('returns error for empty description', () {
        final result = Validators.validateDescription('');
        expect(result, isNotNull);
      });

      test('returns error for description shorter than 10 characters', () {
        expect(Validators.validateDescription('Short'), isNotNull);
        expect(Validators.validateDescription('123456789'), isNotNull);
      });

      test('returns error for description longer than 500 characters', () {
        final longDescription = 'A' * 501;
        final result = Validators.validateDescription(longDescription);
        expect(result, isNotNull);
      });

      test('returns null for valid description (10-500 characters)', () {
        expect(Validators.validateDescription('Valid description here'), isNull);
        expect(Validators.validateDescription('1234567890'), isNull);
        expect(Validators.validateDescription('A' * 500), isNull);
      });
    });
  });
}


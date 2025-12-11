import 'package:flutter_test/flutter_test.dart';
import 'package:fixit/data/models/ticket_model.dart';

void main() {
  group('TicketCategory Enum', () {
    test('fromString returns correct category for valid input', () {
      expect(TicketCategory.fromString('IT'), TicketCategory.it);
      expect(TicketCategory.fromString('Electrical'), TicketCategory.electrical);
      expect(TicketCategory.fromString('Plumbing'), TicketCategory.plumbing);
      expect(TicketCategory.fromString('HVAC'), TicketCategory.hvac);
      expect(TicketCategory.fromString('Furniture'), TicketCategory.furniture);
      expect(TicketCategory.fromString('Other'), TicketCategory.other);
    });

    test('fromString is case insensitive', () {
      expect(TicketCategory.fromString('it'), TicketCategory.it);
      expect(TicketCategory.fromString('IT'), TicketCategory.it);
      expect(TicketCategory.fromString('It'), TicketCategory.it);
    });

    test('fromString returns other for unknown category', () {
      expect(TicketCategory.fromString('Unknown'), TicketCategory.other);
      expect(TicketCategory.fromString(''), TicketCategory.other);
      expect(TicketCategory.fromString('RandomText'), TicketCategory.other);
    });

    test('displayName returns correct string', () {
      expect(TicketCategory.it.displayName, 'IT');
      expect(TicketCategory.electrical.displayName, 'Electrical');
      expect(TicketCategory.plumbing.displayName, 'Plumbing');
      expect(TicketCategory.hvac.displayName, 'HVAC');
      expect(TicketCategory.furniture.displayName, 'Furniture');
      expect(TicketCategory.other.displayName, 'Other');
    });
  });

  group('TicketPriority Enum', () {
    test('fromString returns correct priority for valid input', () {
      expect(TicketPriority.fromString('Low'), TicketPriority.low);
      expect(TicketPriority.fromString('Medium'), TicketPriority.medium);
      expect(TicketPriority.fromString('High'), TicketPriority.high);
    });

    test('fromString is case insensitive', () {
      expect(TicketPriority.fromString('low'), TicketPriority.low);
      expect(TicketPriority.fromString('LOW'), TicketPriority.low);
      expect(TicketPriority.fromString('High'), TicketPriority.high);
    });

    test('fromString returns medium for unknown priority', () {
      expect(TicketPriority.fromString('Unknown'), TicketPriority.medium);
      expect(TicketPriority.fromString(''), TicketPriority.medium);
      expect(TicketPriority.fromString('Critical'), TicketPriority.medium);
    });

    test('displayName returns correct string', () {
      expect(TicketPriority.low.displayName, 'Low');
      expect(TicketPriority.medium.displayName, 'Medium');
      expect(TicketPriority.high.displayName, 'High');
    });
  });

  group('TicketStatus Enum', () {
    test('fromString returns correct status for valid input', () {
      expect(TicketStatus.fromString('Open'), TicketStatus.open);
      expect(TicketStatus.fromString('In Progress'), TicketStatus.inProgress);
      expect(TicketStatus.fromString('Resolved'), TicketStatus.resolved);
    });

    test('fromString is case insensitive', () {
      expect(TicketStatus.fromString('open'), TicketStatus.open);
      expect(TicketStatus.fromString('OPEN'), TicketStatus.open);
      expect(TicketStatus.fromString('in progress'), TicketStatus.inProgress);
    });

    test('fromString returns open for unknown status', () {
      expect(TicketStatus.fromString('Unknown'), TicketStatus.open);
      expect(TicketStatus.fromString(''), TicketStatus.open);
      expect(TicketStatus.fromString('Closed'), TicketStatus.open);
    });

    test('displayName returns correct string', () {
      expect(TicketStatus.open.displayName, 'Open');
      expect(TicketStatus.inProgress.displayName, 'In Progress');
      expect(TicketStatus.resolved.displayName, 'Resolved');
    });
  });

  group('TicketModel', () {
    late TicketModel testTicket;
    late DateTime testDate;
    late DateTime updateDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      updateDate = DateTime(2024, 1, 16, 14, 0);
      testTicket = TicketModel(
        id: 'ticket-123',
        title: 'WiFi not working',
        description: 'The WiFi in conference room 3 is not working',
        imageUrl: 'https://example.com/image.jpg',
        category: TicketCategory.it,
        priority: TicketPriority.high,
        status: TicketStatus.open,
        createdByUid: 'user-uid-456',
        createdByName: 'John Doe',
        createdAt: testDate,
        updatedAt: updateDate,
        resolvedAt: null,
      );
    });

    group('Constructor', () {
      test('creates TicketModel with all required fields', () {
        expect(testTicket.id, 'ticket-123');
        expect(testTicket.title, 'WiFi not working');
        expect(testTicket.description, 'The WiFi in conference room 3 is not working');
        expect(testTicket.category, TicketCategory.it);
        expect(testTicket.priority, TicketPriority.high);
        expect(testTicket.status, TicketStatus.open);
        expect(testTicket.createdByUid, 'user-uid-456');
        expect(testTicket.createdByName, 'John Doe');
        expect(testTicket.createdAt, testDate);
        expect(testTicket.updatedAt, updateDate);
      });

      test('creates TicketModel with optional imageUrl', () {
        expect(testTicket.imageUrl, 'https://example.com/image.jpg');
      });

      test('creates TicketModel with null imageUrl', () {
        final ticketNoImage = TicketModel(
          id: 'id',
          title: 'title',
          description: 'description',
          category: TicketCategory.other,
          priority: TicketPriority.low,
          status: TicketStatus.open,
          createdByUid: 'uid',
          createdByName: 'name',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(ticketNoImage.imageUrl, isNull);
      });

      test('creates TicketModel with resolvedAt', () {
        final resolvedDate = DateTime(2024, 1, 20);
        final resolvedTicket = testTicket.copyWith(
          status: TicketStatus.resolved,
          resolvedAt: resolvedDate,
        );

        expect(resolvedTicket.resolvedAt, resolvedDate);
      });
    });

    group('toMap', () {
      test('converts TicketModel to map', () {
        final map = testTicket.toMap();

        expect(map['title'], 'WiFi not working');
        expect(map['description'], 'The WiFi in conference room 3 is not working');
        expect(map['imageUrl'], 'https://example.com/image.jpg');
        expect(map['category'], 'IT');
        expect(map['priority'], 'High');
        expect(map['status'], 'Open');
        expect(map['createdByUid'], 'user-uid-456');
        expect(map['createdByName'], 'John Doe');
        expect(map['createdAt'], isNotNull);
        expect(map['updatedAt'], isNotNull);
      });

      test('toMap does not include id', () {
        final map = testTicket.toMap();

        expect(map.containsKey('id'), isFalse);
      });

      test('toMap handles null resolvedAt', () {
        final map = testTicket.toMap();

        expect(map['resolvedAt'], isNull);
      });

      test('toMap includes resolvedAt when present', () {
        final resolvedTicket = testTicket.copyWith(
          resolvedAt: DateTime(2024, 1, 20),
        );
        final map = resolvedTicket.toMap();

        expect(map['resolvedAt'], isNotNull);
      });
    });

    group('copyWith', () {
      test('copies with no changes returns equivalent object', () {
        final copy = testTicket.copyWith();

        expect(copy.id, testTicket.id);
        expect(copy.title, testTicket.title);
        expect(copy.description, testTicket.description);
        expect(copy.imageUrl, testTicket.imageUrl);
        expect(copy.category, testTicket.category);
        expect(copy.priority, testTicket.priority);
        expect(copy.status, testTicket.status);
        expect(copy.createdByUid, testTicket.createdByUid);
        expect(copy.createdByName, testTicket.createdByName);
        expect(copy.createdAt, testTicket.createdAt);
        expect(copy.updatedAt, testTicket.updatedAt);
      });

      test('copies with single field change', () {
        final copy = testTicket.copyWith(status: TicketStatus.resolved);

        expect(copy.status, TicketStatus.resolved);
        expect(copy.title, testTicket.title); // Other fields unchanged
      });

      test('copies with multiple field changes', () {
        final copy = testTicket.copyWith(
          status: TicketStatus.inProgress,
          priority: TicketPriority.low,
          updatedAt: DateTime(2024, 2, 1),
        );

        expect(copy.status, TicketStatus.inProgress);
        expect(copy.priority, TicketPriority.low);
        expect(copy.updatedAt, DateTime(2024, 2, 1));
      });
    });

    group('Equality', () {
      test('two tickets with same id are equal', () {
        final ticket1 = TicketModel(
          id: 'same-id',
          title: 'Title 1',
          description: 'Desc 1',
          category: TicketCategory.it,
          priority: TicketPriority.low,
          status: TicketStatus.open,
          createdByUid: 'uid1',
          createdByName: 'Name 1',
          createdAt: testDate,
          updatedAt: testDate,
        );

        final ticket2 = TicketModel(
          id: 'same-id',
          title: 'Title 2', // Different title
          description: 'Desc 2',
          category: TicketCategory.electrical,
          priority: TicketPriority.high,
          status: TicketStatus.resolved,
          createdByUid: 'uid2',
          createdByName: 'Name 2',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(ticket1 == ticket2, isTrue);
      });

      test('two tickets with different id are not equal', () {
        final ticket1 = testTicket;
        final ticket2 = testTicket.copyWith(id: 'different-id');

        expect(ticket1 == ticket2, isFalse);
      });

      test('hashCode is based on id', () {
        expect(testTicket.hashCode, 'ticket-123'.hashCode);
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        final string = testTicket.toString();

        expect(string, contains('id: ticket-123'));
        expect(string, contains('title: WiFi not working'));
        expect(string, contains('status: Open'));
      });
    });
  });
}


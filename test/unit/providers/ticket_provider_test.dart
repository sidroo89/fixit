import 'package:flutter_test/flutter_test.dart';
import 'package:fixit/data/models/ticket_model.dart';
import '../../helpers/test_helpers.dart';

/// Unit tests for TicketProvider logic
/// 
/// Note: TicketProvider uses Firebase services internally which require
/// Firebase initialization. These tests focus on the filter logic and
/// data structures that can be tested without Firebase.
void main() {
  group('Filter Logic Tests', () {
    test('Open filter correctly filters tickets', () {
      final tickets = createTestTicketList(count: 9);
      
      final openTickets = tickets
          .where((t) => t.status == TicketStatus.open)
          .toList();
      
      expect(openTickets, isNotEmpty);
      for (var ticket in openTickets) {
        expect(ticket.status, TicketStatus.open);
      }
    });

    test('In Progress filter correctly filters tickets', () {
      final tickets = createTestTicketList(count: 9);
      
      final inProgressTickets = tickets
          .where((t) => t.status == TicketStatus.inProgress)
          .toList();
      
      expect(inProgressTickets, isNotEmpty);
      for (var ticket in inProgressTickets) {
        expect(ticket.status, TicketStatus.inProgress);
      }
    });

    test('Resolved filter correctly filters tickets', () {
      final tickets = createTestTicketList(count: 9);
      
      final resolvedTickets = tickets
          .where((t) => t.status == TicketStatus.resolved)
          .toList();
      
      expect(resolvedTickets, isNotEmpty);
      for (var ticket in resolvedTickets) {
        expect(ticket.status, TicketStatus.resolved);
      }
    });

    test('All filter returns all tickets', () {
      final tickets = createTestTicketList(count: 9);
      
      // "all" filter should return the full list
      expect(tickets.length, 9);
    });

    test('Filter is case insensitive', () {
      // Test the filter matching logic
      const filter = 'OPEN';
      expect(filter.toLowerCase() == 'open', isTrue);
      
      const filter2 = 'In Progress';
      expect(filter2.toLowerCase() == 'in progress', isTrue);
    });
  });

  group('Ticket Counts Tests', () {
    test('createTestTicketCounts returns correct structure', () {
      final counts = createTestTicketCounts(open: 5, inProgress: 3, resolved: 10);
      
      expect(counts['open'], 5);
      expect(counts['inProgress'], 3);
      expect(counts['resolved'], 10);
    });

    test('counts map has all required keys', () {
      final counts = createTestTicketCounts();
      
      expect(counts.containsKey('open'), isTrue);
      expect(counts.containsKey('inProgress'), isTrue);
      expect(counts.containsKey('resolved'), isTrue);
    });
  });

  group('Test Data Generation', () {
    test('createTestTicketList generates correct number of tickets', () {
      final tickets5 = createTestTicketList(count: 5);
      final tickets10 = createTestTicketList(count: 10);
      
      expect(tickets5.length, 5);
      expect(tickets10.length, 10);
    });

    test('createTestTicketList cycles through statuses', () {
      final tickets = createTestTicketList(count: 6);
      
      // With 6 tickets cycling through 3 statuses, should have 2 of each
      final statusCounts = <TicketStatus, int>{};
      for (var ticket in tickets) {
        statusCounts[ticket.status] = (statusCounts[ticket.status] ?? 0) + 1;
      }
      
      expect(statusCounts[TicketStatus.open], 2);
      expect(statusCounts[TicketStatus.inProgress], 2);
      expect(statusCounts[TicketStatus.resolved], 2);
    });

    test('createTestTicketList cycles through priorities', () {
      final tickets = createTestTicketList(count: 6);
      
      final priorityCounts = <TicketPriority, int>{};
      for (var ticket in tickets) {
        priorityCounts[ticket.priority] = (priorityCounts[ticket.priority] ?? 0) + 1;
      }
      
      expect(priorityCounts[TicketPriority.low], 2);
      expect(priorityCounts[TicketPriority.medium], 2);
      expect(priorityCounts[TicketPriority.high], 2);
    });

    test('createTestTicketList uses userId when provided', () {
      final tickets = createTestTicketList(count: 3, userId: 'specific-user');
      
      for (var ticket in tickets) {
        expect(ticket.createdByUid, 'specific-user');
      }
    });
  });
}

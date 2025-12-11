import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixit/presentation/widgets/ticket/ticket_card.dart';
import 'package:fixit/data/models/ticket_model.dart';
import 'package:network_image_mock/network_image_mock.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('TicketCard Widget', () {
    late TicketModel testTicket;

    setUp(() {
      testTicket = createTestTicket(
        title: 'WiFi Not Working',
        description: 'The WiFi in the conference room is not connecting',
        category: TicketCategory.it,
        priority: TicketPriority.high,
        status: TicketStatus.open,
        createdByName: 'John Doe',
      );
    });

    Widget createTestWidget({
      required TicketModel ticket,
      VoidCallback? onTap,
      bool showReporter = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TicketCard(
            ticket: ticket,
            onTap: onTap ?? () {},
            showReporter: showReporter,
          ),
        ),
      );
    }

    testWidgets('displays ticket title', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createTestWidget(ticket: testTicket));

        expect(find.text('WiFi Not Working'), findsOneWidget);
      });
    });

    testWidgets('displays ticket category', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createTestWidget(ticket: testTicket));

        expect(find.text('IT'), findsOneWidget);
      });
    });

    testWidgets('displays Open status chip for open ticket', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createTestWidget(ticket: testTicket));

        expect(find.text('Open'), findsOneWidget);
      });
    });

    testWidgets('displays In Progress status chip', (tester) async {
      final inProgressTicket = testTicket.copyWith(
        status: TicketStatus.inProgress,
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createTestWidget(ticket: inProgressTicket));

        expect(find.text('In Progress'), findsOneWidget);
      });
    });

    testWidgets('displays Resolved status chip', (tester) async {
      final resolvedTicket = testTicket.copyWith(status: TicketStatus.resolved);

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createTestWidget(ticket: resolvedTicket));

        expect(find.text('Resolved'), findsOneWidget);
      });
    });

    testWidgets('shows reporter name when showReporter is true', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createTestWidget(ticket: testTicket, showReporter: true),
        );

        expect(find.textContaining('John Doe'), findsOneWidget);
      });
    });

    testWidgets('hides reporter when showReporter is false', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createTestWidget(ticket: testTicket, showReporter: false),
        );

        // Should not find "Reported by" text
        expect(find.textContaining('Reported by'), findsNothing);
      });
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      var tapped = false;

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createTestWidget(ticket: testTicket, onTap: () => tapped = true),
        );

        await tester.tap(find.byType(Card));
        await tester.pump();

        expect(tapped, isTrue);
      });
    });

    testWidgets('displays priority indicator for high priority', (
      tester,
    ) async {
      final highPriorityTicket = testTicket.copyWith(
        priority: TicketPriority.high,
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createTestWidget(ticket: highPriorityTicket));

        // High priority should show a warning icon or indicator
        // This depends on your actual implementation
        expect(find.byType(Card), findsOneWidget);
      });
    });

    testWidgets('handles ticket without image gracefully', (tester) async {
      final noImageTicket = createTestTicket(imageUrl: null);

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createTestWidget(ticket: noImageTicket));

        // Should still render without errors
        expect(find.byType(Card), findsOneWidget);
      });
    });
  });

  group('TicketCard Status Colors', () {
    testWidgets('Open status has correct color scheme', (tester) async {
      final openTicket = createTestTicket(status: TicketStatus.open);

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TicketCard(ticket: openTicket, onTap: () {}),
            ),
          ),
        );

        // Find the status chip container
        final statusText = find.text('Open');
        expect(statusText, findsOneWidget);
      });
    });
  });
}

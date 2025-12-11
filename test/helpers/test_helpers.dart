// Test helpers and utilities
import 'package:fixit/data/models/user_model.dart';
import 'package:fixit/data/models/ticket_model.dart';

/// Creates a test UserModel with default or custom values
UserModel createTestUser({
  String uid = 'test-uid',
  String email = 'test@example.com',
  String name = 'Test User',
  String role = 'user',
  String? department,
  String? photoUrl,
  DateTime? createdAt,
}) {
  return UserModel(
    uid: uid,
    email: email,
    name: name,
    role: role,
    department: department,
    photoUrl: photoUrl,
    createdAt: createdAt ?? DateTime(2024, 1, 1),
  );
}

/// Creates a test admin UserModel
UserModel createTestAdmin({
  String uid = 'admin-uid',
  String email = 'admin@example.com',
  String name = 'Admin User',
}) {
  return createTestUser(
    uid: uid,
    email: email,
    name: name,
    role: 'admin',
  );
}

/// Creates a test TicketModel with default or custom values
TicketModel createTestTicket({
  String id = 'ticket-id',
  String title = 'Test Ticket',
  String description = 'This is a test ticket description',
  String? imageUrl,
  TicketCategory category = TicketCategory.it,
  TicketPriority priority = TicketPriority.medium,
  TicketStatus status = TicketStatus.open,
  String createdByUid = 'user-uid',
  String createdByName = 'Test User',
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? resolvedAt,
}) {
  final now = DateTime.now();
  return TicketModel(
    id: id,
    title: title,
    description: description,
    imageUrl: imageUrl,
    category: category,
    priority: priority,
    status: status,
    createdByUid: createdByUid,
    createdByName: createdByName,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
    resolvedAt: resolvedAt,
  );
}

/// Creates a list of test tickets for testing list views
List<TicketModel> createTestTicketList({int count = 5, String? userId}) {
  return List.generate(count, (index) {
    final statuses = [TicketStatus.open, TicketStatus.inProgress, TicketStatus.resolved];
    final priorities = [TicketPriority.low, TicketPriority.medium, TicketPriority.high];
    final categories = TicketCategory.values;
    
    return createTestTicket(
      id: 'ticket-$index',
      title: 'Test Ticket ${index + 1}',
      description: 'Description for ticket ${index + 1}',
      status: statuses[index % statuses.length],
      priority: priorities[index % priorities.length],
      category: categories[index % categories.length],
      createdByUid: userId ?? 'user-$index',
      createdByName: 'User ${index + 1}',
      createdAt: DateTime(2024, 1, 1).add(Duration(days: index)),
    );
  });
}

/// Creates mock ticket counts map
Map<String, int> createTestTicketCounts({
  int open = 5,
  int inProgress = 3,
  int resolved = 10,
}) {
  return {
    'open': open,
    'inProgress': inProgress,
    'resolved': resolved,
  };
}


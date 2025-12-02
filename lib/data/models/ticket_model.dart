import 'package:cloud_firestore/cloud_firestore.dart';

enum TicketCategory {
  it('IT'),
  electrical('Electrical'),
  plumbing('Plumbing'),
  hvac('HVAC'),
  furniture('Furniture'),
  other('Other');

  final String displayName;
  const TicketCategory(this.displayName);

  static TicketCategory fromString(String value) {
    return TicketCategory.values.firstWhere(
      (e) => e.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => TicketCategory.other,
    );
  }
}

enum TicketPriority {
  low('Low'),
  medium('Medium'),
  high('High');

  final String displayName;
  const TicketPriority(this.displayName);

  static TicketPriority fromString(String value) {
    return TicketPriority.values.firstWhere(
      (e) => e.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => TicketPriority.medium,
    );
  }
}

enum TicketStatus {
  open('Open'),
  inProgress('In Progress'),
  resolved('Resolved');

  final String displayName;
  const TicketStatus(this.displayName);

  static TicketStatus fromString(String value) {
    return TicketStatus.values.firstWhere(
      (e) => e.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => TicketStatus.open,
    );
  }
}

class TicketModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;
  final String createdByUid;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdByUid,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  // Factory constructor from Firestore document
  factory TicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      category: TicketCategory.fromString(data['category'] ?? 'Other'),
      priority: TicketPriority.fromString(data['priority'] ?? 'Medium'),
      status: TicketStatus.fromString(data['status'] ?? 'Open'),
      createdByUid: data['createdByUid'] ?? '',
      createdByName: data['createdByName'] ?? 'Unknown',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category.displayName,
      'priority': priority.displayName,
      'status': status.displayName,
      'createdByUid': createdByUid,
      'createdByName': createdByName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  // Copy with method for updating ticket data
  TicketModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    TicketCategory? category,
    TicketPriority? priority,
    TicketStatus? status,
    String? createdByUid,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdByUid: createdByUid ?? this.createdByUid,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  String toString() {
    return 'TicketModel(id: $id, title: $title, status: ${status.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicketModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}


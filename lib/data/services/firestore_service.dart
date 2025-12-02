import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _ticketsCollection =>
      _firestore.collection('tickets');

  // ==================== USER OPERATIONS ====================

  // Get user by ID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Stream user data
  Stream<UserModel?> streamUser(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // ==================== TICKET OPERATIONS ====================

  // Create a new ticket
  Future<String> createTicket(TicketModel ticket) async {
    final docRef = await _ticketsCollection.add(ticket.toMap());
    return docRef.id;
  }

  // Get ticket by ID
  Future<TicketModel?> getTicket(String ticketId) async {
    try {
      final doc = await _ticketsCollection.doc(ticketId).get();
      if (doc.exists) {
        return TicketModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Stream single ticket
  Stream<TicketModel?> streamTicket(String ticketId) {
    return _ticketsCollection.doc(ticketId).snapshots().map((doc) {
      if (doc.exists) {
        return TicketModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Get all tickets (for admin)
  Stream<List<TicketModel>> streamAllTickets() {
    return _ticketsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TicketModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get tickets by user ID
  Stream<List<TicketModel>> streamUserTickets(String userId) {
    return _ticketsCollection
        .where('createdByUid', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TicketModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get tickets by status
  Stream<List<TicketModel>> streamTicketsByStatus(String status) {
    return _ticketsCollection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TicketModel.fromFirestore(doc))
          .toList();
    });
  }

  // Update ticket status
  Future<void> updateTicketStatus(String ticketId, TicketStatus newStatus) async {
    final updates = <String, dynamic>{
      'status': newStatus.displayName,
      'updatedAt': Timestamp.now(),
    };

    // If resolved, add resolvedAt timestamp
    if (newStatus == TicketStatus.resolved) {
      updates['resolvedAt'] = Timestamp.now();
    }

    await _ticketsCollection.doc(ticketId).update(updates);
  }

  // Update ticket
  Future<void> updateTicket(String ticketId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = Timestamp.now();
    await _ticketsCollection.doc(ticketId).update(updates);
  }

  // Delete ticket
  Future<void> deleteTicket(String ticketId) async {
    await _ticketsCollection.doc(ticketId).delete();
  }

  // ==================== STATISTICS ====================

  // Get ticket counts by status
  Future<Map<String, int>> getTicketCounts() async {
    final counts = <String, int>{
      'open': 0,
      'inProgress': 0,
      'resolved': 0,
    };

    try {
      final snapshot = await _ticketsCollection.get();
      for (final doc in snapshot.docs) {
        final status = doc.data()['status'] as String? ?? 'Open';
        switch (status.toLowerCase()) {
          case 'open':
            counts['open'] = (counts['open'] ?? 0) + 1;
            break;
          case 'in progress':
            counts['inProgress'] = (counts['inProgress'] ?? 0) + 1;
            break;
          case 'resolved':
            counts['resolved'] = (counts['resolved'] ?? 0) + 1;
            break;
        }
      }
    } catch (e) {
      // Return default counts on error
    }

    return counts;
  }

  // Stream ticket counts (real-time updates)
  Stream<Map<String, int>> streamTicketCounts() {
    return _ticketsCollection.snapshots().map((snapshot) {
      final counts = <String, int>{
        'open': 0,
        'inProgress': 0,
        'resolved': 0,
      };

      for (final doc in snapshot.docs) {
        final status = doc.data()['status'] as String? ?? 'Open';
        switch (status.toLowerCase()) {
          case 'open':
            counts['open'] = (counts['open'] ?? 0) + 1;
            break;
          case 'in progress':
            counts['inProgress'] = (counts['inProgress'] ?? 0) + 1;
            break;
          case 'resolved':
            counts['resolved'] = (counts['resolved'] ?? 0) + 1;
            break;
        }
      }

      return counts;
    });
  }
}


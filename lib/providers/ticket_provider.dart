import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../data/models/ticket_model.dart';
import '../data/services/firestore_service.dart';
import '../data/services/storage_service.dart';

class TicketProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  List<TicketModel> _tickets = [];
  List<TicketModel> _filteredTickets = [];
  Map<String, int> _ticketCounts = {'open': 0, 'inProgress': 0, 'resolved': 0};
  bool _isLoading = false;
  String? _errorMessage;
  String _currentFilter = 'all';
  StreamSubscription? _ticketsSubscription;
  StreamSubscription? _countsSubscription;

  // Getters
  List<TicketModel> get tickets => _filteredTickets;
  List<TicketModel> get allTickets => _tickets;
  Map<String, int> get ticketCounts => _ticketCounts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;

  int get openCount => _ticketCounts['open'] ?? 0;
  int get inProgressCount => _ticketCounts['inProgress'] ?? 0;
  int get resolvedCount => _ticketCounts['resolved'] ?? 0;
  int get totalCount => _tickets.length;

  // Initialize streams for user (only their tickets)
  void initUserTickets(String userId) {
    _isLoading = true;
    notifyListeners();

    _ticketsSubscription?.cancel();
    _ticketsSubscription = _firestoreService.streamUserTickets(userId).listen(
      (tickets) {
        _tickets = tickets;
        _applyFilter();
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error loading tickets: $error');
        _errorMessage = 'Failed to load tickets. Check Firestore indexes.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Initialize streams for admin (all tickets)
  void initAdminTickets() {
    _isLoading = true;
    notifyListeners();

    _ticketsSubscription?.cancel();
    _ticketsSubscription = _firestoreService.streamAllTickets().listen(
      (tickets) {
        _tickets = tickets;
        _applyFilter();
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load tickets';
        _isLoading = false;
        notifyListeners();
      },
    );

    // Stream ticket counts for dashboard
    _countsSubscription?.cancel();
    _countsSubscription = _firestoreService.streamTicketCounts().listen(
      (counts) {
        _ticketCounts = counts;
        notifyListeners();
      },
    );
  }

  // Apply filter to tickets
  void setFilter(String filter) {
    _currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    switch (_currentFilter.toLowerCase()) {
      case 'open':
        _filteredTickets = _tickets
            .where((t) => t.status == TicketStatus.open)
            .toList();
        break;
      case 'in progress':
        _filteredTickets = _tickets
            .where((t) => t.status == TicketStatus.inProgress)
            .toList();
        break;
      case 'resolved':
        _filteredTickets = _tickets
            .where((t) => t.status == TicketStatus.resolved)
            .toList();
        break;
      default:
        _filteredTickets = List.from(_tickets);
    }
  }

  // Create a new ticket
  Future<bool> createTicket({
    required String title,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
    required String createdByUid,
    required String createdByName,
    File? imageFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? imageUrl;
      
      // Generate a temporary ID for the image path
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _storageService.uploadTicketImage(
          imageFile: imageFile,
          ticketId: tempId,
        );
      }

      // Create ticket model
      final ticket = TicketModel(
        id: '', // Will be set by Firestore
        title: title,
        description: description,
        imageUrl: imageUrl,
        category: category,
        priority: priority,
        status: TicketStatus.open,
        createdByUid: createdByUid,
        createdByName: createdByName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestoreService.createTicket(ticket);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create ticket';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update ticket status (admin only)
  Future<bool> updateTicketStatus(String ticketId, TicketStatus newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateTicketStatus(ticketId, newStatus);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update ticket status';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get single ticket by ID
  Future<TicketModel?> getTicket(String ticketId) async {
    return await _firestoreService.getTicket(ticketId);
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Dispose subscriptions
  @override
  void dispose() {
    _ticketsSubscription?.cancel();
    _countsSubscription?.cancel();
    super.dispose();
  }
}


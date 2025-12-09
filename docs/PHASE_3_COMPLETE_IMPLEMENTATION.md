# Phase 3-5: Complete Application Implementation

## 📋 Overview

This document covers the complete implementation of the FixIt Now application, including:
- Ticket state management with Provider
- Real-time data streams from Firestore
- Image upload functionality
- Complete UI screens for both User and Admin flows
- Reusable widget components

---

## 📁 New Files Structure

```
lib/
├── data/services/
│   └── storage_service.dart          # Firebase Storage operations
├── providers/
│   └── ticket_provider.dart          # Ticket state management
├── presentation/
│   ├── screens/
│   │   ├── user/
│   │   │   ├── user_home_screen.dart      # Updated with real data
│   │   │   └── create_ticket_screen.dart  # New ticket form
│   │   ├── admin/
│   │   │   └── admin_dashboard_screen.dart # Updated with stats
│   │   └── shared/
│   │       ├── ticket_details_screen.dart  # View/Edit ticket
│   │       ├── profile_screen.dart         # User settings
│   │       └── notifications_screen.dart   # Notifications list
│   └── widgets/
│       └── ticket/
│           └── ticket_card.dart            # Reusable card
```

---

## 🎛 State Management: TicketProvider

**File: `lib/providers/ticket_provider.dart`**

The TicketProvider manages all ticket-related state using the Provider pattern with Firestore streams.

### Core State Variables

```dart:1:30:lib/providers/ticket_provider.dart
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
```

**Key Points:**
- **Lines 12-18**: State variables for tickets, counts, loading state, and stream subscriptions
- **Lines 22-30**: Getters expose state to UI while keeping internal state private
- **StreamSubscription**: Used to manage Firestore real-time listeners

### Initializing User Tickets Stream

```dart:33:50:lib/providers/ticket_provider.dart
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
        _errorMessage = 'Failed to load tickets';
        _isLoading = false;
        notifyListeners();
      },
    );
  }
```

**Flow:**
1. Set loading state and notify listeners
2. Cancel any existing subscription (prevents memory leaks)
3. Subscribe to Firestore stream filtered by user ID
4. On data received: update tickets, apply filter, notify UI
5. On error: set error message, stop loading

### Initializing Admin Tickets Stream

```dart:52:78:lib/providers/ticket_provider.dart
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
```

**Admin-Specific Features:**
- **Line 58**: Streams ALL tickets (not filtered by user)
- **Lines 73-78**: Additional stream for real-time ticket counts (Open/In Progress/Resolved)

### Filter Implementation

```dart:80:99:lib/providers/ticket_provider.dart
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
```

**How Filtering Works:**
1. User selects filter (All/Open/In Progress/Resolved)
2. `setFilter()` updates current filter and calls `_applyFilter()`
3. `_applyFilter()` creates filtered list based on ticket status
4. UI rebuilds showing only matching tickets

### Creating a New Ticket

```dart:101:149:lib/providers/ticket_provider.dart
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
```

**Ticket Creation Flow:**
1. **Lines 111-113**: Set loading state
2. **Lines 117-126**: Upload image to Firebase Storage (if provided)
3. **Lines 129-143**: Create TicketModel with all data
4. **Line 146**: Save to Firestore
5. **Line 150**: Return success/failure to UI

---

## 📷 Storage Service: Image Uploads

**File: `lib/data/services/storage_service.dart`**

Handles all Firebase Storage operations for image uploads.

### Image Picker Methods

```dart:1:44:lib/data/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
```

**Image Optimization:**
- **maxWidth/maxHeight: 1024**: Limits image dimensions
- **imageQuality: 85**: Compresses to 85% quality
- This reduces upload size while maintaining visual quality

### Upload to Firebase Storage

```dart:46:68:lib/data/services/storage_service.dart
  // Upload image to Firebase Storage
  Future<String?> uploadTicketImage({
    required File imageFile,
    required String ticketId,
  }) async {
    try {
      final String fileName = 'tickets/$ticketId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child(fileName);
      
      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
```

**Upload Process:**
1. **Line 52**: Generate unique path: `tickets/{ticketId}/{timestamp}.jpg`
2. **Line 53**: Get storage reference
3. **Lines 55-58**: Upload with JPEG content type
4. **Line 61**: Get public download URL
5. URL is stored in Firestore ticket document

---

## 📝 Create Ticket Screen

**File: `lib/presentation/screens/user/create_ticket_screen.dart`**

A form screen for users to report new facility issues.

### State & Controllers

```dart:14:31:lib/presentation/screens/user/create_ticket_screen.dart
class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final StorageService _storageService = StorageService();

  File? _selectedImage;
  TicketCategory _selectedCategory = TicketCategory.other;
  TicketPriority _selectedPriority = TicketPriority.medium;
  bool _isSubmitting = false;
```

**State Variables:**
- `_formKey`: For form validation
- `_titleController`, `_descriptionController`: Text input controllers
- `_selectedImage`: Picked image file
- `_selectedCategory`, `_selectedPriority`: Dropdown selections

### Image Picker Bottom Sheet

```dart:49:92:lib/presentation/screens/user/create_ticket_screen.dart
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
```

**UI Pattern:**
- Modal bottom sheet with rounded top corners
- Two options: Camera and Gallery
- Closes sheet before picking image

### Form Submission

```dart:116:163:lib/presentation/screens/user/create_ticket_screen.dart
  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final success = await ticketProvider.createTicket(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      createdByUid: user.uid,
      createdByName: user.name,
      imageFile: _selectedImage,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.ticketCreatedSuccess),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ticketProvider.errorMessage ?? AppStrings.errorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
```

**Submission Flow:**
1. **Line 117**: Validate form (title, description)
2. **Lines 119-121**: Show loading state
3. **Lines 123-127**: Get providers and current user
4. **Lines 134-142**: Call provider to create ticket
5. **Lines 150-162**: Show success/error feedback

### Image Picker UI Widget

```dart:257:302:lib/presentation/screens/user/create_ticket_screen.dart
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderLight,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: _selectedImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.uploadImage,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
```

**Conditional UI:**
- **No image**: Shows placeholder with camera icon and "Tap to add photo"
- **With image**: Shows image preview with red X button to remove

---

## 🏠 User Home Screen

**File: `lib/presentation/screens/user/user_home_screen.dart`**

The main screen for regular users showing their tickets.

### Initializing Data Stream

```dart:17:32:lib/presentation/screens/user/user_home_screen.dart
class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTickets();
    });
  }

  void _initializeTickets() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      ticketProvider.initUserTickets(authProvider.currentUser!.uid);
    }
  }
```

**Why `addPostFrameCallback`?**
- Provider context needs to be available
- Prevents "setState during build" errors
- Ensures widget is mounted before accessing providers

### Consumer Widget for Reactive UI

```dart:81:118:lib/presentation/screens/user/user_home_screen.dart
          // Tickets list
          Expanded(
            child: Consumer<TicketProvider>(
              builder: (context, ticketProvider, child) {
                if (ticketProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryTeal,
                    ),
                  );
                }

                if (ticketProvider.tickets.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _initializeTickets();
                  },
                  color: AppColors.primaryTeal,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: ticketProvider.tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = ticketProvider.tickets[index];
                      return TicketCard(
                        ticket: ticket,
                        onTap: () {
                          AppRoutes.navigateTo(
                            context,
                            AppRoutes.ticketDetails,
                            arguments: ticket.id,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
```

**Consumer Pattern Explained:**
- **Line 83**: `Consumer<TicketProvider>` rebuilds only when TicketProvider changes
- **Lines 85-91**: Loading state with spinner
- **Lines 93-95**: Empty state when no tickets
- **Lines 97-117**: List of tickets with pull-to-refresh

**RefreshIndicator:**
- Pull down to refresh ticket list
- Calls `_initializeTickets()` to restart stream

### Floating Action Button

```dart:122:133:lib/presentation/screens/user/user_home_screen.dart
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppRoutes.navigateTo(context, AppRoutes.createTicket);
        },
        backgroundColor: AppColors.primaryTeal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Issue',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
```

**Extended FAB:**
- Shows icon + text for better UX
- Navigates to Create Ticket screen

---

## 👑 Admin Dashboard Screen

**File: `lib/presentation/screens/admin/admin_dashboard_screen.dart`**

Dashboard for administrators with statistics and all tickets.

### Stats Cards with Real-time Data

```dart:69:99:lib/presentation/screens/admin/admin_dashboard_screen.dart
                // Stats cards
                Consumer<TicketProvider>(
                  builder: (context, ticketProvider, child) {
                    return Row(
                      children: [
                        _buildStatCard(
                          context,
                          'Open',
                          ticketProvider.openCount.toString(),
                          AppColors.statusOpen,
                          Icons.error_outline,
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          context,
                          'In Progress',
                          ticketProvider.inProgressCount.toString(),
                          AppColors.statusInProgress,
                          Icons.pending_outlined,
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          context,
                          'Resolved',
                          ticketProvider.resolvedCount.toString(),
                          AppColors.statusResolved,
                          Icons.check_circle_outline,
                        ),
                      ],
                    );
                  },
                ),
```

**Real-time Stats:**
- Consumer rebuilds when `ticketCounts` change in provider
- Three colored cards: Red (Open), Amber (In Progress), Green (Resolved)
- Values update automatically via Firestore stream

### Stat Card Widget

```dart:182:215:lib/presentation/screens/admin/admin_dashboard_screen.dart
  Widget _buildStatCard(
    BuildContext context,
    String label,
    String count,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              count,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              // ...
            ),
          ],
        ),
      ),
    );
  }
```

**Design:**
- Expanded to fill available width equally
- Color-coded background with matching shadow
- Icon, count, and label stacked vertically

### Filter Chips

```dart:103:142:lib/presentation/screens/admin/admin_dashboard_screen.dart
          // Filter chips
          Consumer<TicketProvider>(
            builder: (context, ticketProvider, child) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildFilterChip(
                      'All Tickets',
                      ticketProvider.currentFilter == 'all',
                      () => ticketProvider.setFilter('all'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Open',
                      ticketProvider.currentFilter == 'open',
                      () => ticketProvider.setFilter('open'),
                      color: AppColors.statusOpen,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'In Progress',
                      ticketProvider.currentFilter == 'in progress',
                      () => ticketProvider.setFilter('in progress'),
                      color: AppColors.statusInProgress,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Resolved',
                      ticketProvider.currentFilter == 'resolved',
                      () => ticketProvider.setFilter('resolved'),
                      color: AppColors.statusResolved,
                    ),
                  ],
                ),
              );
            },
          ),
```

**Filter Chip Behavior:**
- Horizontal scrollable row
- Selected chip is filled with color
- Unselected chips have outline only
- Tapping calls `setFilter()` which updates the ticket list

### Filter Chip Widget

```dart:217:244:lib/presentation/screens/admin/admin_dashboard_screen.dart
  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? AppColors.accentOrange) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? (color ?? AppColors.accentOrange) : AppColors.borderLight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (color ?? AppColors.accentOrange).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
```

**Animation:**
- `AnimatedContainer` provides smooth transition when selection changes
- Shadow appears on selected chip
- Text color inverts (dark to white)

---

## 📋 Ticket Details Screen

**File: `lib/presentation/screens/shared/ticket_details_screen.dart`**

Shows ticket details with role-based editing for admins.

### Loading Ticket Data

```dart:25:42:lib/presentation/screens/shared/ticket_details_screen.dart
  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  Future<void> _loadTicket() async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final ticket = await ticketProvider.getTicket(widget.ticketId);
    
    if (mounted) {
      setState(() {
        _ticket = ticket;
        _selectedStatus = ticket?.status;
        _isLoading = false;
      });
    }
  }
```

**Loading Pattern:**
- Fetches ticket by ID from provider
- Sets local state for editing
- `mounted` check prevents setState after dispose

### SliverAppBar with Hero Image

```dart:83:112:lib/presentation/screens/shared/ticket_details_screen.dart
                  CustomScrollView(
                  slivers: [
                    // Image header
                    SliverAppBar(
                      expandedHeight: 300,
                      pinned: true,
                      backgroundColor: AppColors.primaryTeal,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: _ticket!.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: _ticket!.imageUrl!,
                                fit: BoxFit.cover,
                                // ...
                              )
                            : _buildPlaceholderImage(),
                      ),
                    ),
```

**SliverAppBar Features:**
- **expandedHeight: 300**: Large hero image
- **pinned: true**: AppBar stays visible when scrolled
- **FlexibleSpaceBar**: Image collapses on scroll
- **CachedNetworkImage**: Caches images for performance

### Role-Based Status Display

```dart:72:77:lib/presentation/screens/shared/ticket_details_screen.dart
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;

    // Later in the build...
    if (isAdmin)
      _buildStatusSelector()
    else
      _buildStatusDisplay(),
```

**Conditional Rendering:**
- **Users**: See read-only status badge
- **Admins**: See interactive status selector

### Status Selector for Admins

```dart:240:278:lib/presentation/screens/shared/ticket_details_screen.dart
  Widget _buildStatusSelector() {
    return Row(
      children: TicketStatus.values.map((status) {
        final isSelected = _selectedStatus == status;
        final color = AppColors.getStatusColor(status.displayName);

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = status;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(status),
                    color: isSelected ? Colors.white : color,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
```

**Status Selector UI:**
- Three equal-width buttons (Open, In Progress, Resolved)
- Color-coded backgrounds
- Selected state is filled, others are outlined
- Icons change color based on selection

### Update Status Button

```dart:173:199:lib/presentation/screens/shared/ticket_details_screen.dart
                              // Update button (admin only)
                              if (isAdmin && _selectedStatus != _ticket!.status)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _isUpdating ? null : _updateStatus,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentOrange,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: _isUpdating
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.check, color: Colors.white),
                                    label: Text(
                                      _isUpdating ? 'Updating...' : AppStrings.updateStatus,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
```

**Button Logic:**
- Only visible when status has changed
- Shows spinner during update
- Disabled while updating
- Orange background for admin actions

---

## 🎴 Ticket Card Widget

**File: `lib/presentation/widgets/ticket/ticket_card.dart`**

Reusable card component for displaying tickets in lists.

### Card Structure

```dart:12:31:lib/presentation/widgets/ticket/ticket_card.dart
class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;
  final bool showReporter;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
    this.showReporter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        // ...
```

**Props:**
- `ticket`: The ticket data to display
- `onTap`: Callback for navigation
- `showReporter`: Show "By: Name" (used in admin view)

### Thumbnail with CachedNetworkImage

```dart:105:141:lib/presentation/widgets/ticket/ticket_card.dart
  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 70,
        height: 70,
        child: ticket.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: ticket.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.backgroundLight,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.backgroundLight,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            : Container(
                color: AppColors.backgroundTeal,
                child: Icon(
                  _getCategoryIcon(ticket.category),
                  color: AppColors.primaryTeal,
                  size: 32,
                ),
              ),
      ),
    );
  }
```

**Image Handling:**
- **With image**: Cached network image with loading spinner
- **Without image**: Category icon on teal background
- **Error state**: Broken image icon

### Status Chip

```dart:143:160:lib/presentation/widgets/ticket/ticket_card.dart
  Widget _buildStatusChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.getStatusColor(ticket.status.displayName),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        ticket.status.displayName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
```

**Dynamic Coloring:**
- `AppColors.getStatusColor()` returns:
  - Red for "Open"
  - Amber for "In Progress"
  - Green for "Resolved"

### Category Icons

```dart:162:177:lib/presentation/widgets/ticket/ticket_card.dart
  IconData _getCategoryIcon(TicketCategory category) {
    switch (category) {
      case TicketCategory.it:
        return Icons.computer;
      case TicketCategory.electrical:
        return Icons.electrical_services;
      case TicketCategory.plumbing:
        return Icons.plumbing;
      case TicketCategory.hvac:
        return Icons.ac_unit;
      case TicketCategory.furniture:
        return Icons.chair;
      case TicketCategory.other:
        return Icons.more_horiz;
    }
  }
```

**Visual Distinction:**
- Each category has a unique Material icon
- Helps users quickly identify ticket type

---

## 🔄 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        FIRESTORE                                 │
│                                                                  │
│   ┌─────────────┐         ┌─────────────┐                       │
│   │   users     │         │   tickets   │                       │
│   └──────┬──────┘         └──────┬──────┘                       │
│          │                       │                               │
└──────────┼───────────────────────┼───────────────────────────────┘
           │                       │
           │    Stream             │    Stream
           │                       │
           ▼                       ▼
┌──────────────────────────────────────────────────────────────────┐
│                    FIRESTORE SERVICE                              │
│                                                                   │
│   streamUserTickets(userId)    streamAllTickets()                │
│   streamTicketCounts()         createTicket()                    │
│   updateTicketStatus()                                           │
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│                    TICKET PROVIDER                                │
│                                                                   │
│   _tickets: List<TicketModel>     _ticketCounts: Map<String,int> │
│   _filteredTickets                _currentFilter                  │
│                                                                   │
│   notifyListeners() ─────────────────────────────────────────────►
└────────────────────────┬─────────────────────────────────────────┘
                         │
                         │    Consumer<TicketProvider>
                         │
                         ▼
┌──────────────────────────────────────────────────────────────────┐
│                         UI SCREENS                                │
│                                                                   │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│   │  User Home   │  │Admin Dashboard│  │Ticket Details│          │
│   │              │  │              │  │              │          │
│   │ - Ticket List│  │ - Stats Cards│  │ - Status Edit│          │
│   │ - FAB        │  │ - Filters   │  │ - Update Btn │          │
│   │ - Empty State│  │ - All Tickets│  │              │          │
│   └──────────────┘  └──────────────┘  └──────────────┘          │
└──────────────────────────────────────────────────────────────────┘
```

---

## 📊 Real-time Updates Flow

```
1. User/Admin opens screen
   │
   ▼
2. initState() calls initUserTickets() or initAdminTickets()
   │
   ▼
3. Provider subscribes to Firestore stream
   │
   ▼
4. Stream emits initial data
   │
   ▼
5. Provider updates _tickets and calls notifyListeners()
   │
   ▼
6. Consumer widgets rebuild with new data
   │
   ▼
7. [Data changes in Firestore]
   │
   ▼
8. Stream automatically emits new data → Go to step 5
```

---

## 🎨 UI Components Summary

| Component | Location | Purpose |
|-----------|----------|---------|
| **TicketCard** | `widgets/ticket/ticket_card.dart` | Display ticket in lists |
| **CustomButton** | `widgets/common/custom_button.dart` | Styled buttons |
| **CustomTextField** | `widgets/common/custom_text_field.dart` | Form inputs |
| **FilterChip** | `admin_dashboard_screen.dart` | Status filtering |
| **StatCard** | `admin_dashboard_screen.dart` | Dashboard statistics |
| **StatusSelector** | `ticket_details_screen.dart` | Admin status editing |

---

## ✅ Implementation Checklist

| Feature | Status | File |
|---------|--------|------|
| Ticket Provider | ✅ | `providers/ticket_provider.dart` |
| Storage Service | ✅ | `services/storage_service.dart` |
| User Home Screen | ✅ | `screens/user/user_home_screen.dart` |
| Create Ticket Screen | ✅ | `screens/user/create_ticket_screen.dart` |
| Admin Dashboard | ✅ | `screens/admin/admin_dashboard_screen.dart` |
| Ticket Details | ✅ | `screens/shared/ticket_details_screen.dart` |
| Profile Screen | ✅ | `screens/shared/profile_screen.dart` |
| Notifications Screen | ✅ | `screens/shared/notifications_screen.dart` |
| Ticket Card Widget | ✅ | `widgets/ticket/ticket_card.dart` |
| Real-time Updates | ✅ | Via Firestore streams |
| Image Upload | ✅ | Via Storage Service |
| Filter Functionality | ✅ | In Admin Dashboard |
| Status Management | ✅ | In Ticket Details |

---

*Document Version: 1.0*
*Last Updated: December 2024*


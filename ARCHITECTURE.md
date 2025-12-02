# FixIt Now - Architecture Overview

## 📱 Project Overview

**FixIt Now** is a role-based facility management application that enables users to report facility issues (broken WiFi, plumbing problems, etc.) and allows administrators to track and resolve these issues efficiently.

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter (Dart) |
| **Backend** | Firebase Suite |
| **Authentication** | Firebase Auth (Email/Password + Google Sign-In) |
| **Database** | Cloud Firestore |
| **Storage** | Firebase Storage |
| **State Management** | Provider (ChangeNotifier) |
| **Architecture** | MVVM (Model-View-ViewModel) |

---

## 🎨 Design System

### Color Palette

```dart
// Primary Colors
static const Color primaryTeal = Color(0xFF009688);      // AppBars, Primary Buttons, Active States
static const Color primaryTealLight = Color(0xFF4DB6AC);
static const Color primaryTealDark = Color(0xFF00796B);

// Secondary/Accent Colors
static const Color accentOrange = Color(0xFFFF5722);     // Submit Buttons, High Priority

// Status Colors
static const Color statusOpen = Color(0xFFF44336);       // Red - Open tickets
static const Color statusInProgress = Color(0xFFFFC107); // Amber - In Progress
static const Color statusResolved = Color(0xFF4CAF50);   // Green - Resolved

// Neutral Colors
static const Color backgroundLight = Color(0xFFF5F5F5);
static const Color surfaceWhite = Color(0xFFFFFFFF);
static const Color textPrimary = Color(0xFF212121);
static const Color textSecondary = Color(0xFF757575);
```

### Typography

- **Font Family**: Poppins (Google Fonts)
- **Headline Large**: 32sp, Bold
- **Headline Medium**: 24sp, SemiBold
- **Body Large**: 16sp, Regular
- **Body Medium**: 14sp, Regular
- **Label Large**: 14sp, Medium

---

## 📁 Project Structure (MVVM Pattern)

```
lib/
├── main.dart                          # App entry point
├── app/
│   ├── app.dart                       # MaterialApp configuration
│   └── routes.dart                    # Named routes definition
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Color constants
│   │   ├── app_strings.dart           # String constants
│   │   └── app_assets.dart            # Asset paths
│   ├── theme/
│   │   └── app_theme.dart             # ThemeData configuration
│   └── utils/
│       └── validators.dart            # Form validators
├── data/
│   ├── models/
│   │   ├── user_model.dart            # User data model
│   │   └── ticket_model.dart          # Ticket data model
│   └── services/
│       ├── auth_service.dart          # Firebase Auth operations
│       ├── firestore_service.dart     # Firestore CRUD operations
│       └── storage_service.dart       # Firebase Storage operations
├── providers/
│   ├── auth_provider.dart             # Authentication state
│   └── ticket_provider.dart           # Ticket list state
└── presentation/
    ├── screens/
    │   ├── splash/
    │   │   └── splash_screen.dart
    │   ├── onboarding/
    │   │   └── onboarding_screen.dart
    │   ├── auth/
    │   │   ├── login_screen.dart
    │   │   └── register_screen.dart
    │   ├── user/
    │   │   ├── user_home_screen.dart
    │   │   └── create_ticket_screen.dart
    │   ├── admin/
    │   │   └── admin_dashboard_screen.dart
    │   └── shared/
    │       ├── ticket_details_screen.dart
    │       ├── notifications_screen.dart
    │       └── profile_screen.dart
    └── widgets/
        ├── common/
        │   ├── custom_button.dart
        │   ├── custom_text_field.dart
        │   └── loading_indicator.dart
        └── ticket/
            └── ticket_card.dart
```

---

## 🗄 Database Schema

### Firestore Collections

#### `users` Collection
```json
{
  "uid": "string (document ID, matches Firebase Auth UID)",
  "email": "string",
  "name": "string",
  "role": "string ('user' | 'admin')",
  "department": "string (optional)",
  "photoUrl": "string (optional)",
  "createdAt": "timestamp"
}
```

#### `tickets` Collection
```json
{
  "id": "string (auto-generated document ID)",
  "title": "string",
  "description": "string",
  "imageUrl": "string (Firebase Storage URL)",
  "category": "string ('IT' | 'Electrical' | 'Plumbing' | 'HVAC' | 'Furniture' | 'Other')",
  "priority": "string ('Low' | 'Medium' | 'High')",
  "status": "string ('Open' | 'In Progress' | 'Resolved')",
  "createdByUid": "string (reference to users collection)",
  "createdByName": "string (denormalized for display)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "resolvedAt": "timestamp (optional)"
}
```

---

## 🔐 Role-Based Access Control (RBAC)

### Authentication Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         APP LAUNCH                               │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                      SPLASH SCREEN                               │
│              (Check Firebase Auth State)                         │
└─────────────────────────┬───────────────────────────────────────┘
                          │
              ┌───────────┴───────────┐
              │                       │
              ▼                       ▼
      ┌───────────────┐       ┌───────────────┐
      │ NOT LOGGED IN │       │   LOGGED IN   │
      └───────┬───────┘       └───────┬───────┘
              │                       │
              ▼                       ▼
      ┌───────────────┐       ┌───────────────────────┐
      │  ONBOARDING   │       │   FETCH USER DOC      │
      │  (First Time) │       │   FROM FIRESTORE      │
      └───────┬───────┘       └───────────┬───────────┘
              │                           │
              ▼                           │
      ┌───────────────┐       ┌───────────┴───────────┐
      │ LOGIN/REGISTER│       │                       │
      └───────────────┘       ▼                       ▼
                      ┌─────────────────┐   ┌─────────────────┐
                      │  role == 'user' │   │ role == 'admin' │
                      └────────┬────────┘   └────────┬────────┘
                               │                     │
                               ▼                     ▼
                      ┌─────────────────┐   ┌─────────────────┐
                      │   USER HOME     │   │ ADMIN DASHBOARD │
                      │   (Teal Theme)  │   │ (Orange Theme)  │
                      └─────────────────┘   └─────────────────┘
```

### Role Determination Logic (The "Gatekeeper")

```dart
Future<void> routeBasedOnRole(User firebaseUser) async {
  // Fetch user document from Firestore
  final userDoc = await firestore.collection('users').doc(firebaseUser.uid).get();
  
  if (!userDoc.exists) {
    // New user - create document with default 'user' role
    await createUserDocument(firebaseUser, role: 'user');
    navigateTo('/user-home');
    return;
  }
  
  final userData = userDoc.data();
  final role = userData['role'] as String;
  
  if (role == 'admin') {
    navigateTo('/admin-dashboard');
  } else {
    navigateTo('/user-home');
  }
}
```

### Creating Admin Users

**Important**: Admin users must be created manually in Firebase Console or via a secure backend function. The app does NOT allow self-registration as admin.

**Manual Process:**
1. User registers normally (gets 'user' role)
2. Admin goes to Firebase Console → Firestore
3. Navigate to `users` collection → find user document
4. Change `role` field from `'user'` to `'admin'`
5. User logs out and logs back in to get admin access

---

## 🚀 Application Screens

### Phase 1: Auth & Onboarding

| Screen | Route | Description |
|--------|-------|-------------|
| Splash | `/` | Initial loading, auth check |
| Onboarding | `/onboarding` | 3-slide feature introduction |
| Login | `/login` | Email/Password + Google Sign-In |
| Register | `/register` | New user registration |

### Phase 2: User Flow (Reporter)

| Screen | Route | Description |
|--------|-------|-------------|
| User Home | `/user-home` | List of user's tickets |
| Create Ticket | `/create-ticket` | Form to submit new ticket |
| Ticket Details | `/ticket-details` | View ticket (read-only) |

### Phase 3: Admin Flow (Manager)

| Screen | Route | Description |
|--------|-------|-------------|
| Admin Dashboard | `/admin-dashboard` | All tickets with stats |
| Ticket Details | `/ticket-details` | Edit ticket status |

### Shared Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Profile | `/profile` | User info, settings, logout |
| Notifications | `/notifications` | Status update notifications |

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.6.0
  firebase_storage: ^12.4.0
  
  # State Management
  provider: ^6.1.2
  
  # Google Sign-In
  google_sign_in: ^6.2.2
  
  # UI/UX
  google_fonts: ^6.2.1
  smooth_page_indicator: ^1.2.0+3
  image_picker: ^1.1.2
  cached_network_image: ^3.4.1
  
  # Utilities
  shared_preferences: ^2.3.4
  intl: ^0.19.0
```

---

## 🔄 State Management Pattern

### Provider Architecture

```dart
// AuthProvider - Manages authentication state
class AuthProvider extends ChangeNotifier {
  User? _firebaseUser;
  UserModel? _currentUser;
  bool _isLoading = false;
  
  // Exposes current user data
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  
  // Auth methods
  Future<void> signInWithEmail(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signUp(String email, String password, String name);
  Future<void> signOut();
}

// TicketProvider - Manages ticket list state
class TicketProvider extends ChangeNotifier {
  List<TicketModel> _tickets = [];
  bool _isLoading = false;
  
  // For Users: fetch only their tickets
  Stream<List<TicketModel>> getUserTickets(String uid);
  
  // For Admins: fetch all tickets
  Stream<List<TicketModel>> getAllTickets();
  
  // CRUD operations
  Future<void> createTicket(TicketModel ticket);
  Future<void> updateTicketStatus(String ticketId, String newStatus);
}
```

---

## 🧪 Firebase Setup Guide

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project named "FixIt Now"
3. Enable Google Analytics (optional)

### Step 2: Add Flutter App
1. Click "Add app" → Flutter icon
2. Follow the FlutterFire CLI setup:
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```

### Step 3: Enable Authentication
1. Go to Authentication → Sign-in method
2. Enable **Email/Password**
3. Enable **Google** (configure OAuth consent screen)

### Step 4: Create Firestore Database
1. Go to Firestore Database → Create database
2. Start in **test mode** for development
3. Choose closest region

### Step 5: Set Up Storage
1. Go to Storage → Get started
2. Start in **test mode** for development

### Step 6: Firestore Security Rules (Production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Tickets collection
    match /tickets/{ticketId} {
      // Anyone authenticated can read
      allow read: if request.auth != null;
      
      // Users can create tickets
      allow create: if request.auth != null 
        && request.resource.data.createdByUid == request.auth.uid;
      
      // Only admins can update (status changes)
      allow update: if request.auth != null 
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

---

## 📋 Development Phases

### ✅ Phase 1: Architecture & Planning
- [x] Project structure definition
- [x] Database schema design
- [x] RBAC flow design
- [x] Architecture documentation

### 🔄 Phase 2: Firebase + Auth + Onboarding (Current)
- [ ] Firebase integration
- [ ] Auth service implementation
- [ ] Splash screen
- [ ] Onboarding carousel
- [ ] Login/Register screens
- [ ] RBAC routing logic
- [ ] Placeholder home screens

### 📅 Phase 3: User Flow
- [ ] User home screen with ticket list
- [ ] Create ticket form with image upload
- [ ] Ticket details (read-only view)
- [ ] Real-time updates

### 📅 Phase 4: Admin Flow
- [ ] Admin dashboard with statistics
- [ ] Filter chips for ticket filtering
- [ ] Ticket status update functionality
- [ ] User management (optional)

### 📅 Phase 5: Polish & Notifications
- [ ] Push notifications
- [ ] Profile & settings
- [ ] Dark mode support
- [ ] Performance optimization

---

## 👨‍💻 Author

FixIt Now - Facility Management Made Simple

---

*Last Updated: December 2024*


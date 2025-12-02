# Phase 1: Project Overview & Architecture

## 📱 FixIt Now - Facility Management Application

**FixIt Now** is a role-based facility management application that streamlines the process of reporting and resolving facility issues. Whether it's a broken WiFi connection, plumbing problem, or electrical issue, users can quickly report problems while administrators efficiently track and resolve them.

---

## 🎯 Project Goals

1. **For Users (Reporters)**:
   - Easily report facility issues with photos
   - Track the status of their submitted tickets
   - Receive notifications when issues are resolved

2. **For Admins (Managers)**:
   - View all tickets from all users in one dashboard
   - Filter and prioritize tickets
   - Update ticket status (Open → In Progress → Resolved)
   - Access statistics and analytics

---

## 🛠 Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Frontend** | Flutter (Dart) | Cross-platform mobile UI |
| **Backend** | Firebase | Serverless backend services |
| **Authentication** | Firebase Auth | User login/registration |
| **Database** | Cloud Firestore | Real-time NoSQL database |
| **Storage** | Firebase Storage | Image storage for tickets |
| **State Management** | Provider | Reactive state management |

---

## 🏗 MVVM Architecture

### What is MVVM?

**MVVM (Model-View-ViewModel)** is a software architectural pattern that separates the development of the graphical user interface from the business logic. This separation makes the code more maintainable, testable, and scalable.

### The Three Layers

```
┌─────────────────────────────────────────────────────────────┐
│                         VIEW                                 │
│   (Screens & Widgets - What the user sees)                  │
│   • Splash Screen, Login, Dashboard, etc.                   │
│   • Listens to ViewModel for data changes                   │
└─────────────────────────┬───────────────────────────────────┘
                          │ Observes
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      VIEWMODEL                               │
│   (Providers - Business Logic & State)                      │
│   • AuthProvider, TicketProvider                            │
│   • Handles user actions, calls Services                    │
│   • Notifies Views of state changes                         │
└─────────────────────────┬───────────────────────────────────┘
                          │ Uses
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                        MODEL                                 │
│   (Data Models & Services)                                  │
│   • UserModel, TicketModel                                  │
│   • AuthService, FirestoreService                           │
│   • Communicates with Firebase                              │
└─────────────────────────────────────────────────────────────┘
```

### How We Achieve MVVM in This Project

#### 1. **MODEL Layer** (`lib/data/`)

The Model layer contains data structures and services that interact with external systems (Firebase).

```
lib/data/
├── models/
│   ├── user_model.dart      # User data structure
│   └── ticket_model.dart    # Ticket data structure
└── services/
    ├── auth_service.dart    # Firebase Auth operations
    └── firestore_service.dart # Firestore CRUD operations
```

**Purpose**:
- Define data structures (`UserModel`, `TicketModel`)
- Handle all Firebase communication
- Pure data logic with no UI dependencies

#### 2. **VIEWMODEL Layer** (`lib/providers/`)

The ViewModel layer acts as a bridge between the View and Model. It contains the business logic and state management.

```
lib/providers/
├── auth_provider.dart       # Authentication state & logic
└── ticket_provider.dart     # Ticket list state & operations (Phase 3)
```

**Purpose**:
- Manage application state using `ChangeNotifier`
- Process data from Services for Views
- Handle user actions and update state
- Notify Views when data changes

#### 3. **VIEW Layer** (`lib/presentation/`)

The View layer contains all UI components - screens and widgets.

```
lib/presentation/
├── screens/
│   ├── splash/
│   ├── onboarding/
│   ├── auth/
│   ├── user/
│   ├── admin/
│   └── shared/
└── widgets/
    └── common/
```

**Purpose**:
- Display UI to users
- Listen to ViewModel changes via `Provider`
- Dispatch user actions to ViewModel
- No business logic, only presentation

---

## 📁 Complete Project Structure

```
lib/
├── main.dart                    # Entry point - Firebase init
├── firebase_options.dart        # Firebase configuration
│
├── app/                         # App Configuration
│   ├── app.dart                 # MaterialApp with Providers
│   └── routes.dart              # Named routes & navigation
│
├── core/                        # Core Utilities
│   ├── constants/
│   │   ├── app_colors.dart      # Color palette
│   │   ├── app_strings.dart     # Text strings
│   │   └── app_assets.dart      # Asset paths
│   ├── theme/
│   │   └── app_theme.dart       # Material 3 theme
│   └── utils/
│       └── validators.dart      # Form validation
│
├── data/                        # MODEL Layer
│   ├── models/
│   │   ├── user_model.dart      # User data model
│   │   └── ticket_model.dart    # Ticket data model
│   └── services/
│       ├── auth_service.dart    # Auth operations
│       └── firestore_service.dart # Database operations
│
├── providers/                   # VIEWMODEL Layer
│   └── auth_provider.dart       # Auth state management
│
└── presentation/                # VIEW Layer
    ├── screens/
    │   ├── splash/
    │   │   └── splash_screen.dart
    │   ├── onboarding/
    │   │   └── onboarding_screen.dart
    │   ├── auth/
    │   │   ├── login_screen.dart
    │   │   └── register_screen.dart
    │   ├── user/
    │   │   └── user_home_screen.dart
    │   └── admin/
    │       └── admin_dashboard_screen.dart
    └── widgets/
        └── common/
            ├── custom_button.dart
            └── custom_text_field.dart
```

---

## 🎨 Design System

### Color Palette

| Color | Hex Code | Usage |
|-------|----------|-------|
| **Primary Teal** | `#009688` | AppBars, primary buttons, user theme |
| **Accent Orange** | `#FF5722` | Submit buttons, admin theme, high priority |
| **Status Red** | `#F44336` | Open tickets |
| **Status Amber** | `#FFC107` | In Progress tickets |
| **Status Green** | `#4CAF50` | Resolved tickets |

### Typography

- **Font Family**: Poppins (via Google Fonts)
- **Weights**: Regular (400), Medium (500), SemiBold (600), Bold (700)

### UI Components

- Material Design 3
- Rounded corners (12px for cards, 28px for buttons)
- Consistent shadows and elevations
- Curved headers on auth screens

---

## 📊 Database Schema

### Firestore Collections

#### 1. `users` Collection

Stores user profile and role information.

```json
{
  "uid": "firebase-auth-uid",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "user",           // "user" or "admin"
  "department": "IT",       // optional
  "photoUrl": "https://...", // optional
  "createdAt": "Timestamp"
}
```

#### 2. `tickets` Collection

Stores all maintenance tickets.

```json
{
  "id": "auto-generated-id",
  "title": "Broken Office Chair",
  "description": "The wheel on the chair has snapped off...",
  "imageUrl": "https://firebasestorage.googleapis.com/...",
  "category": "Furniture",  // IT, Electrical, Plumbing, HVAC, Furniture, Other
  "priority": "High",       // Low, Medium, High
  "status": "Open",         // Open, In Progress, Resolved
  "createdByUid": "user-uid",
  "createdByName": "John Doe",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp",
  "resolvedAt": "Timestamp" // optional
}
```

---

## 🚀 Application Screens

### Phase 2 Screens (Current)

| Screen | Route | Description |
|--------|-------|-------------|
| **Splash** | `/` | Logo, loading, auth check |
| **Onboarding** | `/onboarding` | 3-slide intro carousel |
| **Login** | `/login` | Email/Password + Google |
| **Register** | `/register` | New user registration |
| **User Home** | `/user-home` | Placeholder showing "USER" |
| **Admin Dashboard** | `/admin-dashboard` | Placeholder showing "ADMIN" |

### Future Phases

| Screen | Phase | Description |
|--------|-------|-------------|
| Create Ticket | Phase 3 | Form with image upload |
| Ticket Details | Phase 3 | View/Edit ticket |
| Profile | Phase 4 | User settings, logout |
| Notifications | Phase 4 | Status update alerts |

---

## 🔄 Application Flow

```
                    ┌──────────────┐
                    │  App Launch  │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │Splash Screen │
                    │ (Auth Check) │
                    └──────┬───────┘
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
      ┌───────────────┐         ┌───────────────┐
      │ Not Logged In │         │   Logged In   │
      └───────┬───────┘         └───────┬───────┘
              │                         │
              ▼                         ▼
      ┌───────────────┐         ┌───────────────┐
      │  First Time?  │         │  Fetch User   │
      │   Yes → No    │         │  From Firestore│
      └───┬───────┬───┘         └───────┬───────┘
          │       │                     │
          ▼       ▼             ┌───────┴───────┐
    Onboarding  Login           │               │
         │        │             ▼               ▼
         └────┬───┘     ┌─────────────┐ ┌─────────────┐
              │         │role = user  │ │role = admin │
              ▼         └──────┬──────┘ └──────┬──────┘
        Login/Register         │               │
              │                ▼               ▼
              └───────→  User Home      Admin Dashboard
                        (Teal Theme)    (Orange Theme)
```

---

## 📦 Dependencies

```yaml
dependencies:
  # Firebase Suite
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.6.0
  firebase_storage: ^12.4.0

  # State Management
  provider: ^6.1.2

  # Authentication
  google_sign_in: ^6.2.2

  # UI Components
  google_fonts: ^6.2.1
  smooth_page_indicator: ^1.2.0+3
  cached_network_image: ^3.4.1

  # Utilities
  shared_preferences: ^2.3.4
  image_picker: ^1.1.2
  intl: ^0.19.0
```

---

## 🎯 What We're Building

### Complete Feature List

1. **Authentication System**
   - Email/Password login & registration
   - Google Sign-In integration
   - Persistent login sessions
   - Secure logout

2. **Role-Based Access Control (RBAC)**
   - Two roles: `user` and `admin`
   - Role stored in Firestore
   - Different UI/features per role
   - Admin-only ticket management

3. **User Features**
   - View personal tickets
   - Create new tickets with photos
   - Track ticket status
   - Receive notifications

4. **Admin Features**
   - View all tickets from all users
   - Dashboard with statistics
   - Filter tickets by status/category
   - Update ticket status
   - Resolve tickets

5. **Shared Features**
   - Profile management
   - Dark mode toggle
   - Push notifications
   - Settings screen

---

## 📋 Development Phases

| Phase | Focus | Status |
|-------|-------|--------|
| **Phase 1** | Architecture & Planning | ✅ Complete |
| **Phase 2** | Firebase + Auth + Onboarding | ✅ Complete |
| **Phase 3** | User Ticket Creation | 📅 Planned |
| **Phase 4** | Admin Ticket Management | 📅 Planned |
| **Phase 5** | Notifications & Polish | 📅 Planned |

---

## 🧠 Key Concepts

### Provider Pattern

Provider is used for state management, implementing the ViewModel layer:

```dart
// AuthProvider notifies listeners when state changes
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  
  UserModel? get currentUser => _currentUser;
  
  Future<void> signIn() async {
    // ... sign in logic
    notifyListeners(); // Updates all listening widgets
  }
}
```

### Reactive UI Updates

Views automatically rebuild when Provider state changes:

```dart
// In any widget
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isLoading) {
      return CircularProgressIndicator();
    }
    return Text(authProvider.currentUser?.name ?? 'Guest');
  },
)
```

### Named Routes

Navigation uses named routes for cleaner code:

```dart
// Navigate to a screen
AppRoutes.navigateTo(context, AppRoutes.userHome);

// Replace current screen
AppRoutes.navigateAndReplace(context, AppRoutes.login);

// Clear stack and navigate
AppRoutes.navigateAndClearStack(context, AppRoutes.adminDashboard);
```

---

## ✅ Phase 1 Summary

In Phase 1, we have:

1. ✅ Defined the complete project architecture
2. ✅ Created the MVVM folder structure
3. ✅ Designed the database schema
4. ✅ Established the design system (colors, typography)
5. ✅ Planned all screens and navigation
6. ✅ Set up dependencies in `pubspec.yaml`

**Next**: Phase 2 - Firebase Integration & Authentication

---

*Document Version: 1.0*
*Last Updated: December 2024*


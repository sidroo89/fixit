# 🔧 FixIt Now

A role-based facility management application built with Flutter and Firebase. Users can report facility issues (broken WiFi, plumbing, electrical) and administrators can track and resolve them efficiently.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

---

## ✨ Features

### For Users (Reporters)
- 📝 Report facility issues with photos
- 🔍 Track ticket status in real-time
- 🔔 Receive notifications on updates

### For Admins (Managers)
- 📊 Dashboard with ticket statistics
- 🎛 Filter and manage all tickets
- ✅ Update ticket status (Open → In Progress → Resolved)

---

## 🏗 Architecture

- **Pattern**: MVVM (Model-View-ViewModel)
- **State Management**: Provider
- **Backend**: Firebase (Auth, Firestore, Storage)

```
lib/
├── app/            # App configuration & routes
├── core/           # Constants, theme, utilities
├── data/           # Models & services (MODEL layer)
├── providers/      # State management (VIEWMODEL layer)
└── presentation/   # Screens & widgets (VIEW layer)
```

---

## 🚀 Quick Start

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10.0 or higher)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
- Android Studio / Xcode (for emulators)
- A Firebase project

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/fixit.git
   cd fixit
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (See [SETUP.md](SETUP.md) for detailed instructions)
   ```bash
   flutterfire configure
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [SETUP.md](SETUP.md) | Complete environment setup guide |
| [docs/PHASE_1_PROJECT_OVERVIEW.md](docs/PHASE_1_PROJECT_OVERVIEW.md) | Architecture & project overview |
| [docs/PHASE_2_FIREBASE_AUTH_RBAC.md](docs/PHASE_2_FIREBASE_AUTH_RBAC.md) | Firebase integration & RBAC details |
| [FIREBASE_SETUP.md](FIREBASE_SETUP.md) | Detailed Firebase configuration guide |

---

## 🎨 Design

| Theme | Color | Usage |
|-------|-------|-------|
| **Primary** | Teal `#009688` | User flow, AppBars |
| **Secondary** | Orange `#FF5722` | Admin flow, Submit buttons |
| **Status: Open** | Red `#F44336` | Open tickets |
| **Status: Progress** | Amber `#FFC107` | In-progress tickets |
| **Status: Resolved** | Green `#4CAF50` | Resolved tickets |

---

## 🔐 Role-Based Access Control

| Role | Access |
|------|--------|
| **User** | Create tickets, view own tickets, track status |
| **Admin** | View all tickets, update status, access dashboard |

> **Note**: Admin users must be manually promoted via Firebase Console. See [FIREBASE_SETUP.md](FIREBASE_SETUP.md#step-6-create-an-admin-user).

---

## 📱 Screenshots

*Coming soon*

---

## 🛣 Roadmap

- [x] Phase 1: Architecture & Planning
- [x] Phase 2: Firebase + Auth + Onboarding
- [ ] Phase 3: User Ticket Creation
- [ ] Phase 4: Admin Ticket Management
- [ ] Phase 5: Notifications & Polish

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Your Name**

---

*Built with ❤️ using Flutter & Firebase*

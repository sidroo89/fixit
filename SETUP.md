# 🛠 FixIt Now - Environment Setup Guide

This guide will walk you through setting up the development environment for the FixIt Now application from scratch.

---

## 📋 Table of Contents

1. [Prerequisites](#-prerequisites)
2. [Clone & Install](#-clone--install)
3. [Firebase Setup](#-firebase-setup)
4. [Platform Configuration](#-platform-configuration)
5. [Running the App](#-running-the-app)
6. [Creating Admin Users](#-creating-admin-users)
7. [Troubleshooting](#-troubleshooting)

---

## 📦 Prerequisites

### Required Software

| Software | Version | Installation |
|----------|---------|--------------|
| **Flutter SDK** | 3.10.0+ | [Install Flutter](https://docs.flutter.dev/get-started/install) |
| **Dart SDK** | 3.0.0+ | Included with Flutter |
| **Git** | Latest | [Install Git](https://git-scm.com/downloads) |
| **Android Studio** | Latest | [Download](https://developer.android.com/studio) |
| **Xcode** (macOS only) | 14.0+ | App Store |

### Firebase Tools

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

### Verify Installation

```bash
# Check Flutter
flutter doctor

# Check Firebase CLI
firebase --version

# Check FlutterFire CLI
flutterfire --version
```

---

## 📥 Clone & Install

### Step 1: Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/fixit.git
cd fixit
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 3: Verify Project Structure

Ensure these directories exist:
```
fixit/
├── lib/
│   ├── app/
│   ├── core/
│   ├── data/
│   ├── presentation/
│   └── providers/
├── android/
├── ios/
└── docs/
```

---

## 🔥 Firebase Setup

> **📚 Detailed Guide**: For comprehensive Firebase setup instructions, refer to [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

### Quick Setup Steps

#### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Name it `fixit-now` (or your preference)
4. Complete the setup wizard

#### 2. Configure FlutterFire

Run the FlutterFire CLI in the project root:

```bash
flutterfire configure
```

This will:
- ✅ Connect to your Firebase project
- ✅ Create `lib/firebase_options.dart`
- ✅ Generate platform-specific config files

**Select these platforms when prompted:**
- ✅ Android
- ✅ iOS  
- ✅ Web (optional)
- ✅ macOS (optional)

#### 3. Enable Firebase Services

In Firebase Console, enable:

| Service | Path | Action |
|---------|------|--------|
| **Authentication** | Authentication → Sign-in method | Enable Email/Password & Google |
| **Firestore** | Firestore Database | Create database in test mode |
| **Storage** | Storage | Initialize storage |

#### 4. Verify Configuration

After running `flutterfire configure`, verify that `lib/firebase_options.dart` was created:

```bash
ls lib/firebase_options.dart
```

If the file exists, Firebase is configured! ✅

---

## 📱 Platform Configuration

### Android Setup

#### 1. Minimum SDK Version

Ensure `android/app/build.gradle.kts` has:

```kotlin
android {
    defaultConfig {
        minSdk = 23  // Required for Firebase
    }
}
```

#### 2. Add SHA Keys for Google Sign-In

Generate SHA keys:

```bash
# Set JAVA_HOME if needed (uses Android Studio's JDK)
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"

# Generate signing report
cd android && ./gradlew signingReport
```

Add the **SHA-1** and **SHA-256** keys to Firebase:
1. Firebase Console → Project Settings → Your apps → Android
2. Click "Add fingerprint"
3. Paste SHA-1 and SHA-256 values

#### 3. Verify google-services.json

After `flutterfire configure`, check that this file exists:
```bash
ls android/app/google-services.json
```

### iOS Setup

#### 1. Minimum Deployment Target

In `ios/Podfile`:

```ruby
platform :ios, '13.0'
```

#### 2. Install CocoaPods

```bash
cd ios
pod install
cd ..
```

#### 3. Configure Google Sign-In

Add URL schemes to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

Find your `REVERSED_CLIENT_ID` in `ios/Runner/GoogleService-Info.plist`.

#### 4. Verify GoogleService-Info.plist

```bash
ls ios/Runner/GoogleService-Info.plist
```

---

## ▶️ Running the App

### Development Mode

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device_id>

# Run on Chrome (web)
flutter run -d chrome
```

### Build Commands

```bash
# Build Android APK
flutter build apk

# Build Android App Bundle
flutter build appbundle

# Build iOS
flutter build ios
```

---

## 👑 Creating Admin Users

The app uses Role-Based Access Control (RBAC). By default, all users register with the `"user"` role. To create an admin:

### Method 1: Firebase Console (Recommended)

1. **Register** a user normally through the app
2. Go to **Firebase Console** → **Firestore Database**
3. Navigate to `users` collection
4. Find the user document
5. Click on the document
6. Change `role` from `"user"` to `"admin"`
7. Click **Update**
8. User logs out and back in → Now an Admin!

### Firestore Document Structure

```json
{
  "uid": "abc123",
  "email": "admin@example.com",
  "name": "Admin User",
  "role": "admin",    // ← Change this from "user" to "admin"
  "createdAt": "..."
}
```

> **📚 More Details**: See [FIREBASE_SETUP.md](FIREBASE_SETUP.md#step-6-create-an-admin-user)

---

## 🔧 Troubleshooting

### Common Issues

#### ❌ "Firebase app not initialized"

**Solution**: Run `flutterfire configure` to generate `firebase_options.dart`

```bash
flutterfire configure
```

#### ❌ Google Sign-In fails on Android

**Solutions**:
1. Verify SHA-1/SHA-256 are added to Firebase Console
2. Re-download `google-services.json` after adding SHA keys
3. Run `flutter clean && flutter pub get`

#### ❌ Google Sign-In fails on iOS

**Solutions**:
1. Check `GoogleService-Info.plist` exists in `ios/Runner/`
2. Verify URL schemes in `Info.plist`
3. Run `cd ios && pod install`

#### ❌ "Permission denied" in Firestore

**Solutions**:
1. Check user is authenticated
2. Verify Firestore security rules
3. For development, use test mode rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### ❌ Build fails on Android

**Solutions**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### ❌ Build fails on iOS

**Solutions**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

#### ❌ Java not found when running Gradle

**Solution**: Use Android Studio's bundled JDK:

```bash
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
```

Add to `~/.zshrc` or `~/.bashrc` for persistence.

---

## 📚 Additional Resources

| Resource | Link |
|----------|------|
| Flutter Documentation | https://docs.flutter.dev |
| Firebase Flutter Setup | https://firebase.flutter.dev |
| FlutterFire CLI | https://firebase.flutter.dev/docs/cli |
| Provider Package | https://pub.dev/packages/provider |

---

## 📂 Project Documentation

| Document | Description |
|----------|-------------|
| [README.md](README.md) | Project overview |
| [FIREBASE_SETUP.md](FIREBASE_SETUP.md) | Detailed Firebase configuration |
| [docs/PHASE_1_PROJECT_OVERVIEW.md](docs/PHASE_1_PROJECT_OVERVIEW.md) | Architecture overview |
| [docs/PHASE_2_FIREBASE_AUTH_RBAC.md](docs/PHASE_2_FIREBASE_AUTH_RBAC.md) | Auth & RBAC implementation |

---

## ✅ Setup Checklist

Use this checklist to verify your setup:

- [ ] Flutter SDK installed (`flutter doctor` passes)
- [ ] Firebase CLI installed (`firebase --version`)
- [ ] FlutterFire CLI installed (`flutterfire --version`)
- [ ] Repository cloned
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Firebase project created
- [ ] `flutterfire configure` completed
- [ ] `lib/firebase_options.dart` exists
- [ ] Firebase Auth enabled (Email/Password + Google)
- [ ] Firestore Database created
- [ ] SHA keys added (Android)
- [ ] CocoaPods installed (iOS)
- [ ] URL schemes configured (iOS)
- [ ] App runs successfully (`flutter run`)

---

*Last Updated: December 2024*


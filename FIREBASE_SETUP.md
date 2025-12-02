# Firebase Setup Guide for FixIt Now

This guide will walk you through setting up Firebase for the FixIt Now application.

## Prerequisites

1. A Google account
2. Flutter SDK installed
3. Firebase CLI installed (optional but recommended)

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `fixit-now` (or your preferred name)
4. Enable/Disable Google Analytics as preferred
5. Click **"Create project"**

## Step 2: Configure Firebase with FlutterFire CLI (Recommended)

### Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### Configure Firebase

Run this command in your project root:

```bash
flutterfire configure
```

This will:

- Prompt you to select your Firebase project
- Automatically create necessary configuration files
- Generate `lib/firebase_options.dart` with your actual Firebase credentials

### Select Platforms

When prompted, select the platforms you want to support:

- ✅ Android
- ✅ iOS
- ✅ Web (optional)
- ✅ macOS (optional)

## Step 3: Enable Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**:
   - Click on "Email/Password"
   - Toggle "Enable" ON
   - Click "Save"
3. Enable **Google Sign-In**:
   - Click on "Google"
   - Toggle "Enable" ON
   - Add your **Support email**
   - Click "Save"

### For iOS/macOS Google Sign-In

Add the reversed client ID to your iOS configuration:

1. Open `ios/Runner/Info.plist`
2. Add the following (replace with your actual reversed client ID from `GoogleService-Info.plist`):

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    </array>
  </dict>
</array>
<key>GIDClientID</key>
<string>YOUR_CLIENT_ID.apps.googleusercontent.com</string>
```

## Step 4: Set Up Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
4. Select the closest region to your users
5. Click **"Enable"**

### Firestore Security Rules (Development)

For development, use test mode rules:

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

### Firestore Security Rules (Production)

For production, use these more secure rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId;
      allow delete: if false;
    }

    // Tickets collection
    match /tickets/{ticketId} {
      // Anyone authenticated can read tickets
      allow read: if request.auth != null;

      // Users can create tickets with their own UID
      allow create: if request.auth != null
        && request.resource.data.createdByUid == request.auth.uid;

      // Only admins can update tickets
      allow update: if request.auth != null
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';

      // Only admins can delete tickets
      allow delete: if request.auth != null
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## Step 5: Set Up Firebase Storage

1. In Firebase Console, go to **Storage**
2. Click **"Get started"**
3. Choose **"Start in test mode"** (for development)
4. Click **"Next"** and then **"Done"**

### Storage Security Rules (Development)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Step 6: Create an Admin User

Since admin users cannot self-register, you need to manually promote a user to admin:

### Method 1: Firebase Console (Recommended)

1. First, register a normal user through the app
2. Go to Firebase Console → **Firestore Database**
3. Navigate to the `users` collection
4. Find the user document you want to make admin
5. Click on the document
6. Change the `role` field from `"user"` to `"admin"`
7. Click **"Update"**
8. The user should log out and log back in to get admin access

### Method 2: Using Firebase Admin SDK (Advanced)

Create a one-time script to promote users:

```javascript
// admin-script.js (Node.js)
const admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.cert("./serviceAccountKey.json"),
});

const db = admin.firestore();

async function makeAdmin(userEmail) {
  const usersRef = db.collection("users");
  const snapshot = await usersRef.where("email", "==", userEmail).get();

  if (snapshot.empty) {
    console.log("User not found");
    return;
  }

  const userDoc = snapshot.docs[0];
  await userDoc.ref.update({ role: "admin" });
  console.log(`${userEmail} is now an admin`);
}

makeAdmin("your-admin-email@example.com");
```

## Step 7: Android Configuration

### Update `android/app/build.gradle.kts`

Ensure you have the correct minimum SDK version:

```kotlin
android {
    defaultConfig {
        minSdk = 23  // Required for Firebase
        // ...
    }
}
```

### Add SHA-1 and SHA-256 for Google Sign-In

1. Generate SHA keys:

```bash
# Debug SHA-1
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# or for Mac/Linux
cd android && ./gradlew signingReport

or

export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" && cd /Users/sidharthbhunia/development/flutter_projects/fixit/android && ./gradlew signingReport
```

2. Add SHA-1 and SHA-256 to Firebase:
   - Go to Firebase Console → Project Settings
   - Select your Android app
   - Add the SHA-1 and SHA-256 fingerprints

## Step 8: iOS Configuration

### Update iOS Deployment Target

In `ios/Podfile`, ensure minimum deployment target:

```ruby
platform :ios, '13.0'
```

### Update Info.plist for Google Sign-In

Already covered in Step 3.

## Step 9: Run the App

```bash
# Get dependencies
flutter pub get

# Run on Android
flutter run

# Run on iOS
flutter run -d ios

# Run on Web
flutter run -d chrome
```

## Troubleshooting

### "Firebase app not initialized"

Make sure you ran `flutterfire configure` and the `firebase_options.dart` file has correct values.

### Google Sign-In not working on Android

1. Ensure SHA-1 is added to Firebase Console
2. Download latest `google-services.json` and replace in `android/app/`

### Google Sign-In not working on iOS

1. Ensure `GoogleService-Info.plist` is in `ios/Runner/`
2. Add URL schemes to `Info.plist`

### Firestore permission denied

Check that:

1. User is authenticated
2. Security rules allow the operation
3. User has the correct role for admin operations

## Test Users

For testing, create:

1. **Regular User**: Register through the app normally
2. **Admin User**: Register normally, then change `role` to `"admin"` in Firestore

---

## Quick Reference

| Service          | Console Link                        |
| ---------------- | ----------------------------------- |
| Firebase Console | https://console.firebase.google.com |
| Authentication   | Console → Authentication → Users    |
| Firestore        | Console → Firestore Database        |
| Storage          | Console → Storage                   |
| Project Settings | Console → ⚙️ Settings               |

---

**Need Help?**

- [Firebase Flutter Docs](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Google Sign-In Setup](https://firebase.google.com/docs/auth/flutter/federated-auth)

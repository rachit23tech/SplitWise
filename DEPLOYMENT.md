# Splitwise App - Deployment Guide

This guide walks you through deploying the Splitwise Flutter app to Android and Firebase Hosting.

## Prerequisites

- **Firebase CLI**: `npm install -g firebase-tools`
- **Flutter SDK**: Already installed
- **Android SDK**: Required for Android deployment
- **Service Account Key**: Download from Firebase Console
- **Firebase Project**: `my-flutter-splitwise`

---

## Step 1: Set Up Firestore Rules and Indexes

These rules ensure users can only read/write their own documents and payments.

### Deploy Rules & Indexes

```bash
cd c:\Users\arora\Desktop\SplitWise
firebase login
firebase deploy --only firestore:rules,firestore:indexes
```

**What this does:**
- Deploys `firestore.rules` (access control)
- Deploys `firestore.indexes.json` (composite indexes for queries)

---

## Step 2: Seed Sample Data (Optional)

Populate Firestore with sample users, expenses, and payments for testing.

### Setup

1. **Download Service Account Key**
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save as `service-account-key.json` in the project root

2. **Set Environment Variable**
   ```powershell
   # Windows PowerShell
   $env:GOOGLE_APPLICATION_CREDENTIALS="C:\Users\arora\Desktop\SplitWise\service-account-key.json"
   ```

3. **Run Seed Script**
   ```bash
   cd c:\Users\arora\Desktop\SplitWise
   dart tool/seed_firestore.dart
   ```

**Sample data created:**
- 3 users (Alice, Bob, Charlie)
- 2 expenses with custom per-person splits
- 1 sample payment (for testing settlement)

---

## Step 3: Deploy to Firebase Hosting (Web)

Deploy the web production build to Firebase Hosting.

### Build & Deploy

```bash
cd c:\Users\arora\Desktop\SplitWise

# Build web production bundle
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

**Your web app will be live at:** `https://my-flutter-splitwise.web.app`

---

## Step 4: Deploy to Android

Build and deploy the Android app to real devices.

### Prerequisites Check

- Verify package name in `android/app/build.gradle.kts` matches Firebase:
  ```kotlin
  namespace = "com.rachit.splitwise.splitwise"
  ```
- Ensure `android/app/google-services.json` is present

### Build & Deploy

```bash
cd c:\Users\arora\Desktop\SplitWise

# Connect Android device via USB (enable Developer Mode)

# Build APK
flutter build apk --release

# Install on device
flutter install
```

**APK location:** `build/app/outputs/apk/release/app-release.apk`

Or use Android Studio to deploy directly.

---

## Step 5: Verify Deployment

### Web Testing
1. Open `https://my-flutter-splitwise.web.app`
2. Register with test account: `testuser@example.com / password`
3. Add expense, view balances

### Android Testing
1. Launch app on connected device
2. Register/login
3. Test expense creation and settlement features

---

## Troubleshooting

### "Service Account Key not found"
- Ensure `service-account-key.json` is in project root
- Verify `GOOGLE_APPLICATION_CREDENTIALS` env var is set correctly

### "Permission denied" in Firestore
- Re-deploy rules: `firebase deploy --only firestore:rules`
- Check Firestore rules allow your user UID

### App can't connect to Firestore
- Verify Firebase project ID in `lib/firebase_options.dart`
- Check Google Services plugin is installed: `flutter pub get`

### Web build fails
- Run `flutter clean` then `flutter build web --release`
- Ensure web platform is enabled: `flutter config --enable-web`

---

## Rollback Instructions

If something goes wrong:

```bash
# Revert Firestore rules to previous version
firebase deploy --only firestore:rules --force

# Redeploy only hosting
firebase deploy --only hosting
```

---

## Monitoring

### View Firestore Usage
- Firebase Console → Firestore → Usage
- Monitor for unusual spikes in read/write operations

### View Web Logs
- Firebase Console → Hosting → Deployments
- Check deployment history and rollback if needed

### View App Crash Reports
- Firebase Console → Crash Reporting
- Monitor for production issues

---

## Notes

- **Staging**: Use `firebase-dev` project for testing before production
- **Data Backups**: Firestore auto-backups; no manual action needed
- **Scaling**: App scales automatically with Firestore; no server maintenance required


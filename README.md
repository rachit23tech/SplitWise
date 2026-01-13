# SplitWise (Flutter)

This is a minimal SplitWise-like app built with Flutter and Firebase (Auth + Firestore).

Features implemented:
- Firebase Authentication (email)
- Firestore `users` and `expenses` collections
- Per-item splitting with optional per-person custom shares
- View your total spent, owed, and net balance

Setup
1. Install Flutter and the FlutterFire CLI (optional).
2. Add Firebase config files for platforms (Android `google-services.json`, iOS `GoogleService-Info.plist`) or run `flutterfire configure`.
3. Run:

```bash
flutter pub get
flutter run
```

Notes
- Ensure Firestore rules allow read/write for authenticated users while testing.
- The app stores participant identifiers as emails when available; for production you may want to use stable UIDs and a contacts/group UX.

Next improvements
- Add contact/group management UI
- Improve UI/UX, localization, currency formatting (already added `intl`)
- Add payments settlement flows and notifications

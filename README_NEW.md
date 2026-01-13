# Splitwise - Expense Sharing App

A full-featured expense-sharing app built with **Flutter** and **Firebase**.

## Features

✅ **User Authentication**
- Firebase Auth (email/password)
- Automatic user profile creation

✅ **Expense Management**
- Create expenses with multiple participants
- Per-item splitting with equal or custom per-person shares
- View expense history with dates and amounts

✅ **Balance Tracking**
- Real-time summary: Total Spent, Total Owed, Sent, Received, Net
- See who owes you and what you owe others
- Currency formatting (USD)

✅ **Settlement Payments**
- Record payments between users
- Track payment history
- Settle up with one-click payment recording

✅ **Platforms**
- **Android**: Native deployment ready
- **Web**: Live demo at `https://my-flutter-splitwise.web.app`

## Tech Stack

- **Frontend**: Flutter 3.9 (Dart)
- **Backend**: Firebase (Auth + Firestore)
- **Architecture**: Layered (Models → Services → UI)
- **Formatting**: `intl` package for currency/dates

## Project Structure

```
lib/
├── main.dart                 # App entry point, Firebase init
├── models/
│   ├── app_user.dart         # User model
│   ├── expense.dart          # Expense with per-person shares
│   └── payment.dart          # Payment/settlement record
├── services/
│   ├── auth_service.dart     # Firebase Auth
│   ├── user_service.dart     # User lookups
│   ├── expense_service.dart  # CRUD + aggregation
│   ├── payment_service.dart  # Payment records
│   └── summary_service.dart  # Unified balance summary
└── screens/
    ├── login_screen.dart     # Email/password login
    ├── register_screen.dart  # New user registration
    ├── home_screen.dart      # Dashboard with balances
    ├── add_expense_screen.dart # Participant picker + splits
    └── settle_up_screen.dart # Payment recording
```

## Local Development

### Prerequisites
- Flutter 3.9+
- Dart 3.5+
- Firebase project with Auth & Firestore enabled

### Setup

```bash
# 1. Install dependencies
flutter pub get

# 2. Configure Firebase (if not already done)
flutterfire configure

# 3. Run on connected device/emulator
flutter run

# 4. Or run on web (localhost:8080)
flutter run -d chrome
```

## Deployment

See **[DEPLOYMENT.md](DEPLOYMENT.md)** for complete instructions on:
- Deploying Firestore rules
- Seeding sample data
- Publishing to Firebase Hosting (Web)
- Building for Android

**Quick Start:**
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules,firestore:indexes

# Seed sample data
dart tool/seed_firestore.dart

# Deploy web hosting
flutter build web --release
firebase deploy --only hosting
```

## Firestore Schema

### Collections

**users** (document ID = user UID)
```json
{
  "uid": "user123",
  "email": "user@example.com",
  "displayName": "Alice"
}
```

**expenses** (auto-generated document ID)
```json
{
  "title": "Dinner",
  "amount": 60.0,
  "payerId": "user123",
  "participants": ["alice@example.com", "bob@example.com"],
  "shares": {
    "alice@example.com": 30.0,
    "bob@example.com": 30.0
  },
  "timestamp": 1698765432000
}
```

**payments** (auto-generated document ID)
```json
{
  "fromUser": "user123",
  "toUser": "user456",
  "amount": 20.0,
  "note": "Lunch reimbursement",
  "timestamp": 1698765432000
}
```

## Testing

```bash
# Run unit tests
flutter test

# Generate coverage report
flutter test --coverage
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Permission denied" in Firestore | Deploy rules: `firebase deploy --only firestore:rules` |
| App can't load users | Verify Firebase project ID in `lib/firebase_options.dart` |
| Web build fails | Run `flutter clean && flutter build web --release` |

## Future Improvements

- [ ] Group expense splitting
- [ ] Push notifications for payments
- [ ] Expense categories and filtering
- [ ] Dark mode
- [ ] Offline support
- [ ] Multiple currencies

## License

MIT

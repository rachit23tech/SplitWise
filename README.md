# SplitWise
An expense-splitting app developed in Flutter using Firebase for authentication and real-time data—designed to manage group spending efficiently
Splitwise Clone – Flutter App

A mobile application built using Flutter that helps users manage group expenses, split bills, and track who owes whom. This app simplifies shared spending for friends, trips, roommates, and college groups.

🚀 Features

👥 Group Management – Create and manage groups for trips, hostels, or friends

➗ Expense Splitting – Split bills equally or unequally among members

🧾 Expense Tracking – Add, view, and manage all group expenses

📊 Balance Summary – See who owes whom in real time

🔐 User Authentication – Secure login & signup

☁️ Cloud Sync – Real-time updates using Firebase (if applicable)

🛠 Tech Stack

Frontend: Flutter (Dart)

Backend / Database: Firebase Firestore

Authentication: Firebase Auth

Platform: Android (iOS support possible)
⚙️ Installation & Setup
1️⃣ Prerequisites

Make sure you have the following installed:

Flutter SDK

Android Studio / VS Code

Firebase CLI (if using Firebase)

2️⃣ Clone the Repository
git clone https://github.com/rachit23tech/splitwise-flutter.git
cd splitwise-flutter

3️⃣ Install Dependencies
flutter pub get

4️⃣ Configure Firebase

Create a Firebase project

Enable Authentication and Firestore Database

Download google-services.json and place it inside:

android/app/


Run:

flutterfire configure

5️⃣ Run the App
flutter run

📂 Project Structure
lib/
│── main.dart
│── screens/
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── group_screen.dart
│   └── add_expense_screen.dart
│── services/
│   ├── auth_service.dart
│   └── database_service.dart
│── models/
│   └── expense_model.dart

🧠 How It Works

Users sign in using email authentication

Create or join a group

Add expenses and select who paid and how it is split

App calculates balances automatically

Users can view settlements and outstanding amounts

🎯 Use Cases

College friend groups

Roommates sharing rent & groceries

Trips and travel expenses

Hackathons & project collaborations

📌 Future Enhancements

💳 Payment integration (UPI/Stripe)

📈 Expense analytics & charts

🌙 Dark mode

📤 Export reports (PDF/CSV)

🔔 Push notifications

👨‍💻 Author

Rachit Arora
2nd Year Engineering Student | Flutter & Full-Stack Developer
📍 India

⭐ Support

If you found this project helpful:

Give it a ⭐ on GitHub

Share it with friends

Use it in your projects or hackathons

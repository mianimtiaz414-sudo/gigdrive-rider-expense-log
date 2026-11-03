#### GigDrive: Rider Expense Log 🛵📊

[](/url?sa=i&source=web&rct=j&url=https://flutter.dev&ved=2ahUKEwjqlbjP2uyXAxUf_7sIHczpBkUQg5wRegkIAggBCJEGEAg&opi=89978449&cd&psig=AOvVaw2bokXgb9fkQYFnGQsQMm41&ust=1793826507549000)
[](/url?sa=i&source=web&rct=j&url=https://firebase.google.com&ved=2ahUKEwjqlbjP2uyXAxUf_7sIHczpBkUQg5wRegkIAggBCJEGEAk&opi=89978449&cd&psig=AOvVaw2bokXgb9fkQYFnGQsQMm41&ust=1793826507549000)
[](/url?sa=i&source=web&rct=j&url=https://pub.dev/packages/hive&ved=2ahUKEwjqlbjP2uyXAxUf_7sIHczpBkUQg5wRegkIAggBCJEGEAo&opi=89978449&cd&psig=AOvVaw2bokXgb9fkQYFnGQsQMm41&ust=1793826507549000)
[]() 

**GigDrive** is a minimalist, professional, and feature-rich daily utility application designed specifically for gig economy workers, delivery riders, and rideshare drivers (Uber, Bykea, Foodpanda, Careem, Indrive, InDrive, Amazon Flex). It empowers riders to efficiently log their daily earnings, fuel costs, vehicle repairs, maintenance expenses, and mileage to understand their **True Net Profit**. 

"Know Your Earnings. Track Your Real Profit." 📈 

#### 🚀 Key Features

* **Smart Financial Ledger:** Seamlessly log daily income, cash inflow, fuel expenses, and bike/car maintenance costs.
* **Offline-First Architecture:** Full application capability works entirely offline using a lightning-fast localized NoSQL Hive Database. Perfect for riders with unstable network connections.
* **Secure Cloud Sync:** Quick authentication using **Google Sign-In** or Email. Synchronize data effortlessly across multiple accounts with multi-tenant Firebase protection.
* **Professional PDF Export:** Generate fully detailed, offline-compiled financial summaries formatted for A4 layout, grouped by month with dynamic totals and structured formatting.
* **Cross-Account Protection:** Automatic pre-flight data upload on logout and device cache purge to prevent corporate or multi-driver data collision.
* **Biometric/PIN Security Pad:** Robust 4-digit localized lock screen system protecting the host ledger from unauthorized app bypass.
* **Zero UI Overflows:** Fully responsive layouts with keyboard auto-resize (resizeToAvoidBottomInset) and overflow-capped visual widgets.

#### 🛠️ Tech Stack & Architecture

* **Frontend Framework:** Flutter (Dart VM)
* **State Management:** GetX (Reactive State, Dependency Injection, and Named Routing)
* **Local Storage:** Hive NoSQL & SharedPreferences
* **Backend Cloud Infrastructure:** Firebase Authentication & Cloud Firestore
* **Reporting Utility:** Pdf & Printing compilers

#### 📦 Project Directory Layout

text

lib/
├── bindings/         # GetX Dependency injection bindings
├── core/             # Application styles, themes, and global constants
├── data/
│   ├── local/        # Hive config, SharedPrefs, PDF Reporting Service
│   ├── models/       # Expense and Data serialization schemas
│   └── remote/       # Firebase Authentication & Firestore services
├── routes/           # Decoupled App Navigation Route descriptors
├── view_models/      # Clean Architecture MVVM Controller logic layers
└── views/            # Responsive UI Components, Widgets, and Screens

Use code with caution.

#### ⚙️ Development & Build Setup

#### Prerequisites

* Flutter SDK >=3.4.0 <4.0.0
* Android API Level 24+ (minSdk 23 verified)

#### 1. Installation

Clone the repository and fetch the active plugin dependencies: 

bash

git clone https://github.com/yourusername/rider_expense_tracker.git
cd rider_expense_tracker
flutter pub get

Use code with caution.

#### 2. Assets & Icon Generation

Ensure your high-resolution asset logo app_icon.png is placed under the /assets directory, then re-compile launcher icons: 

bash

dart run flutter_launcher_icons

Use code with caution.

#### 3. Production Compilation (AAB Bundle)

To generate the release application bundle optimized for Google Play Console distribution: 

bash

flutter build appbundle --release

Use code with caution.

#### 🛡️ Privacy & Data Security

GigDrive respects user data privacy. Financial sheets are maintained directly inside the host device storage. Cloud backup processing strictly utilizes official Google Firebase API channels, ensuring absolute transparency. No user behavioral datasets or individual ledger metrics are transmitted to any external third-party agencies. 

#### 📄 License

This project is proprietary software. All distribution, modification, or commercial platform release rights are strictly reserved by the application owner.
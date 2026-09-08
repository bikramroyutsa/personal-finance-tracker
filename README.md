# Personal Finance Tracker 💰

A modern, offline-first personal finance and debt management application built with Flutter. Keep track of your daily expenses, analyze spending trends, manage debts, and log expenses anywhere on Android using the quick floating assistant.

[![Download APK](https://img.shields.io/badge/Download-Release%20APK-brightgreen?logo=android&style=for-the-badge)](https://github.com/bikramroyutsa/personal-finance-tracker/releases/latest)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&style=for-the-badge)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

---

## ✨ Key Features

### 📊 1. Home Dashboard & Spending Sliders
- **Today & This Month Budgets:** Color-coded budget tracking cards with dynamic progress sliders comparing current spend vs. daily and monthly max limits.
- **Dynamic Limit Alerts:** Color adapts automatically: Green (<80%), Amber (80-100%), and Red (>100% over budget).
- **Date Navigation & Daily Breakdown:** Navigate forward and backward across days or jump back to today with instant categorized transaction breakdowns.

### 🕒 2. History, Logs & Analytics
- **Powerful Custom Date Filters:**
  - **Presets:** *This Month*, *Last Month*, *This Year*, *Last 7 Days*, *Last 30 Days*.
  - **Custom N Days:** View arbitrary periods (e.g., last 14, 45, 90 days).
  - **Specific Month & Year:** Interactive month stepper (`< Prev / Next >`) and year-grid selector.
  - **Custom Date Range:** Select custom start and end dates with a calendar picker.
- **Log Management:** Swipe-to-delete or tap the delete button on any log entry with instant confirmation dialogs.
- **Analytics & Comparisons:** Categorical spending pie charts, monthly bar trends, and side-by-side period comparison views.

### 👥 3. Lent & Borrowed Debt Tracker
- Track money you've **Lent** to friends/colleagues or **Borrowed**.
- Mark debts as **Pending** or **Settled** with a single tap.
- View total unsettled lent/borrowed amounts and individual transaction notes.

### 💬 4. Android Floating Overlay Assistant
- Quick-access floating chat-head bubble to log transactions without interrupting your workflow or switching apps.
- Expand to enter amounts, select categories, and add notes.
- Collapses seamlessly into a draggable, non-intrusive floating bubble.

### 📁 5. Data Export, Import & Management
- **Excel (.xlsx) Export:** Structured monthly spreadsheet tabs with daily expense rows and totals.
- **CSV Export & Import:** Full backup and restore support with automatic category mapping and reactive UI refresh.
- **Category Customization:** Create, edit, and organize custom categories and subcategories with custom Lucide icons.
- **Privacy First & 100% Offline:** All data is stored locally on your device via SQLite. No account or internet connection required.

---

## 📲 Download & Installation

Download the optimized APK for your device from the [GitHub Releases](https://github.com/bikramroyutsa/personal-finance-tracker/releases/latest) page:

| File | Size | Which one should I download? |
| :--- | :--- | :--- |
| **`app-arm64-v8a-release.apk`** | **~19 MB** | ⭐ **Recommended for 99% of smartphones** (Modern 64-bit Android devices: Snapdragon, Helio, Dimensity, Exynos, Tensor). |
| **`app-armeabi-v7a-release.apk`** | **~18 MB** | Older 32-bit legacy Android phones (older devices pre-2017). |
| **`app-x86_64-release.apk`** | **~20 MB** | PC Android emulators (e.g. BlueStacks, LDPlayer, Android Studio on PC). |
| **`app-release.apk`** | **~56 MB** | Universal "all-in-one" build (works on every device). |

### Installation:
1. Download the matching `.apk` file for your device above.
2. Open and tap install on your Android device (enable *"Install from unknown sources"* if prompted).

---

## 🛠️ Tech Stack & Dependencies

- **Framework:** [Flutter](https://flutter.dev) (Dart)
- **Local Database:** [SQLite (`sqflite`)](https://pub.dev/packages/sqflite)
- **Floating Overlay:** [flutter_overlay_window](https://pub.dev/packages/flutter_overlay_window)
- **Spreadsheets & Data:** [excel](https://pub.dev/packages/excel), [csv](https://pub.dev/packages/csv), [file_picker](https://pub.dev/packages/file_picker)
- **Typography & Icons:** [Google Fonts (Inter)](https://pub.dev/packages/google_fonts), [Lucide Icons](https://pub.dev/packages/lucide_icons)
- **Charts:** [fl_chart](https://pub.dev/packages/fl_chart)

---

## 🚀 Getting Started (Development)

### Prerequisites
- Flutter SDK (v3.0 or higher)
- Android Studio / VS Code with Flutter extension
- Android device or emulator (Android 7.0+ recommended)

### Setup & Run
```bash
# 1. Clone the repository
git clone https://github.com/bikramroyutsa/personal-finance-tracker.git
cd personal-finance-tracker

# 2. Install dependencies
flutter pub get

# 3. Run the app in debug mode
flutter run

# 4. Build release APK
flutter build apk --release
```

---

## 📄 License

This project is licensed under the MIT License.

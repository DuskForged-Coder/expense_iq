# ExpenseIQ 📊

A premium offline-first personal finance Android app built with **Flutter** to track expenses, manage budgets, set savings goals, and capture receipts using ML Kit OCR.

---

## 🌟 Features

- **Expense Tracking**: Log income and expenses with categories and tags
- **Budgets**: Set monthly/weekly budgets and get notified when approaching limits
- **Savings Goals**: Create and track progress toward financial goals
- **Receipt OCR**: Scan receipts with Google ML Kit to automatically extract totals and merchant info
- **Smart Reports**: Generate beautiful PDF, Excel, and CSV summaries with fl_chart visualizations
- **Offline-First**: All data stored locally with encrypted security
- **Cross-Platform Material Design 3**: Beautiful UI on Android

---

## 🛠️ Tech Stack

[![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Android-848484?style=for-the-badge&logo=android)](https://developer.android.com)

---

## 📱 Screenshots

| | |
|---|---|
| <img src="https://via.placeholder.com/300x500.png?text=Expense+Tracking" width="200"/> | <img src="https://via.placeholder.com/300x500.png?text=Budget+Management" width="200"/> |
| <img src="https://via.placeholder.com/300x500.png?text=Receipt+OCR" width="200"/> | <img src="https://via.placeholder.com/300x500.png?text=Reports" width="200"/> |

---

## 🚀 Getting Started

Follow these steps to get the app running locally:

```sh
# 1. Clone the repository
git clone https://github.com/your-username/expense_iq.git
cd expense_iq

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
# - Create a Firebase project
# - Enable Email/Password and Google authentication
# - Enable Cloud Firestore, Firebase Storage, and Cloud Messaging
# - Run: flutterfire configure

# 4. Run the app
flutter run
```

---

## 📊 Smart Reports

ExpenseIQ generates **smart, beautiful reports** with:

- **PDF reports**: Well-formatted financial summaries
- **Excel export**: Data that can be opened in Excel/Google Sheets
- **CSV export**: Compatible with any data analysis tool
- **Charts & Graphs**: Visual spending trends using `fl_chart`
- **Category breakdown**: See where your money goes
- **Monthly/Yearly trends**: Track progress over time

---

## 📦 Available Scripts

| Command | Description |
|---|---|
| `flutter pub get` | Install dependencies |
| `flutter analyze` | Run static analysis |
| `flutter test` | Run unit/integration tests |
| `flutter build apk --release` | Build release APK |
| `flutterfire configure` | Configure Firebase settings |

---

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

--- 

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

--- 

**Made with ❤️ using Flutter and Dart**

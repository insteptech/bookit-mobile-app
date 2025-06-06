
# 📱 Bookit Mobile App

Bookit is a Flutter-based mobile application designed to allow users to book wellness, fitness, and beauty services seamlessly. This app is built with scalability, modularity, and enterprise-grade architecture in mind.

---

## 📦 Features

- ✅ Modular Folder Architecture (Core, App, Features, Shared)
- 🎨 Dynamic Light/Dark Theme Support
- 🌍 Internationalization with Multi-language Support
- 🔐 Authentication Module
- ♻️ Reusable Component Library
- 📡 Service Layer with Network, Logger, and Sync Integration
- 🧪 Unit and Widget Testing (Setup Recommended)
- 🧭 Route Management with Centralized Router
- ☁️ Configurable for Future Firebase & API Integrations

---

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/bookitapp-aicha/bookit_mobile_app.git
cd bookit_mobile_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App
```bash
flutter run
```

---

## 📁 Folder Structure

```
lib/
├── main.dart
├── bootstrap.dart
├── app/              # Theme, Localization, Routing
├── core/             # Services like Logger, Network
├── features/         # Feature modules (e.g., Auth)
├── shared/           # Reusable components
├── assets/           # Fonts, images
```

---

## 🧪 Testing

To run all tests:

```bash
flutter test
```

> Integration testing setup and GitHub Actions CI pipeline coming soon.

---

## 🧱 Tech Stack

- Flutter 3.x
- Provider (State Management)
- SharedPreferences
- Modular Architecture
- Internationalization

---

## 📌 Future Improvements

- 🔄 Replace Provider with Riverpod for better scalability
- 🧪 Add widget and integration tests
- 📲 CI/CD via GitHub Actions
- 💬 Real-time notifications and deep linking

---

## 👨‍💻 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss.

---

## 📜 License


# 📚 EduLink

A Flutter-based classroom management application inspired by Google Classroom. EduLink streamlines academic collaboration by allowing Class Representatives to create classrooms and manage academic content while students stay organized and notified.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.32.8-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
[![GetX](https://img.shields.io/badge/State%20Management-GetX-purple.svg)](https://pub.dev/packages/get)

---

## ✨ Features

### 🎓 Classroom Management
- **Create Classrooms:** Class Representatives can create classrooms and receive unique class codes
- **Join Classrooms:** Students join using class codes
- **Multiple Classrooms:** Users can participate in multiple classrooms simultaneously

### 👨‍🏫 Admin (Class Representative) Capabilities
- Post **Notices** for announcements and updates
- Assign **Tasks/Assignments** with deadlines
- Schedule **Class Tests** and **Presentations**
- Share **Class Routines** and schedules
- Real-time updates to all classroom members

### 👨‍🎓 Student Features
- View all notices, tasks, and routines
- Mark tasks as **completed** or **incomplete**
- Track personal task completion status
- Filter and view completed vs. uncompleted tasks
- Receive real-time notifications

### 🔔 Notifications
- **Firebase Cloud Messaging** for push notifications
- Instant alerts for new notices and tasks
- Local notifications support

### 🔐 Authentication & Security
- Google Sign-In integration via Firebase Authentication
- Secure user data management
- Persistent authentication with SQLite local storage

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter 3.32.8** | Cross-platform UI framework |
| **Firebase Auth** | User authentication |
| **Cloud Firestore** | Real-time database |
| **Firebase Cloud Messaging** | Push notifications |
| **SQLite** | Local data persistence |
| **GetX** | State management & routing |
| **MVVM Architecture** | Clean code structure |

---

## 📦 Key Dependencies

```yaml
dependencies:
  # State Management & Navigation
  get: ^4.7.2
  
  # Firebase Services
  firebase_core: ^4.2.0
  firebase_auth: ^6.1.1
  cloud_firestore: ^6.0.3
  firebase_messaging: ^16.0.3
  
  # Authentication
  google_sign_in: ^5.4.2
  
  # Local Storage
  sqflite: ^2.4.2
  path_provider: ^2.1.5
  path: ^1.9.1
  
  # Notifications
  flutter_local_notifications: ^19.5.0
  timezone: ^0.10.1
  
  # Utilities
  connectivity_plus: ^7.0.0
  intl: ^0.20.2
  flutter_linkify: ^6.0.0
  url_launcher: ^6.3.2
  url_launcher_android:
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.32.8 or higher
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Firebase project with Authentication, Firestore, and Cloud Messaging enabled
- Google account for Firebase Console access

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Abir-Al-Murad/EduLink-App.git
   cd EduLink-App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable **Authentication** (Google Sign-In provider)
   - Enable **Cloud Firestore**
   - Enable **Cloud Messaging**
   
   **For Android:**
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/`
   
   **For iOS:**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place it in `ios/Runner/`

4. **Run the app**
   ```bash
   flutter run
   ```

---

**Architecture:** Clean Architecture with MVVM pattern
- **Feature-based structure** for better scalability
- **Data layer:** Models and data sources
- **Presentation layer:** Screens, Controllers (GetX), and Widgets
- **Separation of concerns** for maintainable code

---

## 👥 User Roles

### Admin (Class Representative)
- Create classrooms
- Post notices, tasks, tests, presentations, and routines
- Manage classroom content
- Generate and share class codes

### Student
- Join classrooms using class codes
- View all classroom content
- Mark tasks as complete/incomplete
- Track personal task progress
- Receive notifications for updates

---

## 📱 Core Functionalities

### Creating a Classroom
1. Admin logs in with Google
2. Creates a new classroom
3. Receives a unique class code
4. Shares code with students

### Joining a Classroom
1. Student logs in with Google
2. Enters class code
3. Joins classroom instantly
4. Starts receiving notifications

### Task Management
- Students can mark any task as **completed**
- View **completed tasks** separately
- View **uncompleted tasks** for pending work
- Track progress across multiple classrooms

---

## 🔔 Notification System

EduLink uses Firebase Cloud Messaging to send real-time notifications when:
- ✅ New notice is posted
- ✅ New task/assignment is added
- ✅ Class test is scheduled
- ✅ Routine is updated
- ✅ Presentation is announced

---

## 🗄️ Data Storage

- **Firestore:** Real-time sync for classrooms, notices, tasks, routines
- **SQLite:** Local storage for authentication data and offline cache
- **Firebase Auth:** Secure user authentication and session management

---

## 🔮 Future Roadmap

- [ ] **Full Offline Mode:** Complete offline functionality with sync
- [ ] Additional notification types and customization
- [ ] Enhanced analytics for admins
- [ ] File attachment support for tasks
- [ ] In-app messaging between users
- [ ] Calendar view for routines and deadlines

---

## ⚠️ Known Limitations

- **Offline mode** is currently basic and under development
- Full offline support for all features coming soon

---

## 🤝 Contributing

Contributions are welcome! If you'd like to contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 👨‍💻 Developer

**Abir Al Murad**

- GitHub: [@Abir-Al-Murad](https://github.com/Abir-Al-Murad)
- Project Link: [EduLink-App](https://github.com/Abir-Al-Murad/EduLink-App)

---

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on [GitHub Issues](https://github.com/Abir-Al-Murad/EduLink-App/issues)
- Contact the developer through GitHub

---

## 🙏 Acknowledgments

- Inspired by Google Classroom
- Built with Flutter and Firebase
- State management powered by GetX
- Icons and design inspired by Material Design

---

<div align="center">
  <p>Made with ❤️ for better education management</p>
  <p>⭐ Star this repo if you find it helpful!</p>
</div>

# FII Smart - CS Quiz App

A comprehensive Flutter application for computer science education featuring quizzes, progress tracking, and AI-powered content generation.

## Features

- 🧠 Interactive CS quizzes (Data Structures, Algorithms, etc.)
- 📊 Progress tracking and statistics
- 🤖 AI-powered question generation using Google Gemini
- 👤 User profiles and authentication
- 📱 Modern Material Design UI
- 🔥 Firebase backend integration

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Firebase account
- Google AI Studio account (for Gemini API)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/iFlavian02/FII-Smart.git
   cd FII-Smart
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API Keys:**
   - Copy `lib/utils/constants.dart.template` to `lib/utils/constants.dart`
   - Replace `YOUR_GEMINI_API_KEY_HERE` with your actual Gemini API key from Google AI Studio

4. **Configure Firebase:**
   - Create a new Firebase project
   - Add Android app to your Firebase project
   - Download `google-services.json` and place it in `android/app/`
   - Enable Authentication, Firestore, and Storage in Firebase Console

5. **Run the app:**
   ```bash
   flutter run
   ```

### Building for Release

```bash
flutter build apk --release
```

## Project Structure

```
lib/
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── services/        # Backend services
├── utils/           # Utilities and constants
└── widgets/         # Reusable UI components
```

## Technologies Used

- **Flutter** - Cross-platform mobile development
- **Firebase** - Backend services (Auth, Firestore, Storage)
- **Google Gemini AI** - AI-powered content generation
- **Provider** - State management
- **Material Design** - UI/UX design system

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.


# Project Overview

This is a Flutter quiz application designed for computer science students. The app allows users to test their knowledge on various CS topics by taking quizzes. It utilizes Firebase for backend services such as authentication, data storage (Firestore), and file storage. A key feature of this app is its ability to dynamically generate quizzes from user-uploaded notes or default lesson content using the Gemini API.

## Main Technologies

*   **Frontend:** Flutter
*   **Backend:** Firebase (Authentication, Firestore, Storage)
*   **AI:** Google Gemini API (for quiz generation)
*   **State Management:** Provider
*   **UI:** Material Design, with animations and custom components.

## Architecture

The project follows a clean architecture, separating concerns into the following directories:

*   `lib/models`: Contains the data models for the application (e.g., `Quiz`, `User`).
*   `lib/providers`: Holds the business logic and state management using the Provider package (e.g., `QuizProvider`, `AuthProvider`).
*   `lib/screens`: Contains the UI for different screens of the app (e.g., `HomeScreen`, `QuizScreen`).
*   `lib/services`: Includes services that interact with external APIs, such as the Gemini API.
*   `lib/widgets`: Contains reusable UI components.

# Building and Running

To build and run this project, you will need to have the Flutter SDK installed and a Firebase project set up.

1.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

2.  **Run the App:**
    ```bash
    flutter run
    ```

## Testing

The project includes a `test` directory with a `widget_test.dart` file. To run the tests, use the following command:

```bash
flutter test
```

# Development Conventions

*   **State Management:** The project uses the Provider package for state management. All business logic should be handled in the provider classes.
*   **Styling:** The app uses a custom theme defined in `lib/utils/app_theme.dart`. All UI components should adhere to this theme.
*   **Firebase:** All interactions with Firebase are handled in the provider classes.
*   **Gemini API:** The `lib/services/gemini_service.dart` file contains the logic for interacting with the Gemini API. All quiz generation requests should go through this service.

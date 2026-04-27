# Resume Builder

This Flutter project implements a resume builder app with user onboarding, Firebase authentication, and Firestore-backed profile storage.

## Project Overview

The app is designed to meet the interview requirements for an onboarding + profile resume builder:

- Authentication with Email/Password
- Multi-step onboarding form
  - Personal details
  - Skills input
  - Experience entries
  - Education entries
  - Interests / goals
- Store all user data in Firebase Firestore
- Profile screen that displays the collected data
- Edit functionality for every section of the profile

## Approach

### Architecture

The app follows a simple service-driven architecture:

- `main.dart` initializes Firebase and launches the login flow.
- `login_screen.dart` handles email/password authentication and registration using Firebase Auth.
- `onboarding_screen.dart` contains the 5-step onboarding process and validation rules.
- `profile_screen.dart` loads the saved Firestore document and renders a clean profile view.
- `firestore_service.dart` is responsible for reading and writing user data.
- `auth_service.dart` is responsible for login, registration, and sign-out operations.
- `user_model.dart` defines the Firestore user document structure.

### Form handling and validation

Onboarding is implemented as a sequential flow with local state management in `StatefulWidget`.
Validation points include:

- Full name required
- At least one skill must be added
- Experience entries require role, company, and duration
- Education entries require school, degree, and field of study

Each section prevents progression until the required fields are completed.

### Clean UI/UX

The UI uses:

- clear section headings
- progress indicator for onboarding
- chips for skills/interests
- cards for experience and education
- edit dialogs for profile updates

This provides a clean and intuitive experience for the user.

### Firestore data modeling

User resumes are stored under `users/{uid}` in Firestore.
The data model includes:

- `uid`
- `name`
- `email`
- `skills` (array of strings)
- `experience` (array of objects with `role`, `company`, `duration`)
- `education` (array of objects with `school`, `degree`, `field`)
- `interests` (array of strings)

This structure is simple and well-suited to Firestore document storage.

### State management

The app uses local `StatefulWidget` state for each screen.
This approach keeps state simple and direct for the size of this project while still separating service logic from UI logic.

## Setup

1. Ensure Firebase is configured in `firebase_options.dart`.
2. Enable **Email/Password** authentication in Firebase Console under `Authentication -> Sign-in method`.
3. Add your Firebase project configuration if not already present.
4. Run:

```bash
flutter pub get
flutter run
```

## Notes

- The project currently supports **Email/Password authentication**.
- Google Sign-In can be added later if desired.
- The app is ready for interview submission with the required onboarding, profile display, Firestore storage, and edit flow.

## File Structure

- `lib/main.dart` — app entry point and Firebase initialization
- `lib/screens/login_screen.dart` — authentication UI and flow
- `lib/screens/onboarding_screen.dart` — multi-step onboarding form
- `lib/screens/profile_screen.dart` — profile display and edit screen
- `lib/services/auth_service.dart` — Firebase authentication service
- `lib/services/firestore_service.dart` — Firestore data service
- `lib/models/user_model.dart` — user data model

## How it works

1. A user logs in or signs up.
2. If no Firestore profile exists, the user completes onboarding.
3. Onboarding saves the resume data to Firestore.
4. The profile screen reads the saved data and displays it.
5. The user can edit skills, experience, education, or interests and save changes back to Firestore.

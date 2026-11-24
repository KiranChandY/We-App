# WE · Where Events Come Alive

A cross-platform Flutter app for sharing event photos. Hosts create events, add members, and assign photos to the people in them, so everyone ends up with the pictures they're actually in.

---

## ✨ Features

- **Authentication.** Email sign up, login and password reset, plus Google and Apple sign-in, powered by Firebase Auth.
- **Events.** Create events, view event details and manage the members of each event.
- **Photo assignment.** Pick photos and assign them to specific members, with validation (for example, a photo can't be assigned twice).
- **Photo review.** A review screen for checking assigned photos.
- **Profile and settings.** Edit account, notifications, language, FAQ, help and support, and about screens.

## 🛠 Built with

| Area | Tools |
|---|---|
| Framework | Flutter, Dart (iOS, Android, web, desktop targets) |
| Backend | Firebase Core, Firebase Auth, Google Sign-In, Sign in with Apple |
| State | Provider |
| Device | camera, image_picker, photo_manager, share_plus, url_launcher |
| Storage | flutter_secure_storage, shared_preferences |

## 📁 Structure

```
lib/
  main.dart
  providers/auth_provider.dart   # auth state (Provider)
  services/auth_service.dart     # Firebase auth calls
  theme/app_theme.dart           # app-wide theme
  screens/
    auth/                        # login, signup, forgot password
    home_screen.dart
    create_event_screen.dart
    event_details_screen.dart
    event_members_screen.dart
    photo_assignment_screen.dart
    photo_review_screen.dart
    profile_screen.dart ...
```

## 🚀 Run locally

```bash
flutter pub get
flutter run
```

You'll need your own Firebase project. Run `flutterfire configure` to generate `firebase_options.dart` for it.

---

Designed and built by **[Kiran Chand Yellamelli](https://github.com/KiranChandY)** · [Portfolio](https://kiranchandy.framer.website) · [LinkedIn](https://www.linkedin.com/in/kiran-chandy/)

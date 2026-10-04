# LU-Navigate Flutter

A production-ready Flutter conversion of the supplied Expo LU-Navigate application.

## Run in VS Code

1. Open the `lu_navigate_flutter` folder in Visual Studio Code.
2. Install the Flutter and Dart extensions, then select an Android emulator or a USB-connected Android phone from the device selector in the VS Code status bar.
3. In the integrated terminal, run:

```bash
flutter pub get
flutter run
```

The campus-map asset is located at `assets/campus_map.png` and is declared in `pubspec.yaml`.

## Included functionality

- Floating four-section navigation (Map, Schedule, Announcements, Profile)
- Image-based pinch/zoom campus map, search highlights, building details, and interior state
- Official weekly timetable and simulated Registration Form synchronization
- Announcement search/filtering, read state, dismissal confirmation, pull-to-refresh, and empty state
- Profile preferences, feedback validation, developer credits, and logout confirmation

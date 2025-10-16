# Technology Stack

## Framework & Language

- Flutter SDK 3.9.2+
- Dart language
- Material Design 3 (useMaterial3: true)

## Key Dependencies

### Database & Backend
- `mongo_dart` (0.10.5) - MongoDB driver for direct database access
- `shared_preferences` (2.5.3) - Local key-value storage
- `connectivity_plus` (5.0.2) - Network connectivity detection

### State Management
- `provider` (6.1.5+1) - State management pattern used throughout

### PDF & Printing
- `pdf` (3.11.3) - PDF document generation
- `printing` (5.14.2) - PDF preview and printing

### UI & Forms
- `flutter_typeahead` (5.2.0) - Autocomplete text fields
- `image_picker` (1.2.0) - Camera and gallery access
- `file_picker` (10.3.3) - File selection

### Utilities
- `intl` (0.20.2) - Internationalization and date formatting
- `http` (1.5.0) - HTTP requests
- `path_provider` (2.1.5) - File system paths

## Build & Development

### Common Commands

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Build for specific platforms
flutter build apk          # Android APK
flutter build appbundle    # Android App Bundle
flutter build ios          # iOS
flutter build windows      # Windows desktop
flutter build web          # Web

# Run tests
flutter test

# Analyze code
flutter analyze

# Clean build artifacts
flutter clean
```

## Code Quality

- Uses `flutter_lints` (6.0.0) for static analysis
- Follows Flutter recommended linting rules
- Print statements allowed for debugging (avoid_print not enforced)

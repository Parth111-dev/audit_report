---
description: Repository Information Overview
alwaysApply: true
---

# Solar Panel Audit System Information

## Summary
A Flutter application for solar panel audit management. The app provides functionality for managing and tracking solar panel audits, including user authentication, audit form creation, dashboard visualization, and PDF report generation.

## Structure
- **lib/**: Core application code
  - **models/**: Data models for the application
  - **screens/**: UI screens and pages
  - **services/**: Business logic and backend services
  - **widgets/**: Reusable UI components
- **assets/**: Static resources like images
- **test/**: Test files for the application
- **android/**, **ios/**, **web/**, **linux/**, **macos/**, **windows/**: Platform-specific code

## Language & Runtime
**Language**: Dart
**Version**: SDK ^3.9.2
**Framework**: Flutter
**Package Manager**: pub (Flutter's package manager)

## Dependencies
**Main Dependencies**:
- **mongo_dart**: ^0.10.5 - MongoDB driver for Dart
- **printing**: ^5.14.2 - PDF printing functionality
- **pdf**: ^3.11.3 - PDF generation
- **provider**: ^6.1.5+1 - State management
- **intl**: ^0.20.2 - Internationalization and formatting
- **flutter_typeahead**: ^5.2.0 - Autocomplete functionality
- **image_picker**: ^1.2.0 - Image selection
- **file_picker**: ^10.3.3 - File selection
- **http**: ^1.5.0 - HTTP requests
- **shared_preferences**: ^2.5.3 - Local storage

**Development Dependencies**:
- **flutter_test**: Testing framework
- **flutter_lints**: ^6.0.0 - Linting rules

## Build & Installation
```bash
# Get dependencies
flutter pub get

# Run the application in development mode
flutter run

# Build for specific platforms
flutter build apk  # Android
flutter build ios  # iOS
flutter build web  # Web
flutter build windows  # Windows
flutter build macos  # macOS
flutter build linux  # Linux
```

## Application Structure
**Main Entry Point**: lib/main.dart
**Key Components**:
- **Authentication**: Managed by AuthService
- **Database**: MongoDB connection via DatabaseService
- **Audit Management**: AuditService for handling audit data
- **UI Screens**:
  - LoginScreen: User authentication
  - DashboardScreen: Main dashboard view
  - AuditFormScreen: Form for creating/editing audits
  - AuditDetailScreen: Detailed view of an audit
  - UserManagementScreen: User administration
  - PdfScreen: PDF report generation and preview

## Data Model
The application uses a comprehensive AuditForm model that captures detailed information about solar panel audits across multiple stages:
- Basic audit information (serial number, date, auditor)
- Floor stage measurements
- Front glass loading specifications
- EVA cutting parameters
- Stringer process details
- Lay-up and auto bussing measurements
- Auto tapping specifications
- Rear side EVA cutting
- Backsheet/glass specifications
- Logo and barcode verification
- Pre-EL inspection results
- Edge taping verification
- Lamination process parameters
- Framing process details
- Junction box assembly specifications

## Testing
**Framework**: flutter_test
**Test Location**: test/
**Naming Convention**: *_test.dart
**Run Command**:
```bash
flutter test
```

## Cross-Platform Support
The application is built to support multiple platforms:
- **Mobile**: Android and iOS
- **Desktop**: Windows, macOS, and Linux
- **Web**: Browser-based version

The repository includes platform-specific configurations for each supported platform, allowing the same codebase to be deployed across different environments.
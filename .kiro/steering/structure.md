# Project Structure

## Directory Organization

```
lib/
├── main.dart                 # App entry point, service initialization, routing
├── models/                   # Data models and business logic
│   ├── base_audit_model.dart       # Abstract base class for all audit types
│   ├── audit_model.dart            # Legacy/generic audit model
│   ├── sheet_cutting_audit_model.dart
│   ├── cell_cutting_audit_model.dart
│   ├── framing_audit_model.dart
│   └── audit_form_factory.dart     # Factory pattern for audit creation
├── screens/                  # UI screens (full-page views)
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── audit_form_screen.dart      # Generic audit form
│   ├── audit_detail_screen.dart
│   ├── sheet_cutting_form_screen.dart
│   ├── sheet_cutting_detail_screen.dart
│   ├── sheet_cutting_pdf_screen.dart
│   ├── cell_cutting_form_screen.dart
│   ├── cell_cutting_detail_screen.dart
│   ├── cell_cutting_pdf_screen.dart
│   ├── framing_form_screen.dart
│   ├── framing_detail_screen.dart
│   ├── framing_pdf_screen.dart
│   ├── pdf_screen.dart
│   └── user_management_screen.dart
├── services/                 # Business logic and external integrations
│   ├── auth_service.dart           # Authentication (ChangeNotifier)
│   ├── database_service.dart       # MongoDB operations (ChangeNotifier)
│   ├── audit_service.dart          # Audit-specific logic (ChangeNotifier)
│   └── pdf_service.dart            # PDF generation
└── widgets/                  # Reusable UI components
    ├── audit_card.dart
    ├── custom_textfield.dart
    ├── date_field.dart
    ├── dynamic_audit_form.dart
    └── stage_widget.dart

assets/
├── images/                   # Image assets
└── excel/                    # Excel templates (if any)
```

## Architecture Patterns

### Model Layer
- **Inheritance hierarchy**: `BaseAuditForm` → specific audit types (SheetCutting, CellCutting, Framing)
- **Factory pattern**: `audit_form_factory.dart` for creating appropriate audit types
- **Type identification**: Serial number prefixes (SC-, CC-, FR-) determine audit type
- **Common fields**: All audits share base fields (serialNumber, auditDate, shift, po, moduleType, etc.)

### Service Layer
- **Provider pattern**: All services extend `ChangeNotifier` for reactive state management
- **Singleton-like usage**: Services instantiated in main.dart and provided via MultiProvider
- **Connection management**: DatabaseService handles both local and cloud MongoDB connections
- **Lifecycle management**: Services implement dispose() for cleanup

### Screen Layer
- **Naming convention**: `*_screen.dart` for full-page views
- **Type-specific screens**: Separate form/detail/pdf screens for each audit type
- **Route-based navigation**: Named routes defined in main.dart

### Widget Layer
- **Reusable components**: Custom form fields, cards, and specialized widgets
- **Composition over inheritance**: Small, focused widgets composed together

## Key Conventions

### Date Handling
- ISO 8601 format for storage (`DateTime.toIso8601String()`)
- DD/MM/YYYY format for display (`DateFormat('dd/MM/yyyy')`)
- Helper functions in `base_audit_model.dart`: `parseAuditDate()`, `formatDateWithLocalTime()`

### ID Management
- MongoDB ObjectId handling via `parseMongoId()` helper
- String/ObjectId conversion utilities in base model

### Error Handling
- Print statements with emoji prefixes (✅ success, ❌ error, ⚠️ warning, 🔍 debug)
- Try-catch blocks with user-friendly error messages
- Graceful fallbacks for null/invalid data

### Data Serialization
- `toMap()` for model → database
- `fromMap()` factory constructors for database → model
- Safe parsing with `safeString()` and `safeRequiredString()` helpers

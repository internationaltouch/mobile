# FIT Mobile App - GitHub Copilot Instructions

**Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Project Overview

FIT Mobile App is a Flutter mobile application for Federation of International Touch events, providing access to fixtures, results, and ladder standings across various divisions and tournaments. The app is built with Flutter/Dart and targets Android, iOS, Web, and macOS platforms.

## Working Effectively

### Prerequisites & Installation
Install Flutter SDK and dependencies:
```bash
# Download and install Flutter SDK 3.24.5 or later
cd /tmp
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.1-stable.tar.xz
tar xf flutter_linux_3.27.1-stable.tar.xz
export PATH="/tmp/flutter/bin:$PATH"
```

### Bootstrap, Build, and Test
**CRITICAL: NEVER CANCEL any build or test commands. Set timeouts appropriately.**

```bash
# Install dependencies - takes 1-3 seconds (measured: 1.4s)
flutter pub get

# Run analysis - takes 3-5 seconds (measured: 3.0s)
flutter analyze

# Format code - takes 1 second (measured: 0.8s)
dart format .

# Build Android APK - FIRST BUILD: 200+ seconds, INCREMENTAL: 40-50 seconds
# NEVER CANCEL. Set timeout to 400+ seconds for safety.
flutter build apk --release

# Build for web - takes 35-40 seconds (measured: 38s incremental)
# NEVER CANCEL. Set timeout to 120+ seconds.
flutter create --platforms=web .  # Only needed once to enable web support
flutter build web --release

# Build Android App Bundle - similar timing to APK build
# NEVER CANCEL. Set timeout to 400+ seconds.
flutter build appbundle --release
```

### Testing
**WARNING: Tests currently fail due to database initialization issues.**
```bash
# Run tests - currently fails due to sqflite_common_ffi not properly configured
# Set timeout to 600+ seconds if attempting. NEVER CANCEL.
flutter test --timeout=600s

# The issue: Database factory not initialized for testing environment
# Tests require sqflite_common_ffi setup which is currently disabled in pubspec.yaml
```

### Development Commands
```bash
# Format code - takes 1 second (measured: 0.8s)
dart format .

# Run the app (development mode)
flutter run

# Run on web (requires web platform enabled)
flutter run -d chrome --web-port=8080

# Clean build artifacts - takes 1-2 seconds
flutter clean
```

## Validation Requirements

**ALWAYS manually validate any new code changes by:**

1. **Build Validation**: Run the complete build process
   ```bash
   flutter clean
   flutter pub get              # 1-3 seconds
   flutter analyze              # 3-5 seconds (expect warnings, not errors)
   dart format .                # 1 second
   flutter build apk --release  # NEVER CANCEL - Wait 6+ minutes first build, 1+ minute incremental
   flutter build web --release  # NEVER CANCEL - Wait 40+ seconds
   ```

2. **Web Application Testing**: Validate the web build works
   ```bash
   # After building for web, serve and test
   cd build/web
   python3 -m http.server 8082
   # Then test in browser: http://localhost:8082
   # Verify: App loads, navigation works, no console errors
   ```

3. **Manual Testing Scenarios**: Test these workflows after any UI/navigation changes:
   - **Tab Navigation**: Navigate between bottom tabs (News, Competitions, My Touch)
   - **Competition Flow**: Browse competitions list → select event → view seasons
   - **Deep Navigation**: Competition → Event Detail → Divisions → Fixtures/Results
   - **Back Navigation**: Test back button maintains proper navigation stack
   - **Favorites**: Add/remove favorites in My Touch tab, test navigation to saved items
   - **Image Loading**: Verify images load (should show FIT logo for missing images)
   - **Responsive Layout**: Check layout on different screen sizes

4. **Code Quality**: Always run before committing
   ```bash
   dart format .           # Should show "0 changed"
   flutter analyze         # Should complete without new errors
   ```

## Common Issues & Solutions

### Build Issues
- **Gradle timeouts**: Android builds can take 200+ seconds. Always set timeout to 400+ seconds.
- **Path dependency conflict**: Use `path: ^1.9.0` in pubspec.yaml (not ^1.9.1)
- **sqflite issues**: Database plugin has Gradle compatibility issues on some configurations

### Testing Issues  
- **Database initialization**: Tests fail because `sqflite_common_ffi` is disabled
- **Mock data**: App uses static demo data via DataService for testing
- **Network requests**: Tests return 400 status codes in test environment

### Development Environment
- **Flutter version**: Requires 3.24.5 or later (tested with 3.27.1)
- **Dart version**: Requires 3.5.4 or later  
- **Android SDK**: Required for APK/AAB builds
- **Web platform**: Run `flutter create --platforms=web .` once to enable

## Repository Structure

```
lib/
├── config/           # App configuration (API URLs, image settings)
├── models/           # Data models (Event, Division, Fixture, Ladder, NewsItem)
├── services/         # Data services (API calls, database, caching)
├── theme/            # UI theming and styling
├── utils/            # Helper functions and utilities
├── views/            # UI screens and pages
└── widgets/          # Reusable UI components

test/
├── navigation_test.dart         # Navigation flow tests (currently failing)
├── widget_test.dart            # Widget tests (currently failing)  
└── services/                   # Service layer tests (currently failing)

android/              # Android platform-specific code
web/                  # Web platform-specific code (after enabling)
assets/               # Images and static assets
```

## Key Files & Configuration

### Critical Files to Check After Changes
- `lib/services/data_service.dart` - Main data service with static demo data
- `lib/views/main_navigation_view.dart` - Bottom navigation and tab management
- `lib/config/app_config.dart` - API configuration and image handling
- `pubspec.yaml` - Dependencies and versioning
- `analysis_options.yaml` - Linting rules

### Dependencies Management
Current known dependency constraints:
```yaml
# In pubspec.yaml - these versions are validated to work:
path: ^1.9.0                    # NOT ^1.9.1 (causes conflict)
sqflite: ^2.4.1                # Works for builds
# sqflite_common_ffi: ^2.3.6   # Disabled - causes Dart SDK version issues
```

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/flutter.yml`) runs:
- **Test**: `flutter test` (currently failing)
- **Analysis**: `flutter analyze` (succeeds with warnings)
- **Build Android**: APK and App Bundle creation
- **Build iOS**: IPA creation (macOS runner)

**Build Timing Expectations (Measured on Ubuntu 24.04):**
- Dependencies: 1-3 seconds (flutter pub get)
- Code formatting: 1 second (dart format)
- Analysis: 3-5 seconds (flutter analyze)  
- Web build: 35-40 seconds incremental (flutter build web)
- Android APK: 200+ seconds first build, 40-50 seconds incremental
- Android AAB: Similar to APK timing
- Clean operation: 1-2 seconds (flutter clean)

## Manual Validation Checklist

Before completing any changes, verify:

- [ ] `flutter clean && flutter pub get` completes successfully (1-3 seconds)
- [ ] `dart format .` shows "0 changed" (1 second)
- [ ] `flutter analyze` runs without new errors (3-5 seconds, warnings OK)
- [ ] `flutter build web --release` completes successfully (35-40 seconds)
- [ ] `flutter build apk --release` completes successfully (40+ seconds incremental, 200+ seconds first build)
- [ ] Web app serves correctly: `cd build/web && python3 -m http.server 8082`
- [ ] Navigate through app: News → Competitions → Event → Divisions → Back
- [ ] Test My Touch favorites navigation and add/remove functionality
- [ ] Verify no broken images (should show FIT logo fallback)
- [ ] Check responsive layout and UI consistency
- [ ] No console errors in browser developer tools

## Performance Notes

- **Caching**: App uses SQLite for caching with progressive background loading
- **Images**: Falls back to FIT logo (`assets/images/LOGO_FIT-VERT.png`) for missing images
- **Data**: Currently uses static demo data; designed for future REST API integration
- **Navigation**: Uses Flutter's Navigator 2.0 with bottom tab architecture

## Contact & Support

For questions about this codebase:
📧 [technology@internationaltouch.org](mailto:technology@internationaltouch.org)

**Remember: Always follow these validated instructions before attempting alternative approaches.**
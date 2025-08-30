# FIT Mobile App

A Flutter mobile application for Federation of International Touch events, providing access to fixtures, results, and ladder standings across various divisions and tournaments.

## Features

### 📱 Complete Tournament Interface
- **Home Page**: Scrolling news feed with latest tournament updates
- **Competitions Grid**: Browse events with visual tiles and logos
- **Event Details**: Season selection for multi-year tournaments
- **Division Selection**: Color-coded division tiles for easy navigation
- **Fixtures & Results**: Match cards showing teams, times, fields, and scores
- **Ladder Standings**: Real-time tournament standings with comprehensive stats

### 🏆 Navigation Flow
Home → Competitions → Event → Season → Division → Fixtures ⟷ Ladder

### ⚡ Key Features
- **Real-time Updates**: Live fixtures and ladder data
- **Cross-platform**: Single codebase for iOS, iPadOS, Android, and macOS
- **Offline Ready**: Local data caching with refresh capabilities
- **Modern UI**: Material Design 3 with responsive layouts
- **Tabbed Interface**: Easy switching between Fixtures and Ladder views

## Getting Started

### Prerequisites
- Flutter SDK 3.24.5 or later
- Dart SDK 3.1.0 or later
- Android Studio / VS Code with Flutter extensions
- CocoaPods (for iOS and macOS builds)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/internationaltouch/mobile.git
cd mobile
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Testing

Run all tests:
```bash
flutter test
```

Run specific test files:
```bash
flutter test test/services/data_service_test.dart
```

### Building

Build for Android:
```bash
flutter build apk --release
flutter build appbundle --release
```

Build for iOS:
```bash
flutter build ios --release
```

Build for macOS:
```bash
flutter build macos --release
```

## Architecture

### Project Structure
```
lib/
├── models/           # Data models (Event, Division, Fixture, etc.)
├── views/            # UI screens and pages
├── services/         # Data services and API calls
├── widgets/          # Reusable UI components
└── utils/            # Helper functions and utilities
```

### Data Models
- **Event**: Tournament/competition information
- **Division**: Age/gender categories within events
- **Fixture**: Match details with teams, times, and results
- **Ladder**: Tournament standings with statistics
- **NewsItem**: News feed content

### Static Data
Currently uses static demo data via `DataService`. In production, this would be replaced with REST API calls to live tournament data.

## CI/CD Pipeline

The project includes GitHub Actions workflows for:

- ✅ **Code Quality**: Formatting, linting, and analysis
- 🧪 **Testing**: Automated test suite execution
- 📦 **Build Artifacts**: 
  - Android APK and App Bundle
  - iOS IPA (signed/unsigned for testing)

### Workflows

#### Main CI/CD (`flutter.yml`)
- **Triggers**: Push to `main`/`develop` branches, PRs to `main`
- **Runs**: Tests, analysis, Android builds, iOS builds
- **Artifacts**: `android-apk`, `android-aab`, `ios-ipa`

#### iOS Build (`ios-build.yml`)
- **Triggers**: Pull requests only
- **Runs**: iOS-specific builds with code signing support
- **Artifacts**: `ios-ipa`, `ios-build-report`
- **Features**: Automatic device installation instructions

### Artifacts
Download build artifacts from GitHub Actions runs:
- `android-apk`: Android APK for direct installation
- `android-aab`: Android App Bundle for Play Store
- `ios-ipa`: iOS IPA for testing (signed if secrets configured)
- `ios-build-report`: Device installation instructions and build details

### iOS Code Signing
For signed iOS builds, configure the following repository secrets:
- `APPLE_CERTIFICATE_BASE64`: Base64-encoded P12 certificate
- `APPLE_CERTIFICATE_PASSWORD`: Certificate password
- `APPLE_PROVISIONING_PROFILE_BASE64`: Base64-encoded provisioning profile
- `APPLE_TEAM_ID`: Apple Developer Team ID

See [IOS_CODE_SIGNING.md](IOS_CODE_SIGNING.md) for detailed setup instructions.

## Development

### Adding New Features
1. Create feature branch from `develop`
2. Implement changes with tests
3. Run `flutter analyze` and `flutter test`
4. Submit pull request

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` for consistent formatting
- Prefer `const` constructors where possible
- Use meaningful variable and function names

## Tournament Data

The app currently displays demo data for:
- **Touch World Cup** (2024, 2022, 2020)
- **European Touch Championships** (2024, 2023)
- **Asian Touch Cup** (2024, 2023)
- **Pacific Touch Championships** (2024)

Each event includes multiple divisions:
- Men's Open, Women's Open
- Men's 30s, Women's 30s
- Men's 40s, Women's 40s

## Contributing

This is an open-source project welcoming contributions from the touch rugby community.

### How to Contribute
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit pull request

### Contact
For questions or collaboration opportunities:
📧 [technology@internationaltouch.org](mailto:technology@internationaltouch.org)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Federation of International Touch** - Empowering the global touch rugby community through technology.
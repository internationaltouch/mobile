# Touch Technology Framework

A modular Flutter framework for building white-label touch rugby mobile applications. This mono-repo contains reusable packages and multiple organization-specific apps.

## 🏗️ Framework Structure

```
white-label-mobile/
├── packages/                        # Reusable Flutter packages
│   ├── touchtech_core/             # Core services, config, database
│   ├── touchtech_news/             # News feed functionality
│   ├── touchtech_clubs/            # Clubs/Member Nations
│   ├── touchtech_competitions/     # Competitions, fixtures, ladders
│   └── touchtech_favorites/        # Bookmarks/favorites system
├── apps/                           # Organization-specific apps
│   ├── internationaltouch/         # FIT International Touch App
│   └── touch_superleague_uk/       # Touch Superleague UK App
├── configs/                        # Saved app configurations
├── docs/                           # Framework documentation
└── Makefile                        # Build and test commands
```

## 📦 Packages

### touchtech_core
Core services and utilities used across all apps:
- Configuration system with JSON-based app config
- Database service with Drift/SQLite
- Device awareness and connectivity monitoring
- API service foundation
- Shared widgets and utilities

### touchtech_news
News feed module with:
- REST API integration
- News article models and views
- Media support (images, videos)
- Offline caching

### touchtech_clubs
Clubs/Member Nations module:
- Club data models
- Club listing and detail views
- Member organization profiles

### touchtech_competitions
Competition management module:
- Event, season, division models
- Fixtures and results
- Ladder standings with statistics
- Competition filtering and navigation
- Match score cards

### touchtech_favorites
Bookmarking system:
- Multi-type favorites (events, divisions, teams)
- Local storage persistence
- Favorites view and management

## 🏢 Apps

### FIT International Touch (`apps/internationaltouch/`)
Official app for Federation of International Touch:
- Global touch rugby events and tournaments
- World Cup, continental championships
- International news feed
- Member nation information
- Bundle ID: `org.internationaltouch.fit`

### Touch Superleague UK (`apps/touch_superleague_uk/`)
Official app for Touch Superleague UK:
- UK domestic competition results
- League fixtures and standings
- Focused on competitions (no news/clubs modules)
- Bundle ID: `uk.org.touchsuperleague.mobile`

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.13.0 or later
- Dart SDK 3.1.0 or later
- Android Studio / VS Code with Flutter extensions
- CocoaPods (for iOS builds)
- Make (for build scripts)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/internationaltouch/mobile.git
cd mobile
```

2. Install dependencies for all packages and apps:
```bash
make pub-get
```

### Development Commands

```bash
# Get dependencies for all packages and apps
make pub-get

# Run all tests (packages + apps)
make test

# Test packages only
make test-packages

# Test apps only
make test-apps

# Lint all code
make lint

# Clean all build artifacts
make clean

# Build specific apps
make build-fit       # Build FIT International Touch app
make build-tsl       # Build Touch Superleague UK app
```

### Running Apps

```bash
# Run FIT International Touch app
cd apps/internationaltouch
flutter run

# Run Touch Superleague UK app
cd apps/touch_superleague_uk
flutter run
```

## 🧪 Testing

Run tests for all packages:
```bash
make test-packages
```

Run tests for all apps:
```bash
make test-apps
```

Run all tests:
```bash
make test
```

Test individual packages:
```bash
cd packages/touchtech_core && flutter test
cd packages/touchtech_competitions && flutter test
```

## 🏗️ Building Apps

### Android

```bash
# FIT International Touch
cd apps/internationaltouch
flutter build apk --release
flutter build appbundle --release

# Touch Superleague UK
cd apps/touch_superleague_uk
flutter build apk --release
flutter build appbundle --release
```

### iOS

```bash
# FIT International Touch
cd apps/internationaltouch
flutter build ios --release

# Touch Superleague UK
cd apps/touch_superleague_uk
flutter build ios --release
```

## 📝 Creating New Apps

To create a new organization app:

1. Create app directory structure:
```bash
mkdir -p apps/your_org/{lib,assets/{config,images},test}
```

2. Copy Android/iOS projects from an existing app
3. Create `pubspec.yaml` with required package dependencies
4. Create app-specific `app_config.json` in `assets/config/`
5. Customize bundle IDs and app name
6. Add app logo and branding assets

## 🔧 Configuration

Each app uses a JSON configuration file (`assets/config/app_config.json`) to customize:
- Display name and branding
- API endpoints
- Enabled/disabled modules (news, clubs, competitions)
- Theme colors
- Competition logos and assets

See `configs/` directory for example configurations.

## 📚 Architecture

### Package Dependencies

```
touchtech_core (foundation)
    ↓
touchtech_news, touchtech_clubs, touchtech_competitions
    ↓
touchtech_favorites
    ↓
Apps (internationaltouch, touch_superleague_uk)
```

### State Management
- **Riverpod** for reactive state management
- Providers for API data, favorites, device state
- Offline-first architecture with local caching

### Data Layer
- **Drift** for local SQLite database
- REST API integration via `ApiService`
- Automatic offline fallback

### Navigation
- Material navigation with deep linking support
- Tab-based navigation within feature modules
- Route-based navigation between major sections

## 🔄 CI/CD Pipeline

GitHub Actions workflows for:
- ✅ Code quality (formatting, linting, analysis)
- 🧪 Automated testing
- 📦 Build artifacts (Android APK/AAB, iOS IPA)

### Workflow Triggers
- Push to `main` or `develop` branches
- Pull requests to `main` branch

## 🤝 Contributing

This framework powers multiple touch rugby organizations' apps. Contributions welcome!

### How to Contribute
1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Run `make lint` and `make test`
5. Submit pull request

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` for consistent formatting
- Prefer `const` constructors
- Add tests for new features

## 📞 Contact

For questions or collaboration:
📧 [technology@internationaltouch.org](mailto:technology@internationaltouch.org)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Touch Technology Framework** - Powering the global touch rugby community through modular, scalable technology.

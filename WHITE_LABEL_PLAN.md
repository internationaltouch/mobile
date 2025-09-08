# White Label Enhancement Plan

## Current State Analysis

The project has made significant progress toward the white label vision outlined in WHITE_LABEL.md. Key existing components:

### ✅ Already Implemented
- **Configuration Framework**: `ConfigService` provides comprehensive JSON-based configuration
- **Component Support**: All major components are present:
  - News (RSS-based) - `NewsView` (currently named `HomeView`)
  - Clubs - `ClubView` (currently named `MembersView`, displays customizable labels)
  - Fixtures & Results - `CompetitionsView` and related views
  - Navigation - `MainNavigationView` with configurable tabs
- **Theming**: `ConfigurableTheme` and branding configuration support
- **Multiple Configurations**: Sample configs exist for different organizations

### ❌ Gaps vs WHITE_LABEL.md Requirements

1. **RSS Configuration**: News component doesn't use configurable RSS URLs or pagination settings
2. **Club Filtering**: Missing per-app overrides for inactive/hidden clubs, slug exclusion, and image mapping
3. **Competition Filtering**: Missing per-app exclusion by competition/season/division slugs
4. **Initial Navigation**: Can't start at specific Competition/Season/Division levels
5. **Favorites Component**: Not implemented as independent component with stack clearing
6. **Component Independence**: Some coupling exists between components
7. **Debug Configuration**: No OS-level settings for base URL in debug builds
8. **Library Integration**: Missing recommended libraries for enhanced functionality
9. **Splash Screen Assets**: Logo asset management not fully configurable

## Target Architecture

### Modular Component Structure

After the refactor, each component will be split into testable, independent modules:

```
lib/
├── core/                           # Shared infrastructure
│   ├── config/                     # Configuration management
│   ├── network/                    # API clients and networking
│   ├── storage/                    # Local data persistence
│   └── theme/                      # Theming and branding
├── components/                     # Independent UI components
│   ├── news/
│   │   ├── models/                 # RSS feed models
│   │   ├── services/               # News data fetching
│   │   ├── bloc/                   # Business logic (state management)
│   │   ├── widgets/                # Reusable UI widgets
│   │   └── views/                  # NewsView and related screens
│   ├── clubs/
│   │   ├── models/                 # Club data models
│   │   ├── services/               # Club API services
│   │   ├── bloc/                   # Club state management
│   │   ├── widgets/                # Club UI components
│   │   └── views/                  # ClubView and related screens
│   ├── competitions/
│   │   ├── models/                 # Competition/fixture models
│   │   ├── services/               # Competition API services
│   │   ├── bloc/                   # Competition state management
│   │   ├── widgets/                # Competition UI components
│   │   └── views/                  # Competition views
│   └── favorites/
│       ├── models/                 # Favorites data models
│       ├── services/               # Favorites persistence
│       ├── bloc/                   # Favorites state management
│       ├── widgets/                # Favorites UI components
│       └── views/                  # Favorites view
└── shared/                         # Cross-component utilities
    ├── widgets/                    # Common UI widgets
    ├── utils/                      # Helper functions
    └── extensions/                 # Dart extensions
```

**Key Principles:**
- Each component is self-contained with its own models, services, and UI
- Components communicate through well-defined interfaces (events/states)
- Shared code lives in `core/` and `shared/` directories
- Business logic is separated from UI using BLoC pattern
- Each module has comprehensive unit and widget tests

## Mono-Repo Structure

### Project Organization

**Touch Technology Framework** (app.touchtechnology.* namespace)

```
touch-mobile-framework/            # Root mono-repo
├── packages/                      # Reusable Flutter packages (touchtechnology.app namespace)
│   ├── touchtech_core/            # Core services and utilities
│   │   ├── lib/
│   │   │   ├── config/            # Configuration services
│   │   │   ├── services/          # Data services, API clients
│   │   │   ├── models/            # Shared data models
│   │   │   ├── utils/             # Utility functions
│   │   │   └── theme/             # Base theming system
│   │   ├── test/
│   │   └── pubspec.yaml           # name: touchtech_core
│   ├── touchtech_news/            # News module package
│   │   ├── lib/
│   │   │   ├── models/            # News-specific models
│   │   │   ├── services/          # RSS parsing, news API
│   │   │   ├── widgets/           # News UI components
│   │   │   └── views/             # NewsView and screens
│   │   ├── test/
│   │   └── pubspec.yaml           # name: touchtech_news
│   ├── touchtech_clubs/           # Clubs module package
│   │   ├── lib/
│   │   │   ├── models/
│   │   │   ├── services/
│   │   │   ├── widgets/
│   │   │   └── views/
│   │   ├── test/
│   │   └── pubspec.yaml           # name: touchtech_clubs
│   ├── touchtech_competitions/    # Competitions module package
│   │   ├── lib/
│   │   │   ├── models/
│   │   │   ├── services/
│   │   │   ├── widgets/
│   │   │   └── views/
│   │   ├── test/
│   │   └── pubspec.yaml           # name: touchtech_competitions
│   └── touchtech_favorites/       # Favorites module package
│       ├── lib/
│       ├── test/
│       └── pubspec.yaml           # name: touchtech_favorites
├── apps/                          # Individual organization apps
│   ├── internationaltouch/        # FIT International Touch
│   │   ├── lib/
│   │   │   ├── main.dart          # App entry point
│   │   │   └── config/            # FIT-specific configuration
│   │   ├── assets/                # FIT-specific assets (logos, etc.)
│   │   ├── config/                # JSON configuration files
│   │   ├── test/                  # App integration tests
│   │   ├── pubspec.yaml           # Dependencies + touchtech packages
│   │   ├── android/app/build.gradle # applicationId "org.internationaltouch.mobile"
│   │   ├── ios/Runner.xcodeproj   # Bundle ID: org.internationaltouch.mobile
│   │   └── Makefile               # FIT app build commands
│   ├── touch_superleague_uk/      # Touch Superleague UK
│   │   ├── lib/
│   │   ├── assets/
│   │   ├── config/
│   │   ├── test/
│   │   ├── pubspec.yaml
│   │   ├── android/app/build.gradle # applicationId "uk.org.touchsuperleague.mobile"
│   │   ├── ios/Runner.xcodeproj   # Bundle ID: uk.org.touchsuperleague.mobile
│   │   └── Makefile
│   └── template/                  # Template for new apps
│       ├── lib/
│       ├── assets/
│       ├── config/
│       ├── pubspec.yaml.template
│       ├── android/app/build.gradle.template
│       ├── ios/Runner.xcodeproj.template
│       └── Makefile.template
├── scripts/                       # Build and deployment scripts
│   ├── new-app.sh                 # Create new app from template
│   ├── test-all.sh                # Run tests across all packages + apps
│   └── build-all.sh               # Build all apps
├── docs/                          # Documentation
│   ├── configuration-guide.md
│   ├── new-app-setup.md
│   ├── namespace-conventions.md
│   └── architecture.md
├── Makefile                       # Root-level commands (make test, make build-all)
└── README.md
```

**App Dependencies:**
Each app's `pubspec.yaml` references the touchtech packages:
```yaml
dependencies:
  flutter:
    sdk: flutter
  touchtech_core:
    path: ../../packages/touchtech_core
  touchtech_news:
    path: ../../packages/touchtech_news
  touchtech_clubs:
    path: ../../packages/touchtech_clubs
  touchtech_competitions:
    path: ../../packages/touchtech_competitions
  touchtech_favorites:
    path: ../../packages/touchtech_favorites
  # App-specific dependencies
```

## Implementation Plan

### Phase 1: Core Component Configuration
1. **News RSS Configuration**: ✅ COMPLETED Update `NewsView` (rename from `HomeView`) to use configurable RSS feed URLs
   - ✅ Rename `HomeView` to `NewsView` to clarify its purpose as news component (not necessarily home screen)
   - ✅ Add RSS URL (absolute or relative to base URL) to config schema
   - ✅ Add pagination settings: initial items (default 10), infinite scroll items (default 5)
   - ✅ Implement infinite scroll with configurable batch sizes
   - ✅ Modify news loading to respect configuration
2. **Club Filtering & Images**: ✅ COMPLETED Enhance club configuration system
   - ✅ Rename `MembersView` to `ClubView` to use generic terminology
   - ✅ Add configurable UI labels (navigation label, title bar text) - e.g., FIT uses "Members"/"Member Nations"
   - ✅ Add status filters: allow inactive/hidden clubs per-app
   - ✅ Implement slug exclusion list in config
   - ✅ Add slug-to-image mapping configuration
   - ✅ Update `ClubView` to apply all filters and image mappings
3. **Competition Filtering**: ✅ COMPLETED Implement comprehensive competition exclusion
   - ✅ Add exclusion by competition slug, competition+season, competition+season+division
   - ✅ Update competition views to respect exclusion filters
   - ✅ Ensure filtering works at all navigation levels

### Phase 2: Library Integration & Architecture
1. **State Management Libraries**: Integrate recommended libraries
   - Add `bloc` and `flutter_bloc` for business logic separation
   - Integrate `riverpod` for reactive data caching and async handling
   - Migrate existing state management to use these patterns
2. **Device & Connectivity**: Add device awareness capabilities
   - Integrate `connectivity_plus` for network state monitoring
   - Add `device_info_plus` for device-specific feature enabling/disabling
   - Implement adaptive behavior based on connectivity and device capabilities
3. **Data Persistence**: Implement local storage
   - Add `shared_preferences` for simple key-value storage
   - Move user preferences and settings to device storage
   - Implement offline capability where appropriate

### Phase 3: Navigation & Component Independence
1. **Favorites as Independent Component**: Implement dedicated favorites system
   - Create standalone favorites component with navigation tab
   - Implement stack clearing when navigating from favorites
   - Support shortcuts to any Competition/Season/Division/Team level
2. **Initial Navigation Configuration**: Enable deep entry points
   - Add config option to start at specific Competition/Season/Division levels
   - Implement direct navigation bypassing intermediate levels
   - Maintain proper navigation stack management
3. **Component Isolation**: Ensure complete component independence
   - Review and eliminate cross-component state dependencies
   - Implement proper state management isolation between modules
   - Ensure switching components doesn't affect others (except intentional coupling)
   - **Extract Historical Configurations**: One-time migration to extract FIT and Touch Superleague configs from git history
     - Review git history to recover original FIT configuration state
     - Capture current Touch Superleague configuration
     - Create separate configuration files for both organizations in their respective app directories
   - **Reorganize into Touch Technology Framework** (app.touchtechnology.* namespace)
     - Move reusable components to separate packages with proper namespacing
     - Restructure mono-repo with packages/ and apps/ directories
     - Update package names: touchtech_core, touchtech_news, touchtech_clubs, etc.
     - Configure proper reverse domain name identifiers for each app
   - **Implement Comprehensive Testing Strategy**
     - Root-level `make test` validates all packages and apps in harmony
     - Package-level tests validate individual component functionality
     - App-level integration tests validate configuration and assembly
     - Cross-app compatibility tests ensure framework works for different organizations

### Phase 4: Advanced Theming & Debug Features
1. **Enhanced Theming System**: Implement comprehensive color schemes
   - Add per-component color configuration (news=white, fixtures=green, etc.)
   - Integrate `flex_color_scheme` for Material design themes
   - Support both app-wide and component-specific color schemes
2. **Debug Configuration**: Add development tools
   - Implement OS-level settings for base URL in debug builds
   - Add runtime API base URL switching
   - Create debug screens for testing different configurations
3. **Asset Management**: Improve splash screen and logo handling
   - Ensure splash screen logos are configurable per build
   - Implement asset validation and fallback handling
   - Support multiple logo formats and sizes

### Phase 5: Notifications & Polish
1. **Local Notifications**: Add match reminder capabilities
   - Integrate `flutter_local_notifications`
   - Implement configurable match start reminders
   - Support per-user notification preferences
2. **Configuration Validation & Documentation**: 
   - Add comprehensive config schema validation
   - Create detailed configuration documentation with examples
   - Implement helpful error messages for invalid configurations
3. **Testing & Examples**:
   - Create sample configurations for different organization types
   - Add comprehensive testing for all configuration scenarios
   - Document migration path for existing installations

## Build & Test Strategy

### Makefile-Driven Development

The project uses `Makefile` at multiple levels for consistent build and test operations:

#### Root-Level Makefile (`./Makefile`)
```makefile
# Test all packages and apps - validates framework integrity
test:
	@echo "🧪 Testing Touch Technology Framework..."
	@for dir in packages/* apps/*; do \
		if [ -f "$$dir/Makefile" ]; then \
			echo "📦 Testing $$dir..."; \
			$(MAKE) -C "$$dir" test; \
		fi \
	done
	@echo "✅ All tests passed! Framework validated."

# Build all apps
build-all:
	./scripts/build-all.sh

# Lint all code
lint-all:
	cd core && make lint
	./scripts/lint-all.sh

# Create new app from template
new-app:
	@read -p "Enter app name: " app_name; \
	./scripts/new-app.sh $$app_name

# Clean all builds
clean-all:
	cd core && make clean
	./scripts/clean-all.sh
```

#### Core Library Makefile (`./core/Makefile`)
```makefile
# Run all tests for core library
test:
	flutter test

# Test specific component
test-component:
	flutter test test/components/$(COMPONENT)/

# Run tests with coverage
test-coverage:
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html

# Lint core library
lint:
	dart analyze lib/
	dart format --set-exit-if-changed lib/ test/

# Build documentation
docs:
	dart doc lib/

clean:
	flutter clean
	rm -rf coverage/
```

#### App-Level Makefile (`./apps/{app-name}/Makefile`)
```makefile
APP_NAME := $(shell basename $(CURDIR))

# Development builds
dev-android:
	flutter build apk --debug --flavor dev --target lib/main.dart

dev-ios:
	flutter build ios --debug --flavor dev --target lib/main.dart

# Production builds
prod-android:
	flutter build apk --release --flavor prod --target lib/main.dart

prod-ios:
	flutter build ios --release --flavor prod --target lib/main.dart

# Testing
test:
	flutter test

test-integration:
	flutter drive --target=test_driver/app.dart

# Linting and formatting
lint:
	dart analyze lib/ test/
	dart format --set-exit-if-changed lib/ test/

# Configuration validation
validate-config:
	dart run lib/tools/validate_config.dart config/

# Asset generation (icons, splash screens)
generate-assets:
	flutter packages pub run flutter_launcher_icons:main
	flutter packages pub run flutter_native_splash:create

# Clean
clean:
	flutter clean
	rm -rf build/
```

### Testing Strategy

#### Unit Testing Structure
```
test/
├── core/                          # Core library tests
│   ├── config/
│   │   ├── config_service_test.dart
│   │   └── theme_config_test.dart
│   ├── network/
│   │   └── api_client_test.dart
│   └── storage/
│       └── local_storage_test.dart
├── components/                    # Component-specific tests
│   ├── news/
│   │   ├── models/
│   │   │   └── news_item_test.dart
│   │   ├── services/
│   │   │   └── rss_service_test.dart
│   │   ├── bloc/
│   │   │   └── news_bloc_test.dart
│   │   └── widgets/
│   │       └── news_card_test.dart
│   ├── clubs/
│   │   ├── models/
│   │   ├── services/
│   │   ├── bloc/
│   │   └── widgets/
│   └── competitions/
└── integration/                   # Integration tests
    ├── app_flow_test.dart
    ├── configuration_test.dart
    └── navigation_test.dart
```

#### Test Categories

1. **Unit Tests**: Test individual functions, models, and services
   - Models: Data parsing, validation, serialization
   - Services: API calls, data transformation, business logic
   - BLoCs: State management, event handling
   - Utilities: Helper functions, extensions

2. **Widget Tests**: Test UI components in isolation
   - Component rendering with different configurations
   - User interaction handling
   - State-driven UI changes
   - Theme application

3. **Integration Tests**: Test component interactions and full app flows
   - Navigation between components
   - Configuration loading and application
   - Cross-component communication (favorites → competitions)
   - Real API integration tests

4. **Golden Tests**: Visual regression testing
   - Component rendering across different themes
   - Screen layout validation
   - Asset loading verification

#### Continuous Integration

Each app includes CI configuration for:
- Automated testing on PR creation
- Build validation for multiple platforms
- Configuration validation
- Code quality checks (linting, formatting)
- Coverage reporting

Example GitHub Actions workflow:
```yaml
name: Test and Build
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v1
      - run: make test-all
      - run: make lint-all
  build:
    needs: test
    runs-on: ubuntu-latest
    strategy:
      matrix:
        app:
          - internationaltouch
          - touch_superleague_uk
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v1
      - run: cd apps/${{ matrix.app }} && make prod-android
```

## Library Dependencies to Add

Based on WHITE_LABEL.md recommendations, these libraries should be integrated:

- `connectivity_plus` - Network state monitoring for adaptive behavior
- `device_info_plus` - Device-specific feature capabilities  
- `shared_preferences` - Simple key-value storage for user preferences
- `bloc` and `flutter_bloc` - Business logic separation and state management
- `flex_color_scheme` - Advanced Material Design theming
- `riverpod` - Reactive data caching and async state management
- `flutter_local_notifications` - Match reminder notifications

## Benefits of This Approach

- **Builds on Strong Foundation**: Leverages existing configuration system
- **Maintains Compatibility**: Existing configurations continue to work  
- **Addresses ALL Requirements**: Fulfills every specification in WHITE_LABEL.md
- **Modern Architecture**: Integrates recommended libraries for better maintainability
- **Scalable**: Easy to add new configuration options in the future
- **Testable**: Each phase can be tested independently
- **Future-Proof**: Creates flexible foundation for any client requirements

## Success Metrics

Upon completion, the app should achieve:
1. **Single Base URL Deployment**: Any client build configurable via base URL alone
2. **Component Modularity**: Each UI component works independently unless explicitly coupled
3. **Flexible Entry Points**: Can start navigation at any Competition/Season/Division level
4. **Complete Configurability**: All features, colors, assets, and behavior configurable per-app
5. **Enhanced User Experience**: Offline capability, notifications, and adaptive behavior

## Next Steps

This revised plan provides a comprehensive roadmap that fully addresses the white label vision outlined in WHITE_LABEL.md, building upon the existing foundation while adding all missing functionality and modern architecture patterns.
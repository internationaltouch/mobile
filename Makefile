.PHONY: help test test-packages test-apps lint clean pub-get pub-get-packages pub-get-apps sync-version
.PHONY: build-fit build-fit-ios build-fit-android build-tsl build-tsl-ios build-tsl-android
.PHONY: build-all-ios build-all-android

help:
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Touch Technology Framework - Available Commands"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "📦 Dependencies:"
	@echo "  make pub-get            - Run flutter pub get for all packages and apps"
	@echo ""
	@echo "🧪 Testing & Quality:"
	@echo "  make test               - Run all tests (packages + apps)"
	@echo "  make test-packages      - Test all packages only"
	@echo "  make test-apps          - Test all apps only"
	@echo "  make lint               - Lint all code"
	@echo ""
	@echo "🧹 Maintenance:"
	@echo "  make clean              - Clean all build artifacts"
	@echo "  make sync-version       - Sync version from version.json to all pubspec.yaml files"
	@echo ""
	@echo "🏗️  Building (Both Platforms):"
	@echo "  make build-fit          - Build FIT app (Android + iOS signed)"
	@echo "  make build-tsl          - Build Touch Superleague app (Android + iOS signed)"
	@echo ""
	@echo "📱 Building Android Only:"
	@echo "  make build-fit-android  - Build FIT app for Android (APK + AAB)"
	@echo "  make build-tsl-android  - Build TSL app for Android (APK + AAB)"
	@echo "  make build-all-android  - Build all apps for Android"
	@echo ""
	@echo "🍎 Building iOS Only (Code Signed):"
	@echo "  make build-fit-ios      - Build FIT app for iOS (signed IPA)"
	@echo "  make build-tsl-ios      - Build TSL app for iOS (signed IPA)"
	@echo "  make build-all-ios      - Build all apps for iOS"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

pub-get: pub-get-packages pub-get-apps

pub-get-packages:
	@echo "📦 Getting dependencies for packages..."
	@cd packages/touchtech_core && flutter pub get
	@cd packages/touchtech_news && flutter pub get
	@cd packages/touchtech_competitions && flutter pub get
	@echo "✅ All package dependencies resolved!"

pub-get-apps:
	@echo "📦 Getting dependencies for apps..."
	@cd apps/internationaltouch && flutter pub get
	@cd apps/touch_superleague_uk && flutter pub get
	@echo "✅ All app dependencies resolved!"

test: test-packages test-apps

test-packages:
	@echo "🧪 Testing packages..."
	@cd packages/touchtech_core && flutter test
	@cd packages/touchtech_news && flutter test
	@cd packages/touchtech_competitions && flutter test
	@echo "✅ All package tests passed!"

test-apps:
	@echo "🧪 Testing apps..."
	@cd apps/internationaltouch && flutter test
	@cd apps/touch_superleague_uk && flutter test
	@echo "✅ All app tests passed!"

lint:
	@echo "🔍 Linting all code..."
	@cd packages/touchtech_core && flutter analyze
	@cd packages/touchtech_news && flutter analyze
	@cd packages/touchtech_competitions && flutter analyze
	@cd apps/internationaltouch && flutter analyze
	@cd apps/touch_superleague_uk && flutter analyze
	@echo "✅ All code analyzed!"

clean:
	@echo "🧹 Cleaning all build artifacts..."
	@cd packages/touchtech_core && flutter clean
	@cd packages/touchtech_news && flutter clean
	@cd packages/touchtech_competitions && flutter clean
	@cd apps/internationaltouch && flutter clean
	@cd apps/touch_superleague_uk && flutter clean
	@echo "✅ Cleaned!"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FIT International Touch App Builds
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

build-fit: build-fit-android build-fit-ios
	@echo "✅ FIT International Touch app built for both platforms!"

build-fit-android:
	@echo "🏗️  Building FIT International Touch for Android..."
	@./scripts/build_android.sh apps/internationaltouch both

build-fit-ios:
	@echo "🏗️  Building FIT International Touch for iOS (code signed)..."
	@./scripts/build_ios.sh apps/internationaltouch

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Touch Superleague UK App Builds
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

build-tsl: build-tsl-android build-tsl-ios
	@echo "✅ Touch Superleague UK app built for both platforms!"

build-tsl-android:
	@echo "🏗️  Building Touch Superleague UK for Android..."
	@./scripts/build_android.sh apps/touch_superleague_uk both

build-tsl-ios:
	@echo "🏗️  Building Touch Superleague UK for iOS (code signed)..."
	@./scripts/build_ios.sh apps/touch_superleague_uk

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Build All Apps
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

build-all-android: build-fit-android build-tsl-android
	@echo "✅ All apps built for Android!"

build-all-ios: build-fit-ios build-tsl-ios
	@echo "✅ All apps built for iOS!"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Utilities
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

sync-version:
	@dart scripts/sync_versions.dart

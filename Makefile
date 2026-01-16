.PHONY: help test test-packages test-apps lint clean build-fit build-tsl pub-get pub-get-packages pub-get-apps sync-version

help:
	@echo "Touch Technology Framework - Available Commands:"
	@echo "  make pub-get       - Run flutter pub get for all packages and apps"
	@echo "  make test          - Run all tests (packages + apps)"
	@echo "  make test-packages - Test all packages only"
	@echo "  make test-apps     - Test all apps only"
	@echo "  make lint          - Lint all code"
	@echo "  make clean         - Clean all build artifacts"
	@echo "  make build-fit     - Build FIT app (Android APK + iOS IPA)"
	@echo "  make build-tsl     - Build Touch Superleague app (Android APK + iOS IPA)"
	@echo "  make sync-version  - Sync version from version.json to all pubspec.yaml files"

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

build-fit:
	@echo "🏗️  Building FIT International Touch app..."
	@echo "📱 Building Android APK..."
	@cd apps/internationaltouch && flutter build apk --release
	@echo "🍎 Building iOS IPA..."
	@cd apps/internationaltouch && flutter build ios --release --no-codesign
	@echo "✅ FIT app built for Android and iOS!"

build-tsl:
	@echo "🏗️  Building Touch Superleague UK app..."
	@echo "📱 Building Android APK..."
	@cd apps/touch_superleague_uk && flutter build apk --release
	@echo "🍎 Building iOS IPA..."
	@cd apps/touch_superleague_uk && flutter build ios --release --no-codesign
	@echo "✅ TSL app built for Android and iOS!"

sync-version:
	@dart scripts/sync_versions.dart

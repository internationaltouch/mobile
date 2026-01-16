#!/bin/bash

# Android Build Script
# This script builds Android APK and/or AAB (App Bundle) for Google Play Store

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Default build type
BUILD_TYPE="both"  # both, apk, or aab

# Parse command line arguments
show_usage() {
    echo "Usage: $0 <app_directory> [build_type]"
    echo ""
    echo "Arguments:"
    echo "  app_directory   Path to the app directory (e.g., apps/internationaltouch)"
    echo "  build_type      Type of build: 'apk', 'aab', or 'both' (default: both)"
    echo ""
    echo "Examples:"
    echo "  $0 apps/internationaltouch           # Build both APK and AAB"
    echo "  $0 apps/touch_superleague_uk apk     # Build APK only"
    echo "  $0 apps/internationaltouch aab       # Build AAB only"
    echo ""
}

# Check if app directory is provided
if [ -z "$1" ]; then
    print_error "App directory is required"
    show_usage
    exit 1
fi

APP_DIR="$1"
if [ ! -z "$2" ]; then
    BUILD_TYPE="$2"
fi

# Validate build type
if [[ ! "$BUILD_TYPE" =~ ^(apk|aab|both)$ ]]; then
    print_error "Invalid build type: $BUILD_TYPE"
    print_info "Valid options: apk, aab, both"
    exit 1
fi

PROJECT_ROOT="$(pwd)"
BUILD_DIR="$PROJECT_ROOT/build/android"

# Validate app directory exists
if [ ! -d "$APP_DIR" ]; then
    print_error "App directory not found: $APP_DIR"
    exit 1
fi

APP_NAME=$(basename "$APP_DIR")
print_info "Building Android app: $APP_NAME"
print_info "Build type: $BUILD_TYPE"

# Change to app directory
cd "$APP_DIR"

# Clean previous builds
print_step "Cleaning previous builds..."
flutter clean

# Get dependencies
print_step "Getting Flutter dependencies..."
flutter pub get

# Create output directory
mkdir -p "$BUILD_DIR/$APP_NAME"

# Build APK if requested
if [ "$BUILD_TYPE" = "apk" ] || [ "$BUILD_TYPE" = "both" ]; then
    print_step "Building release APK..."
    flutter build apk --release
    
    # Copy APK to build directory
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        cp "build/app/outputs/flutter-apk/app-release.apk" "$BUILD_DIR/$APP_NAME/${APP_NAME}-release.apk"
        print_info "✅ APK built successfully: $BUILD_DIR/$APP_NAME/${APP_NAME}-release.apk"
    else
        print_error "APK file not found after build"
        exit 1
    fi
fi

# Build AAB if requested
if [ "$BUILD_TYPE" = "aab" ] || [ "$BUILD_TYPE" = "both" ]; then
    print_step "Building release App Bundle (AAB)..."
    flutter build appbundle --release
    
    # Copy AAB to build directory
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        cp "build/app/outputs/bundle/release/app-release.aab" "$BUILD_DIR/$APP_NAME/${APP_NAME}-release.aab"
        print_info "✅ AAB built successfully: $BUILD_DIR/$APP_NAME/${APP_NAME}-release.aab"
    else
        print_error "AAB file not found after build"
        exit 1
    fi
fi

# Return to project root
cd "$PROJECT_ROOT"

echo ""
print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_info "✅ Build completed successfully!"
print_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$BUILD_TYPE" = "apk" ] || [ "$BUILD_TYPE" = "both" ]; then
    print_info "📱 APK: $BUILD_DIR/$APP_NAME/${APP_NAME}-release.apk"
    APK_SIZE=$(du -h "$BUILD_DIR/$APP_NAME/${APP_NAME}-release.apk" | cut -f1)
    print_info "   Size: $APK_SIZE"
fi

if [ "$BUILD_TYPE" = "aab" ] || [ "$BUILD_TYPE" = "both" ]; then
    print_info "📦 AAB: $BUILD_DIR/$APP_NAME/${APP_NAME}-release.aab"
    AAB_SIZE=$(du -h "$BUILD_DIR/$APP_NAME/${APP_NAME}-release.aab" | cut -f1)
    print_info "   Size: $AAB_SIZE"
fi

echo ""
print_info "Next steps:"
if [ "$BUILD_TYPE" = "apk" ] || [ "$BUILD_TYPE" = "both" ]; then
    print_info "  • APK can be installed directly on devices or distributed via third-party stores"
fi
if [ "$BUILD_TYPE" = "aab" ] || [ "$BUILD_TYPE" = "both" ]; then
    print_info "  • AAB should be uploaded to Google Play Console for distribution"
    print_info "  • Use: https://play.google.com/console/"
fi
echo ""

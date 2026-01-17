#!/bin/bash

# iOS Build Script with Code Signing
# This script builds a signed iOS IPA that can be uploaded to App Store Connect
# via automation or Transporter.app

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if app directory is provided
if [ -z "$1" ]; then
    print_error "Usage: $0 <app_directory> [scheme_name]"
    print_info "Example: $0 apps/internationaltouch"
    print_info "Example: $0 apps/touch_superleague_uk Runner"
    exit 1
fi

APP_DIR="$1"
SCHEME="${2:-Runner}"  # Default to "Runner" if not provided
PROJECT_ROOT="$(pwd)"
BUILD_DIR="$PROJECT_ROOT/build/ios"

# Validate app directory exists
if [ ! -d "$APP_DIR" ]; then
    print_error "App directory not found: $APP_DIR"
    exit 1
fi

APP_NAME=$(basename "$APP_DIR")
print_info "Building iOS app: $APP_NAME"
print_info "Using scheme: $SCHEME"

# Change to app directory
cd "$APP_DIR"

# Clean previous builds
print_info "Cleaning previous builds..."
flutter clean

# Get dependencies
print_info "Getting Flutter dependencies..."
flutter pub get

# Build iOS archive
print_info "Building iOS archive (this may take several minutes)..."
flutter build ios --release

# Change to iOS directory for xcodebuild
cd ios

# Build archive with xcodebuild
print_info "Creating Xcode archive with code signing..."
xcodebuild -workspace Runner.xcworkspace \
    -scheme "$SCHEME" \
    -sdk iphoneos \
    -configuration Release \
    -archivePath "$BUILD_DIR/$APP_NAME.xcarchive" \
    archive \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM=WTCZNPDMRV

if [ $? -ne 0 ]; then
    print_error "Archive creation failed"
    exit 1
fi

print_info "Archive created successfully at: $BUILD_DIR/$APP_NAME.xcarchive"

# Determine ExportOptions.plist location
# First check in the app's ios directory, then fall back to root
if [ -f "ExportOptions.plist" ]; then
    EXPORT_OPTIONS="ExportOptions.plist"
    print_info "Using app-specific ExportOptions.plist"
elif [ -f "$PROJECT_ROOT/ios/ExportOptions.plist" ]; then
    EXPORT_OPTIONS="$PROJECT_ROOT/ios/ExportOptions.plist"
    print_info "Using shared ExportOptions.plist"
else
    print_error "ExportOptions.plist not found"
    print_error "Expected at: $PWD/ExportOptions.plist or $PROJECT_ROOT/ios/ExportOptions.plist"
    exit 1
fi

# Export IPA with code signing
print_info "Exporting signed IPA..."
xcodebuild -exportArchive \
    -archivePath "$BUILD_DIR/$APP_NAME.xcarchive" \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    -exportPath "$BUILD_DIR/$APP_NAME" \
    -allowProvisioningUpdates

if [ $? -ne 0 ]; then
    print_error "IPA export failed"
    exit 1
fi

# Find the generated IPA
IPA_FILE=$(find "$BUILD_DIR/$APP_NAME" -name "*.ipa" | head -n 1)

if [ -z "$IPA_FILE" ]; then
    print_error "IPA file not found after export"
    exit 1
fi

print_info "✅ Build completed successfully!"
echo ""
print_info "Signed IPA location: $IPA_FILE"
print_info "Archive location: $BUILD_DIR/$APP_NAME.xcarchive"
echo ""
print_info "You can now upload this IPA to App Store Connect using:"
print_info "  1. Transporter.app (drag and drop the IPA file)"
print_info "  2. xcrun altool --upload-app --type ios --file \"$IPA_FILE\" --apiKey YOUR_KEY --apiIssuer YOUR_ISSUER"
print_info "  3. xcrun altool --validate-app --type ios --file \"$IPA_FILE\" --apiKey YOUR_KEY --apiIssuer YOUR_ISSUER"
echo ""

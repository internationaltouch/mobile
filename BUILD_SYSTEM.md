# Build System Documentation

This document describes the build system for the Touch Technology mobile apps, including separate build targets for iOS and Android with proper code signing for iOS.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [Build Targets](#build-targets)
5. [iOS Code Signing](#ios-code-signing)
6. [Android Build Types](#android-build-types)
7. [Build Scripts](#build-scripts)
8. [Output Locations](#output-locations)
9. [Troubleshooting](#troubleshooting)

## Overview

The build system provides:

- **Separate iOS and Android build targets** for each app
- **Automated iOS code signing** for App Store distribution
- **Android APK and AAB (App Bundle)** builds
- **Simple Makefile interface** for common operations
- **Detailed build scripts** with progress feedback

## Prerequisites

### All Platforms

- Flutter SDK (3.13.0 or higher)
- Dart SDK (3.1.0 or higher)
- Git

### iOS Builds

- macOS with Xcode installed
- Valid Apple Developer account
- Code signing certificates and provisioning profiles configured
- Development Team ID: `WTCZNPDMRV` (configured in project)

### Android Builds

- Android SDK
- Android NDK (if using native code)
- Java JDK 11 or higher

## Quick Start

### View Available Commands

```bash
make help
```

### Build for Both Platforms

```bash
# FIT International Touch
make build-fit

# Touch Superleague UK
make build-tsl
```

### Build iOS Only (Code Signed)

```bash
# FIT International Touch
make build-fit-ios

# Touch Superleague UK
make build-tsl-ios

# All apps
make build-all-ios
```

### Build Android Only

```bash
# FIT International Touch
make build-fit-android

# Touch Superleague UK
make build-tsl-android

# All apps
make build-all-android
```

## Build Targets

### Available Make Targets

| Target | Description |
|--------|-------------|
| `make build-fit` | Build FIT app for both iOS and Android |
| `make build-fit-ios` | Build FIT app for iOS (code signed IPA) |
| `make build-fit-android` | Build FIT app for Android (APK + AAB) |
| `make build-tsl` | Build TSL app for both iOS and Android |
| `make build-tsl-ios` | Build TSL app for iOS (code signed IPA) |
| `make build-tsl-android` | Build TSL app for Android (APK + AAB) |
| `make build-all-ios` | Build all apps for iOS |
| `make build-all-android` | Build all apps for Android |

### App Directories

- **FIT International Touch**: `apps/internationaltouch`
- **Touch Superleague UK**: `apps/touch_superleague_uk`

## iOS Code Signing

### Overview

iOS builds are automatically code signed using Xcode's automatic code signing with your development team credentials.

### Configuration

Code signing is configured in:

1. **ExportOptions.plist**:
   - Location: Each app has its own at `apps/<app_name>/ios/ExportOptions.plist`
   - Fallback: Shared configuration at `ios/ExportOptions.plist`
   - Export method: `app-store`
   - Team ID: `WTCZNPDMRV`
   - Signing style: `automatic`
   - Bitcode: disabled (as required by Flutter)
   - Bundle IDs: Automatically detected from Xcode project (no hardcoding)

2. **Xcode Project** (in each app's `ios/Runner.xcodeproj/project.pbxproj`):
   - Development Team: `WTCZNPDMRV`
   - Bundle IDs:
     - FIT International Touch: `org.internationaltouch.mobile`
     - Touch Superleague UK: `uk.org.touchsuperleague.mobile`

### Requirements

Before building iOS apps, ensure:

1. **Xcode is installed** and configured
2. **You're signed in** to your Apple Developer account in Xcode
   - Xcode → Settings → Accounts
3. **Certificates are installed** in your keychain
4. **Provisioning profiles** are available (Xcode can download automatically)

### Build Process

The iOS build script (`scripts/build_ios.sh`) performs:

1. Clean previous builds
2. Get Flutter dependencies
3. Build Flutter iOS release
4. Create Xcode archive with code signing
5. Export signed IPA for App Store distribution

### Uploading to App Store

After building, you can upload the IPA using:

#### Option 1: Transporter.app (Recommended)

1. Open Transporter.app (comes with Xcode)
2. Drag and drop the IPA file
3. Click "Deliver"

#### Option 2: Command Line (xcrun altool)

```bash
# Validate the IPA
xcrun altool --validate-app \
  --type ios \
  --file build/ios/<app_name>/<app_name>.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID

# Upload the IPA
xcrun altool --upload-app \
  --type ios \
  --file build/ios/<app_name>/<app_name>.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

To get API keys:
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Users and Access → Keys
3. Generate a new key (App Manager role or higher)

## Android Build Types

The Android build script supports multiple build types:

### APK (Android Package)

- **Use case**: Direct installation, testing, third-party distribution
- **File**: `<app_name>-release.apk`
- **Build command**: `./scripts/build_android.sh apps/<app_name> apk`

### AAB (Android App Bundle)

- **Use case**: Google Play Store distribution (required)
- **File**: `<app_name>-release.aab`
- **Build command**: `./scripts/build_android.sh apps/<app_name> aab`
- **Benefits**: Smaller downloads, dynamic delivery, better optimization

### Both (Default)

- Builds both APK and AAB
- **Build command**: `./scripts/build_android.sh apps/<app_name> both`

## Build Scripts

### iOS Build Script

**Location**: `scripts/build_ios.sh`

**Usage**:
```bash
./scripts/build_ios.sh <app_directory> [scheme_name]

# Examples
./scripts/build_ios.sh apps/internationaltouch
./scripts/build_ios.sh apps/touch_superleague_uk Runner
```

**Features**:
- Colored console output
- Progress indicators
- Automatic code signing
- Error handling
- Output summary with file locations

### Android Build Script

**Location**: `scripts/build_android.sh`

**Usage**:
```bash
./scripts/build_android.sh <app_directory> [build_type]

# Examples
./scripts/build_android.sh apps/internationaltouch both
./scripts/build_android.sh apps/touch_superleague_uk apk
./scripts/build_android.sh apps/internationaltouch aab
```

**Features**:
- Colored console output
- Flexible build types (apk, aab, both)
- File size reporting
- Clear output organization

## Output Locations

All build outputs are organized in the `build/` directory:

```
build/
├── ios/
│   ├── internationaltouch/
│   │   ├── internationaltouch.ipa
│   │   └── internationaltouch.xcarchive/
│   └── touch_superleague_uk/
│       ├── touch_superleague_uk.ipa
│       └── touch_superleague_uk.xcarchive/
└── android/
    ├── internationaltouch/
    │   ├── internationaltouch-release.apk
    │   └── internationaltouch-release.aab
    └── touch_superleague_uk/
        ├── touch_superleague_uk-release.apk
        └── touch_superleague_uk-release.aab
```

### File Types

| Extension | Description | Platform |
|-----------|-------------|----------|
| `.ipa` | iOS App Package (code signed) | iOS |
| `.xcarchive` | Xcode Archive (for re-exporting) | iOS |
| `.apk` | Android Package (direct install) | Android |
| `.aab` | Android App Bundle (Play Store) | Android |

## Troubleshooting

### iOS Build Issues

#### Code Signing Failed

**Problem**: `Code signing failed` or `No matching provisioning profile found`

**Solutions**:
1. Open Xcode and go to Settings → Accounts
2. Select your Apple ID and download provisioning profiles
3. Open `ios/Runner.xcworkspace` in Xcode
4. Select the Runner target → Signing & Capabilities
5. Ensure "Automatically manage signing" is enabled
6. Verify your Team is selected

#### Archive Export Failed

**Problem**: Export fails with provisioning profile errors

**Solutions**:
1. Check `ios/ExportOptions.plist` has correct bundle ID
2. Ensure you have a valid App Store distribution certificate
3. Try opening the archive in Xcode:
   ```bash
   open build/ios/<app_name>/<app_name>.xcarchive
   ```
4. Export manually from Xcode to identify specific issues

#### Development Team Not Found

**Problem**: `Development team "WTCZNPDMRV" not found`

**Solution**:
1. Update the team ID in:
   - `ios/ExportOptions.plist`
   - `ios/Runner.xcodeproj/project.pbxproj`
2. Find your team ID in Xcode → Settings → Accounts

### Android Build Issues

#### Gradle Build Failed

**Problem**: Build fails with Gradle errors

**Solutions**:
1. Clean the build:
   ```bash
   cd apps/<app_name>
   flutter clean
   cd android
   ./gradlew clean
   ```
2. Update Gradle wrapper:
   ```bash
   cd apps/<app_name>/android
   ./gradlew wrapper --gradle-version=7.5
   ```

#### Out of Memory

**Problem**: `OutOfMemoryError` during build

**Solution**:
1. Increase heap size in `android/gradle.properties`:
   ```properties
   org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m
   ```

#### NDK Not Found

**Problem**: `NDK not found` error

**Solution**:
1. Install NDK via Android Studio SDK Manager
2. Or set NDK path in `android/local.properties`:
   ```properties
   ndk.dir=/path/to/ndk
   ```

### General Issues

#### Flutter Doctor Issues

Run Flutter doctor to check your environment:

```bash
flutter doctor -v
```

Address any issues reported.

#### Build Artifacts Not Found

If build completes but files are missing:

1. Check the exact error message in the build output
2. Look in the app's local build directory:
   - iOS: `apps/<app_name>/build/ios/`
   - Android: `apps/<app_name>/build/app/outputs/`
3. Ensure you have write permissions to the build directory

#### Permission Denied on Scripts

**Problem**: `Permission denied` when running scripts

**Solution**:
```bash
chmod +x scripts/build_ios.sh
chmod +x scripts/build_android.sh
```

## Continuous Integration

For CI/CD pipelines, you can use the build scripts directly:

### GitHub Actions Example (iOS)

```yaml
- name: Build iOS
  run: |
    ./scripts/build_ios.sh apps/internationaltouch
  env:
    MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
```

### GitHub Actions Example (Android)

```yaml
- name: Build Android
  run: |
    ./scripts/build_android.sh apps/internationaltouch both
```

## Version Management

To update app versions across all configurations:

```bash
# Edit version.json with new version
make sync-version
```

This updates:
- All `pubspec.yaml` files
- iOS `Info.plist` files
- Android `build.gradle` files

## Additional Resources

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Flutter Android Deployment](https://docs.flutter.dev/deployment/android)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Google Play Console](https://play.google.com/console)
- [Xcode Code Signing Guide](https://developer.apple.com/documentation/xcode/code-signing)

## Support

For issues or questions about the build system:

1. Check this documentation
2. Review the [Troubleshooting](#troubleshooting) section
3. Check Flutter and Xcode documentation
4. Contact the development team

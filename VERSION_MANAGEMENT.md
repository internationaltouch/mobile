# Version Management

This repository uses a centralized version management system to keep all app versions synchronized.

## Overview

All app versions are controlled by a single source of truth: `version.json` in the repository root.

```json
{
  "version": "1.0.0",
  "buildNumber": 6,
  "description": "Centralized version configuration for all apps"
}
```

## How It Works

1. **Single Source of Truth**: `version.json` contains the version and build number
2. **Automatic Sync**: A script propagates changes to all `pubspec.yaml` files
3. **Platform Native**: iOS and Android read from their respective `pubspec.yaml` files via Flutter's build system

### Version Flow

```
version.json
    ↓
    ├─→ pubspec.yaml (root)
    ├─→ apps/internationaltouch/pubspec.yaml
    └─→ apps/touch_superleague_uk/pubspec.yaml
           ↓
           ├─→ iOS (Info.plist via FLUTTER_BUILD_NAME/NUMBER)
           └─→ Android (build.gradle via flutter.versionName/Code)
```

## Updating Versions

### Method 1: Using Make (Recommended)

1. Edit `version.json` to update the version or build number:
   ```json
   {
     "version": "1.0.1",
     "buildNumber": 7
   }
   ```

2. Run the sync command:
   ```bash
   make sync-version
   ```

### Method 2: Using Dart Directly

```bash
dart scripts/sync_versions.dart
```

### Method 3: Manual (Not Recommended)

If you must update manually, you need to update these files:
- `version.json`
- `pubspec.yaml` (root)
- `apps/internationaltouch/pubspec.yaml`
- `apps/touch_superleague_uk/pubspec.yaml`

**Warning**: Manual updates are error-prone. Use the automated script instead.

## Version Format

Flutter uses the format: `version+buildNumber`

- **version**: Semantic version (e.g., `1.0.0`)
- **buildNumber**: Integer that increments with each build (e.g., `6`)
- **Combined**: `1.0.0+6`

### When to Increment

#### Version Number
Increment according to [Semantic Versioning](https://semver.org/):
- **MAJOR** (`2.0.0`): Breaking changes
- **MINOR** (`1.1.0`): New features, backward compatible
- **PATCH** (`1.0.1`): Bug fixes, backward compatible

#### Build Number
- Increment for **every** build submitted to App Store or Play Store
- Should always increase, never decrease
- Independent of version number changes

### Examples

```json
// Initial release
{"version": "1.0.0", "buildNumber": 1}

// Bug fix release
{"version": "1.0.1", "buildNumber": 2}

// Second build of same version (rejected, resubmitted)
{"version": "1.0.1", "buildNumber": 3}

// New feature release
{"version": "1.1.0", "buildNumber": 4}

// Another bug fix
{"version": "1.1.1", "buildNumber": 5}
```

## Best Practices

1. **Always sync after updating** `version.json`
2. **Increment build number** for every App Store/Play Store submission
3. **Use semantic versioning** for the version number
4. **Never reuse build numbers** - they should always increment
5. **Commit version changes** separately from feature changes

## CI/CD Integration

You can integrate version syncing into your CI/CD pipeline:

```yaml
# Example GitHub Actions workflow
- name: Sync versions
  run: make sync-version
  
- name: Build apps
  run: |
    make build-fit
    make build-tsl
```

## Troubleshooting

### Version not updating in built app

1. Verify `version.json` has correct values
2. Run `make sync-version`
3. Check that all `pubspec.yaml` files have matching versions
4. Clean and rebuild: `make clean && make build-fit`

### Script fails to find files

Ensure you run the script from the repository root:
```bash
cd /path/to/white-label-mobile
make sync-version
```

## Platform-Specific Details

### iOS
- **CFBundleShortVersionString**: Maps to version (e.g., `1.0.0`)
- **CFBundleVersion**: Maps to build number (e.g., `6`)
- Automatically set via `$(FLUTTER_BUILD_NAME)` and `$(FLUTTER_BUILD_NUMBER)`

### Android
- **versionName**: Maps to version (e.g., `1.0.0`)
- **versionCode**: Maps to build number (e.g., `6`)
- Automatically set via `flutter.versionName` and `flutter.versionCode`

Both platforms read from their respective app's `pubspec.yaml` file during the Flutter build process.

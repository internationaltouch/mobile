# App Configuration System

This document describes how to configure the mobile app for different organizations and use cases.

## Overview

The app now supports a comprehensive configuration system that allows you to customize:

1. **App Identity** - Name, identifier, and branding
2. **Navigation** - Tab visibility and labels
3. **Branding** - Colors, logos, and themes
4. **Features** - Country flags and specialized functionality
5. **Assets** - Images, icons, and splash screens

## Configuration File

The main configuration is located in `assets/config/app_config.json`. This JSON file contains all configurable aspects of the app.

### Configuration Structure

```json
{
  "app": {
    "name": "FIT",
    "displayName": "FIT", 
    "description": "FIT - International Touch tournaments and events",
    "identifier": {
      "android": "org.internationaltouch.fit",
      "ios": "org.internationaltouch.fit"
    },
    "version": "1.0.0+6"
  },
  "api": {
    "baseUrl": "https://www.internationaltouch.org/api/v1",
    "imageBaseUrl": "https://www.internationaltouch.org"
  },
  "branding": {
    "primaryColor": "#003A70",
    "secondaryColor": "#F6CF3F", 
    "accentColor": "#73A950",
    "errorColor": "#B12128",
    "backgroundColor": "#FFFFFF",
    "textColor": "#222222",
    "logoVertical": "assets/images/LOGO_FIT-VERT.png",
    "logoHorizontal": "assets/images/LOGO_FIT-HZ.png",
    "appIcon": "assets/images/icon.png",
    "splashScreen": {
      "backgroundColor": "#FFFFFF",
      "image": "assets/images/LOGO_FIT-VERT.png",
      "imageBackgroundColor": "#FFFFFF"
    }
  },
  "navigation": {
    "tabs": [
      {
        "id": "news",
        "label": "News",
        "icon": "newspaper",
        "enabled": true,
        "backgroundColor": "#003A70"
      },
      {
        "id": "clubs",
        "label": "Member Nations",
        "icon": "public",
        "enabled": true,
        "backgroundColor": "#003A70"
      },
      {
        "id": "events",
        "label": "Events",
        "icon": "sports", 
        "enabled": true,
        "backgroundColor": "#003A70",
        "variant": "standard"
      },
      {
        "id": "my_sport",
        "label": "My Touch",
        "icon": "star",
        "enabled": true,
        "backgroundColor": "#003A70"
      }
    ]
  },
  "features": {
    "flagsModule": "fit",
    "eventsVariant": "standard"
  },
  "assets": {
    "competitionImages": "assets/images/competitions/",
    "flagsPath": "lib/config/flags/fit_flags.dart"
  }
}
```

## Creating a Custom Configuration

To create a variant of the app for a different organization:

### 1. Create a New Configuration File

Copy `assets/config/app_config.json` to a new file, for example `assets/config/rugby_world_config.json`.

### 2. Customize the Configuration

#### App Identity
```json
{
  "app": {
    "name": "RugbyWorld",
    "displayName": "Rugby World",
    "description": "Rugby World - International Rugby tournaments and events",
    "identifier": {
      "android": "org.rugbyworld.app",
      "ios": "org.rugbyworld.app"
    }
  }
}
```

#### Branding
```json
{
  "branding": {
    "primaryColor": "#006400",
    "secondaryColor": "#FFD700",
    "accentColor": "#FF4500",
    "logoVertical": "assets/images/RUGBY_LOGO_VERT.png",
    "logoHorizontal": "assets/images/RUGBY_LOGO_HZ.png",
    "appIcon": "assets/images/rugby_icon.png"
  }
}
```

#### Navigation Tabs
```json
{
  "navigation": {
    "tabs": [
      {
        "id": "news",
        "label": "News",
        "icon": "newspaper",
        "enabled": true
      },
      {
        "id": "clubs", 
        "label": "Clubs",
        "icon": "public",
        "enabled": true
      },
      {
        "id": "events",
        "label": "Tournaments",
        "icon": "sports",
        "enabled": true,
        "variant": "favorites"
      },
      {
        "id": "my_sport",
        "label": "My Rugby",
        "icon": "star", 
        "enabled": false
      }
    ]
  }
}
```

### 3. Create Custom Flag Module (Optional)

If you need different country flag mappings:

1. Create `lib/config/flags/rugby_flags.dart`
2. Extend `FlagsInterface` with your custom mappings
3. Update the flags factory to support your module
4. Set `"flagsModule": "rugby"` in your config

### 4. Add Custom Assets

1. Place your logos in the `assets/images/` directory
2. Update the asset paths in your configuration
3. Add the assets to `pubspec.yaml` if needed

## Building with Different Configurations

### Method 1: Replace Configuration File

1. Copy your custom config to `assets/config/app_config.json`
2. Run `flutter build` as normal

### Method 2: Load Different Configuration (Advanced)

The app supports loading different configurations at runtime:

```dart
// In main.dart or initialization code
await ConfigService.loadConfig('assets/config/rugby_world_config.json');
```

## Configuration Properties Reference

### App Section
- `name`: Internal app name
- `displayName`: User-facing app title 
- `description`: App description
- `identifier`: Platform-specific app identifiers
- `version`: App version

### API Section  
- `baseUrl`: Main API endpoint
- `imageBaseUrl`: Base URL for images

### Branding Section
- `primaryColor`: Main brand color (hex)
- `secondaryColor`: Accent color (hex)  
- `accentColor`: Additional accent color (hex)
- `errorColor`: Error state color (hex)
- `backgroundColor`: Background color (hex)
- `textColor`: Main text color (hex)
- `logoVertical`: Path to vertical logo
- `logoHorizontal`: Path to horizontal logo
- `appIcon`: Path to app icon
- `splashScreen`: Splash screen configuration

### Navigation Section
- `tabs`: Array of tab configurations
  - `id`: Internal tab identifier
  - `label`: Display label
  - `icon`: Icon name (Material Icons)
  - `enabled`: Whether tab is visible
  - `backgroundColor`: Tab background color
  - `variant`: Special behavior variant

### Features Section
- `flagsModule`: Which flags module to use
- `eventsVariant`: Events view variant

### Assets Section  
- `competitionImages`: Competition images directory
- `flagsPath`: Path to flags module

## Tab Configuration Options

### Available Tab IDs
- `news`: News/announcements 
- `clubs`: Organizations/teams
- `events`: Competitions/tournaments
- `my_sport`: Personal/favorites view

### Available Icons
- `newspaper`: News icon
- `public`: Globe icon
- `sports`: Sports icon
- `star`: Star icon
- `help`: Help icon

### Event Variants
- `standard`: Normal events list
- `favorites`: Shows favorites/personal events

## Splash Screen Configuration

The app can generate platform-specific splash screen configs:

```dart
import 'package:your_app/config/splash_config_generator.dart';

await SplashConfigGenerator.generateSplashConfig(
  outputPath: 'splash_config.yaml'
);
```

Then run:
```bash
flutter packages pub run flutter_native_splash:create --config=splash_config.yaml
```

## Testing Configurations

1. Validate JSON syntax with a JSON validator
2. Ensure all asset paths exist
3. Test color values are valid hex codes
4. Verify API endpoints are accessible
5. Test with both enabled and disabled tabs

## Best Practices

1. **Version Control**: Keep configurations in version control
2. **Asset Management**: Use consistent naming for assets
3. **Color Consistency**: Use a defined color palette
4. **Testing**: Test thoroughly with each configuration
5. **Documentation**: Document customizations for each variant
6. **Backup**: Keep backups of working configurations

## Troubleshooting

### Common Issues

**Configuration not loading**: 
- Check JSON syntax
- Verify file path in assets
- Ensure pubspec.yaml includes config assets

**Assets not found**:
- Check asset paths in configuration
- Verify files exist in specified locations
- Update pubspec.yaml assets section

**Colors not applying**:
- Verify hex color format (#RRGGBB)
- Check color values are valid
- Restart app after configuration changes

**Tabs not showing**:
- Check `enabled: true` for desired tabs
- Verify tab IDs match expected values
- Check for JSON syntax errors in tabs array
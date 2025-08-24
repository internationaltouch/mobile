# Background Updates for Competitions

This document describes the periodic background update system that monitors competitions in progress and sends notifications for changes to favourited teams.

## Overview

The background update system automatically checks for updates to competitions that have matches within +/- 12 hours of the current time. It focuses on divisions that contain teams marked as favourites by the user and sends push notifications when significant changes occur.

## Key Components

### 1. BackgroundUpdateService

**Location**: `lib/services/background_update_service.dart`

**Features**:
- Runs periodic updates every 2 minutes when the app is active
- Automatically starts when app becomes active, stops when app goes to background
- Filters to only check divisions with favourited teams
- Monitors matches within 12-hour window around current time
- Detects changes and triggers notifications

**Key Methods**:
- `initialize()` - Sets up the service and notification permissions
- `startPeriodicUpdates()` - Begins periodic checking
- `stopPeriodicUpdates()` - Stops periodic checking
- `isRunning` - Property to check if updates are active

### 2. NotificationService

**Location**: `lib/services/notification_service.dart`

**Features**:
- Cross-platform local notifications (Android, iOS, macOS)
- Specific notification types for different update scenarios
- Permission handling and user-friendly messaging

**Notification Types**:
- **Fixture Updates**: Score changes, match completion, new matches
- **Team Updates**: Ladder position changes for favourited teams

### 3. Integration Points

**Main App Integration**:
- `lib/main.dart` - Initializes background service on app startup
- `lib/views/main_navigation_view.dart` - Manages service lifecycle based on app state

**Data Service Updates**:
- `lib/services/data_service.dart` - Enhanced with `forceRefresh` parameter for background updates

## How It Works

### Update Cycle

1. **Timer Triggers**: Every 2 minutes when app is active
2. **Check Favourites**: Retrieves user's favourited teams and divisions
3. **Filter Divisions**: Only processes divisions containing favourited items
4. **Time Window**: Focuses on matches within +/- 12 hours of current time
5. **Compare Data**: Fetches fresh data and compares with cached versions
6. **Detect Changes**: Identifies score updates, completion status, ladder positions
7. **Send Notifications**: Notifies user of relevant changes

### Change Detection

**Fixture Changes**:
- New matches scheduled involving favourited teams
- Score updates (goals/points changes)
- Match completion status changes

**Ladder Changes**:
- Position changes for favourited teams in league tables
- Calculated from match results and standings

### Smart Filtering

The system is designed to be efficient:
- Only checks divisions with user favourites
- Only monitors recent/upcoming matches (12-hour window)
- Skips updates if no favourites are configured
- Uses cached data as baseline for change detection

## Usage

### For Users

1. **Add Favourites**: Use the "My Touch" tab to add favourite teams
2. **Enable Notifications**: Grant notification permissions when prompted
3. **Automatic Updates**: System runs automatically when app is active
4. **Receive Alerts**: Get notified of score changes and ladder movements

### For Developers

**Starting Updates**:
```dart
await BackgroundUpdateService.initialize();
BackgroundUpdateService.startPeriodicUpdates();
```

**Stopping Updates**:
```dart
BackgroundUpdateService.stopPeriodicUpdates();
```

**Checking Status**:
```dart
bool isActive = BackgroundUpdateService.isRunning;
Duration interval = BackgroundUpdateService.updateInterval;
```

## Configuration

### Update Frequency
- **Current**: 2 minutes (when app is active)
- **Rationale**: Balances timely updates with API usage and battery life
- **Platform Limits**: Respects platform-specific background execution limits

### Time Window
- **Current**: +/- 12 hours from current time
- **Rationale**: Captures recent completed matches and upcoming fixtures
- **Configurable**: Can be adjusted in `BackgroundUpdateService._matchTimeWindow`

### Notification Channels
- **Fixture Updates**: High priority, sound and vibration
- **Team Updates**: High priority, sound and vibration
- **Permissions**: Requests alert, badge, and sound permissions

## Platform Support

### Mobile Platforms
- ✅ **Android**: Full support with local notifications
- ✅ **iOS**: Full support with local notifications  
- ✅ **macOS**: Full support with local notifications

### Web Platform
- ❌ **Web**: Not supported (SQLite database not available)

## Performance Considerations

### API Efficiency
- Only checks divisions with favourites (reduces unnecessary API calls)
- Uses time window filtering (reduces data processing)
- Leverages existing cache system (minimizes redundant requests)

### Battery Impact
- Updates only run when app is active (no true background processing)
- Timer-based approach (more efficient than continuous polling)
- Smart filtering reduces actual work performed

### Memory Usage
- Minimal memory footprint (stateless service design)
- Efficient data structures for change detection
- Automatic cleanup when service stops

## Error Handling

### Network Issues
- Graceful degradation when API is unavailable
- Falls back to cached data when possible
- Comprehensive logging for debugging

### Permission Issues
- Graceful handling of denied notification permissions
- Continues monitoring even if notifications are disabled
- Clear user feedback about permission status

### Data Issues
- Robust parsing of API responses
- Safe handling of malformed or missing data
- Fallback mechanisms for critical operations

## Future Enhancements

### Potential Improvements
1. **True Background Processing**: Use platform-specific background task APIs
2. **Smarter Frequency**: Adaptive update intervals based on match timing
3. **Push Notifications**: Server-side push notifications for better efficiency
4. **Customizable Notifications**: User preferences for notification types
5. **Historical Tracking**: Change history and statistics

### Implementation Considerations
- Platform-specific background execution limits
- Battery optimization requirements
- User privacy and data usage concerns
- Scalability for large numbers of favourites

## Testing

### Manual Testing
1. Add favourite teams in different divisions
2. Monitor console logs for update activity
3. Verify notifications appear for actual changes
4. Test app lifecycle (foreground/background transitions)

### Automated Testing
- Unit tests for core service functionality
- Integration tests for notification delivery
- Performance tests for update efficiency

See `test/services/background_update_service_test.dart` for basic test examples.
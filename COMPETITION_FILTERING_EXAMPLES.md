# Competition Filtering Examples

This document demonstrates how to use the new competition filtering system in `lib/views/competitions_view.dart`.

## Usage Modes

### 1. Show ALL competitions (No filtering)
```dart
static const List<String> _includeCompetitionSlugs = [];
static const List<String> _excludeCompetitionSlugs = [];
```

### 2. INCLUDE Mode - Only show specific competitions
```dart
static const List<String> _includeCompetitionSlugs = [
  'fit-world-cup-2023',
  'european-championships',
  'asia-pacific-championships',
];
static const List<String> _excludeCompetitionSlugs = [];
```
**Result**: Only shows competitions with those 3 specific slugs

### 3. EXCLUDE Mode - Hide specific competitions
```dart
static const List<String> _includeCompetitionSlugs = [];
static const List<String> _excludeCompetitionSlugs = [
  'old-tournament-2019',
  'cancelled-event-2020',
  'test-competition',
];
```
**Result**: Shows all competitions EXCEPT those 3 specific slugs

## Error Prevention

The system prevents configuration errors:

### ❌ INVALID - Both modes used simultaneously
```dart
static const List<String> _includeCompetitionSlugs = ['world-cup'];
static const List<String> _excludeCompetitionSlugs = ['old-event'];
```
**Result**: Throws configuration error at runtime

## Common Use Cases

### Show only current/active competitions
```dart
static const List<String> _includeCompetitionSlugs = [
  'world-cup-2024',
  'european-champs-2024',
  'asia-pacific-2024',
];
```

### Hide old/cancelled competitions
```dart
static const List<String> _excludeCompetitionSlugs = [
  'world-cup-2019',
  'cancelled-event-2020',
  'test-tournament',
];
```

## Best Practices

1. **Use INCLUDE mode** when you want to show only a few specific competitions
2. **Use EXCLUDE mode** when you want to hide only a few competitions from many
3. **Use no filtering** during development to see all available competitions
4. **Comment out unused arrays** to make your configuration clear
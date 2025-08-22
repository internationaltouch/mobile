# My Touch Navigation Test Cases

## Test Scenarios

### Scenario 1: Competition Favourite Navigation
**Given:** User has saved "World Cup 2024" as a competition favourite
**When:** User taps on the competition favourite in My Touch tab
**Expected:** 
- App switches to Competitions tab
- Opens EventDetailView showing "World Cup 2024"
- User can select a season to proceed

**Data Structure:**
```json
{
  "id": "comp_world-cup-2024",
  "type": "competition", 
  "competition_slug": "world-cup-2024",
  "competition_name": "World Cup 2024",
  "season_slug": null,
  "season_name": null,
  "division_slug": null,
  "division_name": null,
  "team_id": null,
  "team_name": null
}
```

### Scenario 2: Season Favourite Navigation
**Given:** User has saved "World Cup 2024 - Men's Division" as a season favourite
**When:** User taps on the season favourite
**Expected:**
- App switches to Competitions tab
- Opens DivisionsView showing divisions for "World Cup 2024 - Men's Division"
- User can select a division to see fixtures

**Data Structure:**
```json
{
  "id": "season_world-cup-2024_mens-division",
  "type": "season",
  "competition_slug": "world-cup-2024", 
  "competition_name": "World Cup 2024",
  "season_slug": "mens-division",
  "season_name": "Men's Division",
  "division_slug": null,
  "division_name": null,
  "team_id": null,
  "team_name": null
}
```

### Scenario 3: Division Favourite Navigation
**Given:** User has saved "World Cup 2024 - Men's Division - Open Mixed" as a division favourite
**When:** User taps on the division favourite
**Expected:**
- App switches to Competitions tab
- Opens FixturesResultsView showing fixtures and ladder for "Open Mixed"
- User sees all fixtures/results for that division

**Data Structure:**
```json
{
  "id": "div_world-cup-2024_mens-division_open-mixed",
  "type": "division",
  "competition_slug": "world-cup-2024",
  "competition_name": "World Cup 2024", 
  "season_slug": "mens-division",
  "season_name": "Men's Division",
  "division_slug": "open-mixed",
  "division_name": "Open Mixed",
  "team_id": null,
  "team_name": null
}
```

### Scenario 4: Team Favourite Navigation
**Given:** User has saved "Australia" team as a favourite
**When:** User taps on the team favourite
**Expected:**
- App switches to Competitions tab
- Opens FixturesResultsView for the team's division
- **Team "Australia" is automatically pre-selected in the team filter dropdown**
- Fixtures are automatically filtered to show only "Australia" team matches
- User can change team filter or select "All Teams" to see other fixtures

**Data Structure:**
```json
{
  "id": "team_world-cup-2024_mens-division_open-mixed_australia-123",
  "type": "team",
  "competition_slug": "world-cup-2024",
  "competition_name": "World Cup 2024",
  "season_slug": "mens-division", 
  "season_name": "Men's Division",
  "division_slug": "open-mixed",
  "division_name": "Open Mixed",
  "team_id": "australia-123",
  "team_name": "Australia"
}
```

## Identified Issues to Fix

1. **Tab Switching Context**: Navigator.push from My Touch tab might not work correctly when switching to Competitions tab
2. **Object Construction**: Event/Division objects might be missing required fields
3. **Navigation Stack**: Deep navigation might not maintain proper back button behavior
4. **Error Handling**: Need to handle cases where competitions/seasons/divisions don't exist
5. **Timing Issues**: Tab switch and navigation might have race conditions

## Fixes Applied ✅

1. ✅ **Navigation Context**: Added `switchToTabAndNavigate()` extension method to properly switch to Competitions tab and navigate using the correct Navigator
2. ✅ **Model Construction**: Fixed Event and Division object construction with all required fields including default values
3. ✅ **Tab Switching**: Implemented proper tab switching with post-frame callback to ensure navigation happens after tab switch completes
4. ✅ **Error Handling**: Added comprehensive try-catch blocks with user-friendly error messages
5. ✅ **Data Validation**: Season title/slug conversion handled by DataService's internal helper methods
6. ✅ **Navigation Stack**: Each navigation properly uses the Competitions tab's navigator stack for correct back button behavior
7. ✅ **Team Pre-selection**: Team shortcuts now automatically pre-select the team in the fixtures filter dropdown

## Technical Implementation

### MainNavigationView Extensions
```dart
// Added to MainNavigationView
void navigateInTab(int tabIndex, Widget destination)
void switchToTabAndNavigate(int tabIndex, Widget destination)
```

### MyTouchView Navigation Flow
```dart
void _navigateToFavourite(Map<String, dynamic> favourite) {
  // 1. Create proper Event/Division objects from favourite data
  // 2. Switch to Competitions tab (index 1) and navigate in one operation
  context.switchToTabAndNavigate(1, destinationView);
}
```

### Expected Results
- ✅ Clean tab switching with proper navigation stack
- ✅ Correct back button behavior 
- ✅ No navigation context mismatches
- ✅ Proper model object construction
- ✅ Error handling for edge cases
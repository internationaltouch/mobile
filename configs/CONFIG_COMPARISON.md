# Configuration Comparison: FIT vs Touch Superleague

## Overview
This document compares the configuration differences between the two primary implementations of the Touch mobile framework.

## Extracted Configurations

- **FIT (International Touch)**: `fit_app_config.json`
- **Touch Superleague UK**: `touchsuperleague_app_config.json`

## Key Differences

### App Identity

| Field | FIT | Touch Superleague |
|-------|-----|-------------------|
| **Name** | FIT | Touch Superleague |
| **Display Name** | FIT | Touch Superleague |
| **Description** | FIT - International Touch tournaments and events | Touch Superleague |
| **Android ID** | org.internationaltouch.fit | uk.org.touchsuperleague.mobile |
| **iOS ID** | org.internationaltouch.fit | uk.org.touchsuperleague.mobile |

### API Endpoints

| Field | FIT | Touch Superleague |
|-------|-----|-------------------|
| **Base URL** | https://www.internationaltouch.org/api/v1 | https://www.touchsuperleague.org.uk/api/v1 |
| **Image Base URL** | https://www.internationaltouch.org | https://www.touchsuperleague.org.uk |

### Branding Colors

| Element | FIT | Touch Superleague |
|---------|-----|-------------------|
| **Primary Color** | #003A70 (Dark Blue) | #0993b8 (Teal/Cyan) |
| **Secondary Color** | #F6CF3F (Gold/Yellow) | #0993b8 (Teal/Cyan) |
| **Accent Color** | #73A950 (Green) | #0993b8 (Teal/Cyan) |
| **Error Color** | #B12128 (Red) | #B12128 (Red) - Same |
| **Background** | #FFFFFF (White) | #FFFFFF (White) - Same |
| **Text Color** | #222222 (Dark Gray) | #222222 (Dark Gray) - Same |

**Visual Identity:**
- **FIT**: Classic sports organization look with dark blue, gold, and green
- **Touch Superleague**: Modern, unified teal/cyan branding

### Logo Assets

| Asset | FIT | Touch Superleague |
|-------|-----|-------------------|
| **Logo Vertical** | assets/images/LOGO_FIT-VERT.png | assets/images/touch-superleague-logo.png |
| **Logo Horizontal** | assets/images/LOGO_FIT-HZ.png | assets/images/touch-superleague-logo.png |
| **App Icon** | assets/images/icon.png | assets/images/touch-superleague-logo.png |
| **Splash Image** | assets/images/LOGO_FIT-VERT.png | assets/images/touch-superleague-logo.png |

### Navigation Tabs

#### FIT (4 tabs)
1. **News** - "News" label
2. **Clubs** - "Member Nations" label (customized for FIT's international model)
3. **Events** - "Events" label
4. **My Touch** - "My Touch" label (renamed from default Favorites)

#### Touch Superleague (2 tabs)
1. **Events** - "Events" label
2. **Favorites** - "Favorites" label

**Key Differences:**
- FIT has News and Clubs/Member Nations tabs enabled
- Touch Superleague has a minimal navigation focused on Events and Favorites
- FIT uses "Member Nations" terminology for clubs (international focus)
- FIT uses "My Touch" branding for favorites

### Tab Background Colors

| Tab | FIT | Touch Superleague |
|-----|-----|-------------------|
| All tabs | #003A70 (Dark Blue) | #0993b8 (Teal) |

Both apps use consistent colors across all tabs, but different brand colors.

### Features Configuration

#### Clubs/Member Nations

| Field | FIT | Touch Superleague |
|-------|-----|-------------------|
| **Navigation Label** | "Member Nations" | "Clubs" |
| **Title Bar Text** | "Member Nations" | "Clubs" |
| **Allowed Statuses** | ["active"] | ["active"] - Same |
| **Excluded Slugs** | [] | [] - Same |

**Key Difference:** FIT uses "Member Nations" terminology reflecting its international/national team focus.

#### Competition Filtering

**FIT:**
- No competitions excluded
- All seasons and divisions shown

**Touch Superleague:**
- Excludes: `["cardiff-touch-superleague", "jersey-touch-superleague"]`
- Strategic filtering to show only UK-wide competitions

**Filtering Strategy:**
- FIT: Inclusive (show everything)
- Touch Superleague: Exclusive (hide regional variants)

### Assets Configuration

| Field | FIT | Touch Superleague |
|-------|-----|-------------------|
| **Flags Module** | "fit" | "fit" - Same |
| **Events Variant** | "standard" | "standard" - Same |
| **Competition Images Path** | assets/images/competitions/ | assets/images/competitions/ - Same |
| **Flags Path** | lib/config/flags/fit_flags.dart | lib/config/flags/fit_flags.dart - Same |

Both apps use the same flag/entity image system currently.

## Configuration Philosophy

### FIT (International Touch)
- **Comprehensive**: All features enabled
- **International Focus**: "Member Nations" terminology
- **Brand-Heavy**: Three distinct brand colors (blue, gold, green)
- **Content-Rich**: Four navigation tabs including News
- **Inclusive Filtering**: Show all competitions

### Touch Superleague UK
- **Streamlined**: Minimal navigation (Events + Favorites only)
- **Regional Focus**: UK-specific with exclusions for sub-regional competitions
- **Unified Branding**: Single teal color throughout
- **Competition-Focused**: Emphasis on events over content
- **Exclusive Filtering**: Strategic hiding of regional variants

## Use Case Implications

### FIT App
**Target Audience:** International touch community, national federations, tournament attendees
**Primary Use Cases:**
- Following international news and announcements
- Viewing member nation information
- Tracking major international tournaments
- Managing personal favorites across events

**Navigation Style:** Content portal with news, directory, events, and personalization

### Touch Superleague UK App
**Target Audience:** UK-based touch players and fans
**Primary Use Cases:**
- Checking league fixtures and results
- Following favorite teams
- Viewing league standings

**Navigation Style:** Focused competition tracker with minimal distractions

## Migration Considerations

### Adding News to Touch Superleague
If Touch Superleague wants to add news:
1. Enable news tab in navigation
2. Configure news API path
3. Add news icon/branding
4. Test with Touch Superleague news content

### Adding Clubs to Touch Superleague
If Touch Superleague wants to add clubs:
1. Enable clubs tab in navigation
2. Use "Clubs" terminology (not "Member Nations")
3. Configure any club-specific filtering
4. Add club logos if needed

### Replicating FIT Setup for Other Organizations
Organizations wanting FIT-style apps should:
1. Enable all four tabs (news, clubs, events, favorites)
2. Customize terminology (e.g., "Member Nations" vs "Clubs")
3. Configure brand colors (3+ colors for visual variety)
4. Set up competition filtering strategy
5. Prepare logo assets (vertical and horizontal variants)

## Future Enhancements

### Per-Organization Customizations Needed
1. **Entity Images**: Allow non-FIT apps to define custom entity image providers
   - Team logos, club emblems, organization badges
   - Not all apps need flags
2. **News Sources**: Support multiple news backends (RSS, REST API, CMS)
3. **Club Directories**: Configurable club taxonomies (nations vs clubs vs affiliates)
4. **Competition Hierarchies**: Different competition structures per organization

### Framework Improvements
1. **Validation**: JSON schema validation for configurations
2. **Defaults**: Smarter defaults for optional fields
3. **Templates**: Configuration templates for common use cases
4. **Documentation**: Interactive config builder tool

## Conclusion

The two configurations demonstrate the framework's flexibility:
- **FIT**: Full-featured international sports portal
- **Touch Superleague**: Streamlined competition tracker

The differences in branding, navigation, terminology, and filtering show how the white label framework adapts to different organizational needs while maintaining the same core codebase.

---

**Files:**
- `configs/fit_app_config.json` - FIT configuration
- `configs/touchsuperleague_app_config.json` - Touch Superleague configuration
- `assets/config/app_config.json` - Current active configuration (Touch Superleague)

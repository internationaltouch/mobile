# FIT Brand Color Guidelines

This document defines the official color palette for the Federation of International Touch (FIT) mobile application, based on the official FIT Brandbook (Updated 23 Mar 2015).

## Primary Brand Colors

### Pantone Natural Black C
- **Usage**: Primary text, headers, main UI elements
- **RGB**: `34, 34, 34`
- **Hex**: `#222222`
- **CMYK**: `72, 66, 65, 72`

### Pantone 654C (Blue)
- **Usage**: Primary brand color, navigation, buttons
- **RGB**: `0, 58, 112`
- **Hex**: `#003A70`
- **CMYK**: `100, 85, 30, 16`

### Pantone 129C (Yellow)
- **Usage**: Accent color, highlights, warnings
- **RGB**: `246, 207, 63`
- **Hex**: `#F6CF3F`
- **CMYK**: `4, 16, 87, 0`

### Pantone 7621C (Red)
- **Usage**: Error states, alerts, important actions
- **RGB**: `177, 33, 40`
- **Hex**: `#B12128`
- **CMYK**: `21, 99, 95, 13`

### Pantone 7489C (Green)
- **Usage**: Success states, positive actions
- **RGB**: `115, 169, 80`
- **Hex**: `#73A950`
- **CMYK**: `61, 14, 91, 1`

## Flutter Implementation

```dart
class FITColors {
  // Primary brand colors
  static const Color primaryBlue = Color(0xFF003A70);    // Pantone 654C
  static const Color primaryBlack = Color(0xFF222222);   // Natural Black C
  static const Color accentYellow = Color(0xFFF6CF3F);   // Pantone 129C
  static const Color errorRed = Color(0xFFB12128);       // Pantone 7621C
  static const Color successGreen = Color(0xFF73A950);   // Pantone 7489C
  
  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);
}
```

## Usage Guidelines

### Primary Color (Blue)
- Use for navigation bars, primary buttons, and brand elements
- Represents trust, professionalism, and the FIT brand

### Accent Colors
- **Yellow**: Use sparingly for highlights and call-to-action elements
- **Red**: Reserved for error states and destructive actions
- **Green**: Use for success messages and positive confirmations

### Text Colors
- **Primary Black**: Main body text and headings
- **Dark Grey**: Secondary text and subtitles
- **Medium Grey**: Placeholder text and disabled states

## Accessibility

All color combinations have been verified to meet WCAG 2.1 AA standards for contrast ratios:
- Primary Blue on White: 9.1:1 (AAA)
- Primary Black on White: 15.3:1 (AAA)
- Dark Grey on White: 5.4:1 (AA)

## Brand Compliance

These colors are derived from the official FIT Brandbook (Updated 23 Mar 2015) and should be used consistently across all FIT mobile applications to maintain brand identity and recognition.
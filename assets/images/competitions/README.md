# Competition Images

This folder contains static image assets for competition logos.

## Adding Competition Images

1. **Image Requirements:**
   - Format: PNG (recommended) or JPG
   - Size: Square aspect ratio (e.g., 512x512px)
   - Quality: High resolution for crisp display on all devices

2. **File Naming:**
   - Use descriptive names that match your competition slugs
   - Examples: `world_cup.png`, `european_champs.png`, `asia_pacific.png`

3. **Configuration:**
   - After adding images here, update the `_competitionImages` map in `lib/views/competitions_view.dart`
   - Map format: `'competition-slug': 'assets/images/competitions/filename.png'`
   - Optionally configure filtering using either `_includeCompetitionSlugs` or `_excludeCompetitionSlugs`

4. **pubspec.yaml Configuration:**
   Make sure your `pubspec.yaml` includes:
   ```yaml
   flutter:
     assets:
       - assets/images/competitions/
   ```

## Example Files
Add your competition image files here following the naming convention described above.
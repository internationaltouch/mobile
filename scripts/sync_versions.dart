#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

/// Syncs version numbers from version.json to all pubspec.yaml files in the repository
void main(List<String> args) async {
  final versionFile = File('version.json');

  if (!versionFile.existsSync()) {
    print('❌ Error: version.json not found in the repository root');
    exit(1);
  }

  // Read version configuration
  final versionJson = jsonDecode(await versionFile.readAsString());
  final version = versionJson['version'] as String;
  final buildNumber = versionJson['buildNumber'] as int;
  final versionString = '$version+$buildNumber';

  print('📦 Syncing versions to: $versionString');
  print('   Version: $version');
  print('   Build Number: $buildNumber');
  print('');

  // List of pubspec.yaml files to update
  final pubspecPaths = [
    'pubspec.yaml',
    'apps/internationaltouch/pubspec.yaml',
    'apps/touch_superleague_uk/pubspec.yaml',
  ];

  var updatedCount = 0;
  var skippedCount = 0;

  for (final path in pubspecPaths) {
    final file = File(path);

    if (!file.existsSync()) {
      print('⚠️  Skipped: $path (file not found)');
      skippedCount++;
      continue;
    }

    final content = await file.readAsString();
    final lines = content.split('\n');
    var modified = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Match lines like "version: 1.0.0+6"
      if (line.startsWith('version:')) {
        final oldVersion = line.substring(8).trim();

        if (oldVersion != versionString) {
          lines[i] = 'version: $versionString';
          modified = true;
          print('✅ Updated: $path');
          print('   $oldVersion → $versionString');
        } else {
          print('⏭️  Skipped: $path (already up to date)');
        }
        break;
      }
    }

    if (modified) {
      await file.writeAsString(lines.join('\n'));
      updatedCount++;
    } else if (!modified && !skippedCount.toString().contains(path)) {
      skippedCount++;
    }
  }

  print('');
  print('━' * 50);
  print('✨ Version sync complete!');
  print('   Updated: $updatedCount file(s)');
  print('   Skipped: $skippedCount file(s)');
  print('━' * 50);
}

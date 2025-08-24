import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

// Table definitions
class Events extends Table {
  TextColumn get slug => text().named('slug')();
  TextColumn get name => text().named('name')();
  TextColumn get description => text().nullable().named('description')();
  TextColumn get logoUrl => text().nullable().named('logo_url')();
  IntColumn get apiOrder => integer().named('api_order')();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column> get primaryKey => {slug};
}

class Seasons extends Table {
  TextColumn get competitionSlug => text().named('competition_slug')();
  TextColumn get seasonSlug => text().named('season_slug')();
  TextColumn get title => text().named('title')();
  IntColumn get apiOrder => integer().named('api_order')();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {competitionSlug, seasonSlug};
}

class Divisions extends Table {
  TextColumn get competitionSlug => text().named('competition_slug')();
  TextColumn get seasonSlug => text().named('season_slug')();
  TextColumn get divisionSlug => text().named('division_slug')();
  TextColumn get name => text().named('name')();
  IntColumn get apiOrder => integer().named('api_order')();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {competitionSlug, seasonSlug, divisionSlug};
}

class Teams extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get competitionSlug => text().named('competition_slug')();
  TextColumn get seasonSlug => text().named('season_slug')();
  TextColumn get divisionSlug => text().named('division_slug')();
  TextColumn get name => text().named('name')();
  TextColumn get abbreviation => text().nullable().named('abbreviation')();
  TextColumn get logoUrl => text().nullable().named('logo_url')();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class Fixtures extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get competitionSlug => text().named('competition_slug')();
  TextColumn get seasonSlug => text().named('season_slug')();
  TextColumn get divisionSlug => text().named('division_slug')();
  TextColumn get homeTeamId => text().named('home_team_id')();
  TextColumn get awayTeamId => text().named('away_team_id')();
  TextColumn get homeTeamName => text().named('home_team_name')();
  TextColumn get awayTeamName => text().named('away_team_name')();
  TextColumn get homeTeamAbbreviation =>
      text().nullable().named('home_team_abbreviation')();
  TextColumn get awayTeamAbbreviation =>
      text().nullable().named('away_team_abbreviation')();
  IntColumn get dateTimeMs =>
      integer().named('date_time')(); // Renamed to avoid conflict
  TextColumn get field => text().nullable().named('field')();
  IntColumn get homeScore => integer().nullable().named('home_score')();
  IntColumn get awayScore => integer().nullable().named('away_score')();
  IntColumn get isCompleted => integer().named('is_completed')();
  TextColumn get roundInfo => text().nullable().named('round_info')();
  IntColumn get isBye => integer().nullable().named('is_bye')();
  TextColumn get videos => text().nullable().named('videos')();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class LadderEntries extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get competitionSlug => text().named('competition_slug')();
  TextColumn get seasonSlug => text().named('season_slug')();
  TextColumn get divisionSlug => text().named('division_slug')();
  TextColumn get teamName => text().named('team_name')();
  IntColumn get position => integer().named('position')();
  IntColumn get played => integer().named('played')();
  IntColumn get won => integer().named('won')();
  IntColumn get drawn => integer().named('drawn')();
  IntColumn get lost => integer().named('lost')();
  IntColumn get pointsFor => integer().named('points_for')();
  IntColumn get pointsAgainst => integer().named('points_against')();
  IntColumn get pointsDifference => integer().named('points_difference')();
  RealColumn get points => real().named('points')();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class NewsItems extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get title => text().named('title')();
  TextColumn get summary => text().named('summary')();
  TextColumn get imageUrl => text().nullable().named('image_url')();
  TextColumn get link => text().nullable().named('link')();
  IntColumn get publishedAt => integer().named('published_at')();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class CacheMetadata extends Table {
  TextColumn get key => text().named('key')();
  IntColumn get lastUpdated => integer().named('last_updated')();
  IntColumn get expiryDuration => integer().named('expiry_duration')();

  @override
  Set<Column> get primaryKey => {key};
}

class Favourites extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get type => text().named('type')();
  TextColumn get competitionSlug =>
      text().nullable().named('competition_slug')();
  TextColumn get competitionName =>
      text().nullable().named('competition_name')();
  TextColumn get seasonSlug => text().nullable().named('season_slug')();
  TextColumn get seasonName => text().nullable().named('season_name')();
  TextColumn get divisionSlug => text().nullable().named('division_slug')();
  TextColumn get divisionName => text().nullable().named('division_name')();
  TextColumn get teamId => text().nullable().named('team_id')();
  TextColumn get teamName => text().nullable().named('team_name')();
  IntColumn get createdAt => integer().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

// Database class
@DriftDatabase(tables: [
  Events,
  Seasons,
  Divisions,
  Teams,
  Fixtures,
  LadderEntries,
  NewsItems,
  CacheMetadata,
  Favourites
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (migrator, from, to) async {
        if (from == 1 && to == 2) {
          // Update points column from INTEGER to REAL
          await migrator.alterTable(
            TableMigration(
              ladderEntries,
              columnTransformer: {
                ladderEntries.points: ladderEntries.points.cast<double>(),
              },
            ),
          );
        }
      },
    );
  }
}

// Create a test database factory
AppDatabase createTestDatabase() {
  return AppDatabase(NativeDatabase.memory());
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fit_mobile_app.db'));

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}

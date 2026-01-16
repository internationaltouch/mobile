enum FavoriteType {
  event, // Competition level
  season, // Competition + Season
  division, // Competition + Season + Division
  team, // Team (future)
}

class Favorite {
  final String id;
  final String title;
  final String? subtitle;
  final FavoriteType type;
  final DateTime dateAdded;

  // Navigation data - what's needed to navigate to this favorite
  final String eventId;
  final String? eventSlug;
  final String? eventName;
  final String? season;
  final String? divisionId;
  final String? divisionSlug;
  final String? divisionName;
  final String? teamId;

  // Display data
  final String? logoUrl;
  final String? color;

  Favorite({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    required this.dateAdded,
    required this.eventId,
    this.eventSlug,
    this.eventName,
    this.season,
    this.divisionId,
    this.divisionSlug,
    this.divisionName,
    this.teamId,
    this.logoUrl,
    this.color,
  });

  // Factory constructors for different favorite types
  factory Favorite.fromEvent(
      String eventId, String eventSlug, String eventName) {
    return Favorite(
      id: 'event_$eventId',
      title: eventName,
      subtitle: null,
      type: FavoriteType.event,
      dateAdded: DateTime.now(),
      eventId: eventId,
      eventSlug: eventSlug,
      eventName: eventName,
    );
  }

  factory Favorite.fromSeason(
      String eventId, String eventSlug, String eventName, String season) {
    return Favorite(
      id: 'season_${eventId}_$season',
      title: season,
      subtitle: eventName,
      type: FavoriteType.season,
      dateAdded: DateTime.now(),
      eventId: eventId,
      eventSlug: eventSlug,
      eventName: eventName,
      season: season,
    );
  }

  factory Favorite.fromDivision(
    String eventId,
    String eventSlug,
    String eventName,
    String season,
    String divisionId,
    String divisionSlug,
    String divisionName,
    String? color,
  ) {
    return Favorite(
      id: 'division_${eventId}_${season}_$divisionId',
      title: divisionName,
      subtitle: '$season\n$eventName',
      type: FavoriteType.division,
      dateAdded: DateTime.now(),
      eventId: eventId,
      eventSlug: eventSlug,
      eventName: eventName,
      season: season,
      divisionId: divisionId,
      divisionSlug: divisionSlug,
      divisionName: divisionName,
      color: color,
    );
  }

  factory Favorite.fromTeam(
    String eventId,
    String eventSlug,
    String eventName,
    String season,
    String divisionId,
    String divisionSlug,
    String divisionName,
    String teamId,
    String teamName,
    String? teamSlug,
    String? color,
  ) {
    return Favorite(
      id: 'team_${eventId}_${season}_${divisionId}_$teamId',
      title: teamName,
      subtitle: '$season - $divisionName\n$eventName',
      type: FavoriteType.team,
      dateAdded: DateTime.now(),
      eventId: eventId,
      eventSlug: eventSlug,
      eventName: eventName,
      season: season,
      divisionId: divisionId,
      divisionSlug: divisionSlug,
      divisionName: divisionName,
      teamId: teamId,
      color: color,
    );
  }

  // JSON serialization for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type.name,
      'dateAdded': dateAdded.toIso8601String(),
      'eventId': eventId,
      'eventSlug': eventSlug,
      'eventName': eventName,
      'season': season,
      'divisionId': divisionId,
      'divisionSlug': divisionSlug,
      'divisionName': divisionName,
      'teamId': teamId,
      'logoUrl': logoUrl,
      'color': color,
    };
  }

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      type: FavoriteType.values.firstWhere((e) => e.name == json['type']),
      dateAdded: DateTime.parse(json['dateAdded']),
      eventId: json['eventId'],
      eventSlug: json['eventSlug'],
      eventName: json['eventName'],
      season: json['season'],
      divisionId: json['divisionId'],
      divisionSlug: json['divisionSlug'],
      divisionName: json['divisionName'],
      teamId: json['teamId'],
      logoUrl: json['logoUrl'],
      color: json['color'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Favorite && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

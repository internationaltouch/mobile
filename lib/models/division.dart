class Division {
  final String id;
  final String name;
  final String eventId;
  final String season;
  final String color;

  Division({
    required this.id,
    required this.name,
    required this.eventId,
    required this.season,
    this.color = '#2196F3',
  });

  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(
      id: json['id'],
      name: json['name'],
      eventId: json['eventId'],
      season: json['season'],
      color: json['color'] ?? '#2196F3',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'eventId': eventId,
      'season': season,
      'color': color,
    };
  }
}
class Division {
  final String id;
  final String name;
  final String eventId;
  final String season;
  final String color;
  final String? slug; // Add slug for API compatibility

  Division({
    required this.id,
    required this.name,
    required this.eventId,
    required this.season,
    this.color = '#2196F3',
    this.slug,
  });

  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(
      id: json['id'] ?? json['slug'] ?? '',
      name: json['name'] ?? json['title'] ?? '',
      eventId: json['eventId'] ?? '',
      season: json['season'] ?? '',
      color: json['color'] ?? '#2196F3',
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'eventId': eventId,
      'season': season,
      'color': color,
      'slug': slug,
    };
  }
}

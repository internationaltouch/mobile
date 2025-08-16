class Event {
  final String id;
  final String name;
  final String logoUrl;
  final List<String> seasons;
  final String description;

  Event({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.seasons,
    required this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logoUrl'],
      seasons: List<String>.from(json['seasons']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'seasons': seasons,
      'description': description,
    };
  }
}
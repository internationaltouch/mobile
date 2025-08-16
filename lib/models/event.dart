class Event {
  final String id;
  final String name;
  final String logoUrl;
  final List<String> seasons;
  final String description;
  final String? slug; // Add slug for API compatibility

  Event({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.seasons,
    required this.description,
    this.slug,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? json['slug'] ?? '',
      name: json['name'] ?? json['title'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      seasons: json['seasons'] != null 
          ? (json['seasons'] as List).map((s) => s['title'] ?? s.toString()).toList().cast<String>()
          : List<String>.from(json['seasons'] ?? []),
      description: json['description'] ?? '',
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'seasons': seasons,
      'description': description,
      'slug': slug,
    };
  }
}
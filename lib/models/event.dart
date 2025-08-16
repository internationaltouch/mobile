import 'season.dart';

class Event {
  final String id;
  final String name;
  final String logoUrl;
  final List<Season> seasons;
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
          ? (json['seasons'] as List).map((s) => Season.fromJson(s is Map<String, dynamic> ? s : {'title': s.toString(), 'slug': s.toString()})).toList()
          : [],
      description: json['description'] ?? '',
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'seasons': seasons.map((s) => s.toJson()).toList(),
      'description': description,
      'slug': slug,
    };
  }
}
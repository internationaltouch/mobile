import 'season.dart';

class Event {
  final String id;
  final String name;
  final String logoUrl;
  final List<Season> seasons;
  final String description;
  final String? slug; // Add slug for API compatibility
  final bool seasonsLoaded; // Track if seasons have been loaded

  Event({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.seasons,
    required this.description,
    this.slug,
    this.seasonsLoaded = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? json['slug'] ?? '',
      name: json['name'] ?? json['title'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      seasons: json['seasons'] != null
          ? (json['seasons'] as List)
              .map((s) => Season.fromJson(s is Map<String, dynamic>
                  ? s
                  : {'title': s.toString(), 'slug': s.toString()}))
              .toList()
          : [],
      description: json['description'] ?? '',
      slug: json['slug'],
      seasonsLoaded: json['seasons'] != null,
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
      'seasonsLoaded': seasonsLoaded,
    };
  }

  // Create a copy with updated seasons
  Event copyWith({
    String? id,
    String? name,
    String? logoUrl,
    List<Season>? seasons,
    String? description,
    String? slug,
    bool? seasonsLoaded,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      seasons: seasons ?? this.seasons,
      description: description ?? this.description,
      slug: slug ?? this.slug,
      seasonsLoaded: seasonsLoaded ?? this.seasonsLoaded,
    );
  }
}

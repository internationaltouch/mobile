class Team {
  final String id;
  final String name;
  final String divisionId;
  final String? slug; // Add slug for API compatibility
  final String? abbreviation; // Add abbreviation from club data

  Team({
    required this.id,
    required this.name,
    required this.divisionId,
    this.slug,
    this.abbreviation,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['title'] ?? '',
      divisionId: json['divisionId'] ?? '',
      slug: json['slug'],
      abbreviation: json['club']?['abbreviation'] ?? json['abbreviation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'divisionId': divisionId,
      'slug': slug,
      'abbreviation': abbreviation,
    };
  }
}
class Season {
  final String title;
  final String slug;
  final String? url;

  Season({
    required this.title,
    required this.slug,
    this.url,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'slug': slug,
      'url': url,
    };
  }

  @override
  String toString() => title;
}

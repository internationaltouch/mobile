class NewsItem {
  final String id; // slug from API
  final String title; // headline from API
  final String summary; // abstract from API
  String? imageUrl; // image from API (nullable, filled by detail endpoint)
  final DateTime publishedAt; // published from API
  final String? content; // copy from API (HTML)
  final bool isActive;

  NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    this.imageUrl,
    required this.publishedAt,
    this.content,
    this.isActive = true,
  });

  /// Create NewsItem from list API response
  factory NewsItem.fromListJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['slug'] as String,
      title: json['headline'] as String,
      summary: json['abstract'] as String,
      publishedAt: DateTime.parse(json['published'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Create NewsItem from detail API response
  factory NewsItem.fromDetailJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['slug'] as String,
      title: json['headline'] as String,
      summary: json['abstract'] as String,
      imageUrl: json['image'] as String?,
      publishedAt: DateTime.parse(json['published'] as String),
      content: json['copy'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Generic fromJson that tries detail format first, then list format
  factory NewsItem.fromJson(Map<String, dynamic> json) {
    // Prefer detail format if copy or image is present
    if (json.containsKey('copy') || json.containsKey('image')) {
      return NewsItem.fromDetailJson(json);
    }
    return NewsItem.fromListJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': id,
      'headline': title,
      'abstract': summary,
      'image': imageUrl,
      'published': publishedAt.toIso8601String(),
      'copy': content,
      'is_active': isActive,
    };
  }

  /// Update this item with data from detail response
  NewsItem copyWith({
    String? id,
    String? title,
    String? summary,
    String? imageUrl,
    DateTime? publishedAt,
    String? content,
    bool? isActive,
  }) {
    return NewsItem(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      isActive: isActive ?? this.isActive,
    );
  }
}

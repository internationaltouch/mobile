class NewsItem {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final DateTime publishedAt;
  final String? content;

  NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.publishedAt,
    this.content,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      imageUrl: json['imageUrl'],
      publishedAt: DateTime.parse(json['publishedAt']),
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'content': content,
    };
  }
}
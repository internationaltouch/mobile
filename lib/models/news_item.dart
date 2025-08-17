class NewsItem {
  final String id;
  final String title;
  final String summary;
  String imageUrl;
  final DateTime publishedAt;
  final String? content;
  final String? link;

  NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.publishedAt,
    this.content,
    this.link,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      imageUrl: json['imageUrl'],
      publishedAt: DateTime.parse(json['publishedAt']),
      content: json['content'],
      link: json['link'],
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
      'link': link,
    };
  }
}

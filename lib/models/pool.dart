class Pool {
  final int id;
  final String title;

  Pool({
    required this.id,
    required this.title,
  });

  factory Pool.fromJson(Map<String, dynamic> json) {
    return Pool(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pool && other.id == id && other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  @override
  String toString() => 'Pool{id: $id, title: $title}';
}

class ShortcutItem {
  final String id;
  final String title;
  final String subtitle;
  final String routePath;
  final Map<String, dynamic> arguments;

  const ShortcutItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.routePath,
    this.arguments = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'routePath': routePath,
      'arguments': arguments,
    };
  }

  factory ShortcutItem.fromJson(Map<String, dynamic> json) {
    return ShortcutItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      routePath: json['routePath'] as String,
      arguments: json['arguments'] as Map<String, dynamic>? ?? {},
    );
  }
}

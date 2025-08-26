class Club {
  final String title;
  final String shortTitle;
  final String slug;
  final String abbreviation;
  final String url;
  final String? facebook;
  final String? twitter;
  final String? youtube;
  final String? website;

  Club({
    required this.title,
    required this.shortTitle,
    required this.slug,
    required this.abbreviation,
    required this.url,
    this.facebook,
    this.twitter,
    this.youtube,
    this.website,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      title: json['title'] as String,
      shortTitle: json['short_title'] as String,
      slug: json['slug'] as String,
      abbreviation: json['abbreviation'] as String,
      url: json['url'] as String,
      facebook: json['facebook'] as String?,
      twitter: json['twitter'] as String?,
      youtube: json['youtube'] as String?,
      website: json['website'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'short_title': shortTitle,
      'slug': slug,
      'abbreviation': abbreviation,
      'url': url,
      'facebook': facebook,
      'twitter': twitter,
      'youtube': youtube,
      'website': website,
    };
  }
}

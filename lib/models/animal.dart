class Animal {
  final int? id;
  final String name;
  final String? emoji;
  final String? imageUrl;
  final List<String> hints;
  final List<String> funFacts;

  const Animal({
    this.id,
    required this.name,
    this.emoji,
    this.imageUrl,
    this.hints = const [],
    this.funFacts = const [],
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as int?,
      name: json['name'] as String,
      emoji: json['emoji'] as String?,
      imageUrl: json['imageUrl'] as String?,
      hints: (json['hints'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      funFacts: (json['funFacts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (emoji != null) 'emoji': emoji,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'hints': hints,
      'funFacts': funFacts,
    };
  }
}

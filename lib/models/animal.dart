class Animal {
  final int? id;
  final String name;
  final String? emoji;
  final String? imageUrl;

  const Animal({
    this.id,
    required this.name,
    this.emoji,
    this.imageUrl,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as int?,
      name: json['name'] as String,
      emoji: json['emoji'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (emoji != null) 'emoji': emoji,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

import 'animal.dart';

class Level {
  final int id;
  final String title;
  final String? emoji;
  final List<Animal> animals;

  const Level({
    required this.id,
    required this.title,
    this.emoji,
    required this.animals,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as int,
      title: json['title'] as String,
      emoji: json['emoji'] as String?,
      animals: (json['animals'] as List<dynamic>)
          .map((a) => Animal.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (emoji != null) 'emoji': emoji,
      'animals': animals.map((a) => a.toJson()).toList(),
    };
  }

  String get displayTitle => 'Level $id — $title';
  String get titleKey => 'level_$id';
  int get questionCount => animals.length;
}

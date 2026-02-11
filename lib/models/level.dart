import 'animal.dart';

class Level {
  final int id;
  final String title;
  final String emoji;
  final List<Animal> animals;

  const Level({
    required this.id,
    required this.title,
    required this.emoji,
    required this.animals,
  });

  String get displayTitle => 'Level $id — $title';
  int get questionCount => animals.length;
}

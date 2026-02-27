import 'animal.dart';
import 'level.dart';

class DailyChallenge {
  final DateTime date;
  final List<Animal> animals;
  final bool completed;
  final int? score;
  final int progress;

  const DailyChallenge({
    required this.date,
    required this.animals,
    required this.completed,
    this.score,
    required this.progress,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    final dateRaw = json['date'] as String?;
    final parsedDate =
        (dateRaw != null ? DateTime.tryParse(dateRaw) : null) ?? DateTime.now();

    final animalList = (json['animals'] as List<dynamic>? ?? const [])
        .map((a) => Animal.fromJson(a as Map<String, dynamic>))
        .toList();

    final completed = json['completed'] as bool? ?? false;
    final score = json['score'] as int?;
    final fallbackProgress = completed ? animalList.length : 0;
    final progress =
        (json['progress'] as int?) ??
        (json['answeredCount'] as int?) ??
        fallbackProgress;

    return DailyChallenge(
      date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      animals: animalList,
      completed: completed,
      score: score,
      progress: progress.clamp(0, animalList.length),
    );
  }

  Level toLevel({required int id, required String title, String? emoji}) {
    return Level(id: id, title: title, emoji: emoji, animals: animals);
  }

  DailyChallenge copyWith({bool? completed, int? score, int? progress}) {
    return DailyChallenge(
      date: date,
      animals: animals,
      completed: completed ?? this.completed,
      score: score ?? this.score,
      progress: progress ?? this.progress,
    );
  }
}

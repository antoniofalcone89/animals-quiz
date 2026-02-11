class Animal {
  final String name;
  final String emoji;
  final String imageUrl;

  const Animal({
    required this.name,
    required this.emoji,
    required this.imageUrl,
  });

  String get translationKey => 'animal_${name.toLowerCase().replaceAll(' ', '_')}';
}

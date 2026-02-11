import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimalEmojiCard extends StatelessWidget {
  final String emoji;

  const AnimalEmojiCard({super.key, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.deepPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.deepPurple.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 80)),
      ),
    );
  }
}

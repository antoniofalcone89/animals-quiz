import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import 'level_card.dart';

class LevelGrid extends StatelessWidget {
  final GameState gameState;
  final void Function(Level) onLevelTap;

  const LevelGrid({
    super.key,
    required this.gameState,
    required this.onLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    final levels = gameState.levels;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GridView.builder(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: levels.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemBuilder: (context, index) {
          final level = levels[index];
          final isLocked = !gameState.isLevelUnlocked(level.id);
          final requiredLevelName = level.id > 1 && index > 0
              ? levels[index - 1].title
              : null;
          return LevelCard(
            level: level,
            progress: gameState.getLevelProgress(level.id),
            isLocked: isLocked,
            requiredLevelName: requiredLevelName,
            onTap: () => onLevelTap(level),
          );
        },
      ),
    );
  }
}

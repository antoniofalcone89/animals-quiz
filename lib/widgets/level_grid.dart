import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import '../theme/app_theme.dart';
import 'level_card.dart';
import 'shimmer_loading.dart';

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
          crossAxisCount: 1,
          childAspectRatio: 2.35,
          crossAxisSpacing: 0,
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

class LevelGridSkeleton extends StatelessWidget {
  const LevelGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GridView.builder(
        clipBehavior: Clip.none,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 2.35,
          crossAxisSpacing: 0,
          mainAxisSpacing: 14,
        ),
        itemBuilder: (_, __) => _LevelCardSkeleton(),
      ),
    );
  }
}

class _LevelCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 6,
              color: AppColors.deepPurple.withValues(alpha: 0.12),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(width: 52, height: 52, radius: 12),
                    const SizedBox(height: 8),
                    _shimmerBox(width: 150, height: 18),
                    const Spacer(),
                    _shimmerBox(width: 76, height: 14),
                    const SizedBox(height: 8),
                    _shimmerBox(width: double.infinity, height: 8, radius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: const ShimmerLoading(
          baseColor: Color(0xFFE5E5E5),
          highlightColor: Color(0xFFF2F2F2),
        ),
      ),
    );
  }
}

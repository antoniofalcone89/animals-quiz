import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  /// 0.0–1.0 progress toward unlocking (1.0 = unlocked)
  final double progress;

  /// Human-readable progress label e.g. "3/7"
  final String? progressLabel;

  const Achievement({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
    required this.isUnlocked,
    required this.progress,
    this.progressLabel,
  });
}

class AchievementService {
  static List<Achievement> compute({
    required int totalPoints,
    required int totalCoins,
    required int currentStreak,
    required Map<int, List<bool>> levelProgress,
    required Map<int, List<int>> hintsProgress,
    required int totalLevels,
  }) {
    double levelPct(int id) {
      final p = levelProgress[id];
      if (p == null || p.isEmpty) return 0.0;
      return p.where((g) => g).length / p.length;
    }

    int levelCorrect(int id) {
      final p = levelProgress[id];
      if (p == null) return 0;
      return p.where((g) => g).length;
    }

    int levelTotal(int id) => levelProgress[id]?.length ?? 0;

    bool levelCompleted(int id) => levelPct(id) >= 1.0;

    bool anyLevelNoHints() {
      for (final entry in levelProgress.entries) {
        final id = entry.key;
        final progress = entry.value;
        if (progress.every((g) => g)) {
          final hints = hintsProgress[id];
          if (hints == null || hints.every((h) => h == 0)) return true;
        }
      }
      return false;
    }

    bool allLevelsCompleted() {
      if (totalLevels == 0) return false;
      for (int i = 1; i <= totalLevels; i++) {
        if (!levelCompleted(i)) return false;
      }
      return true;
    }

    final completedCount = List.generate(totalLevels, (i) => i + 1)
        .where((id) => levelCompleted(id))
        .length;

    return [
      // ── First Steps ──────────────────────────────────────────────
      Achievement(
        id: 'first_answer',
        titleKey: 'achievement_first_answer_title',
        descriptionKey: 'achievement_first_answer_desc',
        icon: Icons.star_rounded,
        color: const Color(0xFFFFB800),
        isUnlocked: totalPoints > 0,
        progress: totalPoints > 0 ? 1.0 : 0.0,
      ),
      Achievement(
        id: 'level_1_complete',
        titleKey: 'achievement_level_1_title',
        descriptionKey: 'achievement_level_1_desc',
        icon: Icons.looks_one_rounded,
        color: const Color(0xFF4ECDC4),
        isUnlocked: levelCompleted(1),
        progress: levelPct(1),
        progressLabel: '${levelCorrect(1)}/${levelTotal(1)}',
      ),
      Achievement(
        id: 'all_levels',
        titleKey: 'achievement_all_levels_title',
        descriptionKey: 'achievement_all_levels_desc',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFFF6B6B),
        isUnlocked: allLevelsCompleted(),
        progress: totalLevels > 0 ? completedCount / totalLevels : 0.0,
        progressLabel: '$completedCount/$totalLevels',
      ),
      // ── Points ───────────────────────────────────────────────────
      Achievement(
        id: 'points_100',
        titleKey: 'achievement_points_100_title',
        descriptionKey: 'achievement_points_100_desc',
        icon: Icons.bolt_rounded,
        color: const Color(0xFF45B7D1),
        isUnlocked: totalPoints >= 100,
        progress: (totalPoints / 100).clamp(0.0, 1.0),
        progressLabel: '$totalPoints/100',
      ),
      Achievement(
        id: 'points_500',
        titleKey: 'achievement_points_500_title',
        descriptionKey: 'achievement_points_500_desc',
        icon: Icons.military_tech_rounded,
        color: const Color(0xFF9B6DFF),
        isUnlocked: totalPoints >= 500,
        progress: (totalPoints / 500).clamp(0.0, 1.0),
        progressLabel: '$totalPoints/500',
      ),
      Achievement(
        id: 'points_1000',
        titleKey: 'achievement_points_1000_title',
        descriptionKey: 'achievement_points_1000_desc',
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFFFFB800),
        isUnlocked: totalPoints >= 1000,
        progress: (totalPoints / 1000).clamp(0.0, 1.0),
        progressLabel: '$totalPoints/1000',
      ),
      // ── Coins ────────────────────────────────────────────────────
      Achievement(
        id: 'coins_200',
        titleKey: 'achievement_coins_200_title',
        descriptionKey: 'achievement_coins_200_desc',
        icon: Icons.monetization_on_rounded,
        color: const Color(0xFFFFBE0B),
        isUnlocked: totalCoins >= 200,
        progress: (totalCoins / 200).clamp(0.0, 1.0),
        progressLabel: '$totalCoins/200',
      ),
      // ── Streak ───────────────────────────────────────────────────
      Achievement(
        id: 'streak_3',
        titleKey: 'achievement_streak_3_title',
        descriptionKey: 'achievement_streak_3_desc',
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFFF6B35),
        isUnlocked: currentStreak >= 3,
        progress: (currentStreak / 3).clamp(0.0, 1.0),
        progressLabel: '$currentStreak/3',
      ),
      Achievement(
        id: 'streak_7',
        titleKey: 'achievement_streak_7_title',
        descriptionKey: 'achievement_streak_7_desc',
        icon: Icons.whatshot_rounded,
        color: const Color(0xFFE53935),
        isUnlocked: currentStreak >= 7,
        progress: (currentStreak / 7).clamp(0.0, 1.0),
        progressLabel: '$currentStreak/7',
      ),
      // ── Mastery ──────────────────────────────────────────────────
      Achievement(
        id: 'no_hints',
        titleKey: 'achievement_no_hints_title',
        descriptionKey: 'achievement_no_hints_desc',
        icon: Icons.psychology_rounded,
        color: const Color(0xFF4CAF50),
        isUnlocked: anyLevelNoHints(),
        progress: anyLevelNoHints() ? 1.0 : 0.0,
      ),
      Achievement(
        id: 'level_3_complete',
        titleKey: 'achievement_level_3_title',
        descriptionKey: 'achievement_level_3_desc',
        icon: Icons.pets_rounded,
        color: const Color(0xFF96CEB4),
        isUnlocked: levelCompleted(3),
        progress: levelPct(3),
        progressLabel: '${levelCorrect(3)}/${levelTotal(3)}',
      ),
      Achievement(
        id: 'daily_player',
        titleKey: 'achievement_daily_title',
        descriptionKey: 'achievement_daily_desc',
        icon: Icons.calendar_today_rounded,
        color: const Color(0xFFDDA0DD),
        isUnlocked: currentStreak >= 2,
        progress: (currentStreak / 2).clamp(0.0, 1.0),
        progressLabel: '$currentStreak/2',
      ),
    ];
  }
}

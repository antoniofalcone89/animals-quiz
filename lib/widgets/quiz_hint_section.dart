import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class HintButton extends StatelessWidget {
  final int hintsRevealed;
  final int totalHints;
  final int? nextHintCost;
  final bool canAfford;
  final VoidCallback onRequestHint;
  final bool enabled;

  const HintButton({
    super.key,
    required this.hintsRevealed,
    required this.totalHints,
    required this.nextHintCost,
    required this.canAfford,
    required this.onRequestHint,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final allUsed = nextHintCost == null;
    final active = enabled && !allUsed && canAfford;

    return GestureDetector(
      onTap: active ? onRequestHint : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: allUsed
              ? Colors.grey.withValues(alpha: 0.1)
              : active
                  ? AppColors.deepPurple.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: allUsed
                ? Colors.grey.withValues(alpha: 0.2)
                : active
                    ? AppColors.deepPurple.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 18,
              color: allUsed
                  ? Colors.grey
                  : active
                      ? AppColors.deepPurple
                      : Colors.grey,
            ),
            if (!allUsed) ...[
              const SizedBox(width: 4),
              Text(
                '\u{1FA99}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 2),
              Text(
                '$nextHintCost',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: active ? AppColors.gold : Colors.grey,
                ),
              ),
            ],
            const SizedBox(width: 6),
            // Dot indicators
            ...List.generate(totalHints, (i) {
              return Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < hintsRevealed
                        ? AppColors.deepPurple
                        : Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class LetterRevealButton extends StatelessWidget {
  final int lettersRevealed;
  final int maxReveals;
  final int cost;
  final bool canAfford;
  final VoidCallback onReveal;
  final bool enabled;

  const LetterRevealButton({
    super.key,
    required this.lettersRevealed,
    required this.maxReveals,
    required this.cost,
    required this.canAfford,
    required this.onReveal,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final allUsed = lettersRevealed >= maxReveals;
    final active = enabled && !allUsed && canAfford;

    return GestureDetector(
      onTap: active ? onReveal : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: allUsed
              ? Colors.grey.withValues(alpha: 0.1)
              : active
                  ? AppColors.gold.withValues(alpha: 0.12)
                  : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: allUsed
                ? Colors.grey.withValues(alpha: 0.2)
                : active
                    ? AppColors.gold.withValues(alpha: 0.4)
                    : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'A_',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: allUsed
                    ? Colors.grey
                    : active
                        ? AppColors.gold
                        : Colors.grey,
              ),
            ),
            if (!allUsed) ...[
              const SizedBox(width: 4),
              Text(
                '\u{1FA99}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 2),
              Text(
                '$cost',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: active ? AppColors.gold : Colors.grey,
                ),
              ),
            ],
            const SizedBox(width: 6),
            ...List.generate(maxReveals, (i) {
              return Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < lettersRevealed
                        ? AppColors.gold
                        : Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class RevealAnimalButton extends StatelessWidget {
  final VoidCallback onReveal;
  final bool enabled;

  const RevealAnimalButton({
    super.key,
    required this.onReveal,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onReveal : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.correctGreen.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled
                ? AppColors.correctGreen.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.help_outline_rounded,
              size: 18,
              color: enabled ? AppColors.correctGreen : Colors.grey,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.play_circle_outline_rounded,
              size: 16,
              color: enabled ? AppColors.correctGreen : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class RevealedHints extends StatelessWidget {
  final List<String> hints;
  final int hintsRevealed;

  const RevealedHints({
    super.key,
    required this.hints,
    required this.hintsRevealed,
  });

  @override
  Widget build(BuildContext context) {
    if (hintsRevealed <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: List.generate(hintsRevealed, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.deepPurple.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: AppColors.lightPurple,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hints[i],
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepPurple,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

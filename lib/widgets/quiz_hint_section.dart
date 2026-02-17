import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class QuizHintSection extends StatelessWidget {
  final List<String> hints;
  final int hintsRevealed;
  final int? nextHintCost;
  final bool canAfford;
  final VoidCallback onRequestHint;
  final bool enabled;

  const QuizHintSection({
    super.key,
    required this.hints,
    required this.hintsRevealed,
    required this.nextHintCost,
    required this.canAfford,
    required this.onRequestHint,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (hintsRevealed > 0) ...[
          const SizedBox(height: 12),
          ...List.generate(hintsRevealed, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.deepPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.deepPurple.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u{1F4A1}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hints[i],
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
        if (enabled && nextHintCost != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: canAfford ? onRequestHint : () {},
              icon: const Text(
                '\u{1F4A1}',
                style: TextStyle(fontSize: 16),
              ),
              label: Text(
                '${'hint_button'.tr()} — ${'hint_cost'.tr(args: [nextHintCost.toString()])}',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: canAfford
                      ? AppColors.deepPurple
                      : Colors.grey,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: canAfford
                      ? AppColors.deepPurple.withValues(alpha: 0.4)
                      : Colors.grey.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          if (hintsRevealed > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'hints_used'.tr(args: [
                  hintsRevealed.toString(),
                  hints.length.toString(),
                ]),
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

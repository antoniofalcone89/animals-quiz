import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'coin_badge.dart';

class QuizResults extends StatelessWidget {
  final int correctCount;
  final int totalQuestions;
  final int coinsEarned;
  final VoidCallback onBackToLevel;
  final String completionTitleKey;
  final String backButtonLabelKey;

  const QuizResults({
    super.key,
    required this.correctCount,
    required this.totalQuestions,
    required this.coinsEarned,
    required this.onBackToLevel,
    this.completionTitleKey = 'level_completed',
    this.backButtonLabelKey = 'back_to_level',
  });

  @override
  Widget build(BuildContext context) {
    final isPerfect = totalQuestions > 0 && correctCount >= totalQuestions;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.purpleGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('\u{1F389}', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 24),
              Text(
                completionTitleKey.tr(),
                style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'score'.tr(),
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$correctCount/$totalQuestions',
                      style: GoogleFonts.nunito(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    if (isPerfect) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Text(
                          'perfect_score'.tr(),
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ],
                    if (coinsEarned > 0) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CoinIcon(size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'coins_earned'.tr(args: [coinsEarned.toString()]),
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onBackToLevel,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      backButtonLabelKey.tr(),
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepPurple,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

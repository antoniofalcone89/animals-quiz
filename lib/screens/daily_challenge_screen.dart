import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/daily_challenge.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  final GameState gameState;

  const DailyChallengeScreen({super.key, required this.gameState});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  @override
  void initState() {
    super.initState();
    widget.gameState.addListener(_onStateChanged);
    if (widget.gameState.todayChallenge == null) {
      widget.gameState.loadTodayChallenge();
    }
  }

  @override
  void dispose() {
    widget.gameState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.gameState.todayChallenge;

    if (widget.gameState.isChallengeLoading && challenge == null) {
      return const Scaffold(
        backgroundColor: AppColors.lightGrey,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.gameState.challengeError != null && challenge == null) {
      return Scaffold(
        backgroundColor: AppColors.lightGrey,
        appBar: AppBar(
          backgroundColor: AppColors.lightGrey,
          foregroundColor: AppColors.deepPurple,
          elevation: 0,
          title: Text('daily_challenge'.tr()),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.gameState.challengeError!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: widget.gameState.loadTodayChallenge,
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (challenge == null || challenge.animals.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.lightGrey,
        appBar: AppBar(
          backgroundColor: AppColors.lightGrey,
          foregroundColor: AppColors.deepPurple,
          elevation: 0,
          title: Text('daily_challenge'.tr()),
        ),
        body: Center(
          child: Text(
            'coming_soon'.tr(),
            style: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.deepPurple,
            ),
          ),
        ),
      );
    }

    if (challenge.completed) {
      return _CompletedView(challenge: challenge);
    }

    final startIndex = challenge.progress.clamp(
      0,
      challenge.animals.length - 1,
    );

    return QuizScreen(
      level: challenge.toLevel(
        id: 999,
        title: 'daily_challenge'.tr(),
        emoji: '🔥',
      ),
      animalIndex: startIndex,
      gameState: widget.gameState,
      isDailyChallenge: true,
      initialCorrectCount: challenge.progress,
      submitAnswerOverride: (animalIndex, answer, {bool adRevealed = false}) {
        return widget.gameState.submitDailyChallengeAnswer(
          animalIndex,
          answer,
          adRevealed: adRevealed,
        );
      },
    );
  }
}

class _CompletedView extends StatelessWidget {
  final DailyChallenge challenge;

  const _CompletedView({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.lightGrey,
        foregroundColor: AppColors.deepPurple,
        elevation: 0,
        title: Text('daily_challenge'.tr()),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.correctGreen,
                  size: 44,
                ),
                const SizedBox(height: 10),
                Text(
                  'challenge_completed'.tr(),
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'challenge_score'.tr(
                    args: [(challenge.score ?? 0).toString()],
                  ),
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.deepPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: AppColors.deepPurple,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'next_challenge_tomorrow'.tr(),
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

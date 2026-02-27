import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _introSeenKey = 'daily_challenge_intro_seen';

  @override
  void initState() {
    super.initState();
    widget.gameState.addListener(_onStateChanged);
    if (widget.gameState.todayChallenge == null) {
      widget.gameState.loadTodayChallenge();
    }
    _maybeShowIntro();
  }

  Future<void> _maybeShowIntro() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_introSeenKey) ?? false;
    if (!seen && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showIntroDialog();
      });
    }
  }

  Future<void> _showIntroDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _DailyChallengeIntroDialog(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introSeenKey, true);
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

class _DailyChallengeIntroDialog extends StatelessWidget {
  const _DailyChallengeIntroDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'daily_challenge_intro_title'.tr(),
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'daily_challenge_intro_body'.tr(),
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _RuleRow(
              icon: Icons.today_rounded,
              text: 'daily_challenge_intro_rule1'.tr(),
            ),
            const SizedBox(height: 10),
            _RuleRow(
              icon: Icons.stars_rounded,
              text: 'daily_challenge_intro_rule2'.tr(),
            ),
            const SizedBox(height: 10),
            _RuleRow(
              icon: Icons.emoji_events_rounded,
              text: 'daily_challenge_intro_rule3'.tr(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'daily_challenge_intro_cta'.tr(),
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RuleRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.deepPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.deepPurple),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.deepPurple,
            ),
          ),
        ),
      ],
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
                  size: 54,
                ),
                const SizedBox(height: 12),
                Text(
                  'challenge_completed'.tr(),
                  style: GoogleFonts.nunito(
                    fontSize: 24,
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
                    fontSize: 20,
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
                            fontSize: 18,
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

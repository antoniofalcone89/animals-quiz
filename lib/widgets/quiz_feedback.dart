import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class QuizFeedback extends StatefulWidget {
  final bool showWrongMessage;
  final bool answered;
  final VoidCallback onNext;
  final String? funFact;

  const QuizFeedback({
    super.key,
    required this.showWrongMessage,
    required this.answered,
    required this.onNext,
    this.funFact,
  });

  @override
  State<QuizFeedback> createState() => _QuizFeedbackState();
}

class _QuizFeedbackState extends State<QuizFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Correct answer — staggered intervals
  late final Animation<double> _correctBannerFade;
  late final Animation<Offset> _correctBannerSlide;
  late final Animation<double> _funFactFade;
  late final Animation<Offset> _funFactSlide;
  late final Animation<double> _buttonFade;
  late final Animation<double> _buttonScale;

  // Wrong answer
  late final Animation<double> _wrongFade;
  late final Animation<double> _wrongScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Correct banner: 0–50%
    _correctBannerFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _correctBannerSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // Fun fact: 30–75%
    _funFactFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.75, curve: Curves.easeOut),
    );
    _funFactSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // Next button: 55–100% with bounce
    _buttonFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );
    _buttonScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Wrong message: pop in with scale overshoot
    _wrongFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _wrongScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    if (widget.answered || widget.showWrongMessage) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(QuizFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);

    final wasActive = oldWidget.answered || oldWidget.showWrongMessage;
    final isActive = widget.answered || widget.showWrongMessage;

    if (isActive && !wasActive) {
      _controller.forward(from: 0);
    } else if (!isActive && wasActive) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showWrongMessage)
          FadeTransition(
            opacity: _wrongFade,
            child: ScaleTransition(
              scale: _wrongScale,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.wrongRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.close_rounded,
                        color: AppColors.wrongRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'wrong_answer'.tr(),
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.wrongRed,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        if (widget.answered) ...[
          const SizedBox(height: 16),

          // Correct banner
          FadeTransition(
            opacity: _correctBannerFade,
            child: SlideTransition(
              position: _correctBannerSlide,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.correctGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.correctGreen,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'correct_answer'.tr(),
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.correctGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Fun fact
          if (widget.funFact != null) ...[
            const SizedBox(height: 12),
            FadeTransition(
              opacity: _funFactFade,
              child: SlideTransition(
                position: _funFactSlide,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '\u{1F4D6}',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'did_you_know'.tr(),
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.amber[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.funFact!,
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber[900],
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
          ],

          const SizedBox(height: 16),

          // Next button — icon only with bounce entrance
          FadeTransition(
            opacity: _buttonFade,
            child: ScaleTransition(
              scale: _buttonScale,
              child: GestureDetector(
                onTap: widget.onNext,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.deepPurple,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepPurple.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class QuizInputSection extends StatelessWidget {
  final String hint;
  final String? revealedName;
  final bool alreadyGuessed;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final int questionIndex;
  final bool canSubmit;
  final VoidCallback onSubmit;

  const QuizInputSection({
    super.key,
    required this.hint,
    this.revealedName,
    this.alreadyGuessed = false,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.questionIndex,
    required this.canSubmit,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final showName = alreadyGuessed || revealedName != null;
    final displayName = revealedName ?? '';

    return Column(
      children: [
        // Hint / revealed name
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: showName
              ? Text(
                  alreadyGuessed ? displayName : revealedName!,
                  key: const ValueKey('revealed'),
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.correctGreen,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                )
              : Text(
                  hint,
                  key: const ValueKey('hint'),
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
        const SizedBox(height: 24),
        if (alreadyGuessed) ...[
          // Already guessed badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.correctGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.correctGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: AppColors.correctGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  'already_guessed'.tr(),
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.correctGreen,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Text input
          TextField(
            key: ValueKey('quiz_input_$questionIndex'),
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'type_answer'.tr(),
              hintStyle: GoogleFonts.nunito(fontSize: 18, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.deepPurple.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.deepPurple,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 16),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canSubmit ? onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepPurple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.deepPurple.withValues(
                  alpha: 0.4,
                ),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'submit'.tr(),
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

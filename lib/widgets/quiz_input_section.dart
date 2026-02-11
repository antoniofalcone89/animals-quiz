import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class QuizInputSection extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final int questionIndex;
  final bool canSubmit;
  final VoidCallback onSubmit;

  const QuizInputSection({
    super.key,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.questionIndex,
    required this.canSubmit,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hint: underscores matching name length
        Text(
          hint,
          style: GoogleFonts.nunito(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
            letterSpacing: 4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
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
    );
  }
}

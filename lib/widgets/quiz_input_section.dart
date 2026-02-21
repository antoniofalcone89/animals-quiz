import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class QuizInputSection extends StatefulWidget {
  final String animalName;
  final String? revealedName;
  final bool alreadyGuessed;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final int questionIndex;
  final bool showError;
  final VoidCallback onSubmit;

  const QuizInputSection({
    super.key,
    required this.animalName,
    this.revealedName,
    this.alreadyGuessed = false,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.questionIndex,
    this.showError = false,
    required this.onSubmit,
  });

  @override
  State<QuizInputSection> createState() => _QuizInputSectionState();
}

class _QuizInputSectionState extends State<QuizInputSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  int get _letterCount => widget.animalName.replaceAll(' ', '').length;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    widget.controller.addListener(_onInput);
  }

  @override
  void didUpdateWidget(QuizInputSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showError && !oldWidget.showError) {
      _shakeController.forward(from: 0);
    }
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onInput);
      widget.controller.addListener(_onInput);
    }
  }

  void _onInput() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onInput);
    _shakeController.dispose();
    super.dispose();
  }

  Widget _buildCharacterDisplay() {
    final name = widget.animalName;
    final typed = widget.controller.text;
    int typedIdx = 0;

    final List<TextSpan> spans = [];
    final words = name.split(' ');

    for (int w = 0; w < words.length; w++) {
      if (w > 0) {
        spans.add(const TextSpan(text: '   '));
      }

      final letters = words[w].split('');
      for (int l = 0; l < letters.length; l++) {
        if (l > 0) {
          spans.add(const TextSpan(text: ' '));
        }

        final hasChar = typedIdx < typed.length;
        final char = hasChar ? typed[typedIdx] : '_';

        Color color;
        if (widget.showError && hasChar) {
          color = Colors.red.shade600;
        } else if (hasChar) {
          color = AppColors.deepPurple;
        } else {
          color = Colors.grey.shade400;
        }

        spans.add(TextSpan(
          text: char,
          style: TextStyle(color: color),
        ));

        typedIdx++;
      }
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showName = widget.alreadyGuessed || widget.revealedName != null;

    return Column(
      children: [
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
                  widget.alreadyGuessed
                      ? (widget.revealedName ?? '')
                      : widget.revealedName!,
                  key: const ValueKey('revealed'),
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.correctGreen,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                )
              : AnimatedBuilder(
                  key: ValueKey('input_${widget.questionIndex}'),
                  animation: _shakeController,
                  builder: (context, child) {
                    final shakeOffset = _shakeController.isAnimating
                        ? sin(_shakeController.value * pi * 6) *
                            8 *
                            (1 - _shakeController.value)
                        : 0.0;
                    return Transform.translate(
                      offset: Offset(shakeOffset, 0),
                      child: child,
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      if (widget.enabled) {
                        widget.focusNode.requestFocus();
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _buildCharacterDisplay(),
                        ),
                        Opacity(
                          opacity: 0,
                          child: TextField(
                            controller: widget.controller,
                            focusNode: widget.focusNode,
                            enabled: widget.enabled,
                            maxLength: _letterCount,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                              LengthLimitingTextInputFormatter(_letterCount),
                            ],
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => widget.onSubmit(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 24),
        if (widget.alreadyGuessed) ...[
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                const Icon(
                  Icons.check_circle,
                  color: AppColors.correctGreen,
                  size: 20,
                ),
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
        ],
      ],
    );
  }
}

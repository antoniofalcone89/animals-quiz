import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upperText = newValue.text.toUpperCase();
    return newValue.copyWith(
      text: upperText,
      selection: TextSelection.collapsed(offset: upperText.length),
      composing: TextRange.empty,
    );
  }
}

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
  final List<int> revealedPositions;

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
    this.revealedPositions = const [],
  });

  @override
  State<QuizInputSection> createState() => _QuizInputSectionState();
}

class _QuizInputSectionState extends State<QuizInputSection>
    with TickerProviderStateMixin {
  // Wrong-answer shake
  late final AnimationController _shakeCtrl;

  // Correct-answer reveal transition (input out → name in)
  late final AnimationController _revealCtrl;

  // Input slides up + fades out over the first 40 % of the reveal
  late final Animation<double> _inputFade;
  late final Animation<double> _inputSlideY;

  // Revealed name fades in, slides up from below, scales with spring overshoot
  late final Animation<double> _revealFade;
  late final Animation<double> _revealSlideY;
  late final Animation<double> _revealScale;

  int get _letterCount =>
      widget.animalName.replaceAll(' ', '').length -
      widget.revealedPositions.length;

  @override
  void initState() {
    super.initState();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..addListener(() => setState(() {}));

    // Input exits
    _inputFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _revealCtrl,
        curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
      ),
    );
    _inputSlideY = Tween<double>(begin: 0.0, end: -18.0).animate(
      CurvedAnimation(
        parent: _revealCtrl,
        curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
      ),
    );

    // Revealed name enters
    _revealFade = CurvedAnimation(
      parent: _revealCtrl,
      curve: const Interval(0.30, 0.75, curve: Curves.easeOut),
    );
    _revealSlideY = Tween<double>(begin: 22.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _revealCtrl,
        curve: const Interval(0.30, 0.90, curve: Curves.easeOutCubic),
      ),
    );
    _revealScale = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealCtrl,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOutBack),
      ),
    );

    widget.controller.addListener(_onInput);

    // If already revealed on first build (restored session), skip to end
    if (widget.revealedName != null || widget.alreadyGuessed) {
      _revealCtrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(QuizInputSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showError && !oldWidget.showError) {
      _shakeCtrl.forward(from: 0);
    }

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onInput);
      widget.controller.addListener(_onInput);
    }

    // Moving to a new question — reset or skip to final state immediately
    if (widget.questionIndex != oldWidget.questionIndex) {
      if (widget.alreadyGuessed || widget.revealedName != null) {
        _revealCtrl.value = 1.0;
      } else {
        _revealCtrl.value = 0.0;
      }
      return;
    }

    // Correct answer just submitted — play reveal animation
    final justRevealed =
        widget.revealedName != null && oldWidget.revealedName == null;
    final justGuessed = widget.alreadyGuessed && !oldWidget.alreadyGuessed;
    if (justRevealed || justGuessed) {
      _revealCtrl.forward(from: 0);
    }
  }

  void _onInput() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onInput);
    _shakeCtrl.dispose();
    _revealCtrl.dispose();
    super.dispose();
  }

  // ── Character display (underscores + typed letters) ──────────────────────

  Widget _buildCharacterDisplay() {
    final name = widget.animalName.toUpperCase();
    final typed = widget.controller.text.toUpperCase();
    int typedIdx = 0;
    int nameIdx = 0;

    final List<TextSpan> spans = [];
    final words = name.split(' ');

    for (int w = 0; w < words.length; w++) {
      if (w > 0) {
        spans.add(const TextSpan(text: '   '));
        nameIdx++;
      }

      final letters = words[w].split('');
      for (int l = 0; l < letters.length; l++) {
        if (l > 0) spans.add(const TextSpan(text: ' '));

        final isRevealed = widget.revealedPositions.contains(nameIdx);

        if (isRevealed) {
          spans.add(
            TextSpan(
              text: name[nameIdx],
              style: const TextStyle(color: AppColors.gold),
            ),
          );
        } else {
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

          spans.add(
            TextSpan(
              text: char,
              style: TextStyle(color: color),
            ),
          );
          typedIdx++;
        }

        nameIdx++;
      }
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w700),
        children: spans,
      ),
    );
  }

  // ── Input widget (shake + character blanks + hidden TextField) ───────────

  Widget _buildInputWidget() {
    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (context, child) {
        final shakeOffset = _shakeCtrl.isAnimating
            ? sin(_shakeCtrl.value * pi * 6) * 8 * (1 - _shakeCtrl.value)
            : 0.0;
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          if (widget.enabled) widget.focusNode.requestFocus();
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
                enableInteractiveSelection: false,
                contextMenuBuilder: (_, __) => const SizedBox.shrink(),
                maxLength: _letterCount,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  _UpperCaseTextFormatter(),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final showName = widget.alreadyGuessed || widget.revealedName != null;
    final revealedText = showName
        ? (widget.revealedName ?? widget.animalName).toUpperCase()
        : '';

    return Column(
      children: [
        // ── Name / input display ────────────────────────────────────────────
        //
        // The Stack always sizes itself to the input widget (the non-positioned
        // anchor), so the container height is stable throughout the animation.
        // The revealed name is in Positioned.fill so it never affects sizing.
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Anchor: input section. Fades + slides up as name enters.
            Opacity(
              opacity: _inputFade.value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, _inputSlideY.value),
                child: _buildInputWidget(),
              ),
            ),

            // Revealed name: positioned overlay — no layout contribution.
            if (_revealCtrl.value > 0)
              Positioned.fill(
                child: Center(
                  child: Opacity(
                    opacity: _revealFade.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, _revealSlideY.value),
                      child: Transform.scale(
                        scale: _revealScale.value,
                        child: Text(
                          revealedText,
                          style: GoogleFonts.nunito(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: AppColors.correctGreen,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        if (widget.alreadyGuessed) ...[
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

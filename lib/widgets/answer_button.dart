import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum AnswerState { idle, correct, wrong }

class AnswerButton extends StatefulWidget {
  final String text;
  final AnswerState state;
  final VoidCallback? onTap;

  const AnswerButton({
    super.key,
    required this.text,
    required this.state,
    this.onTap,
  });

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton> {
  bool _pressed = false;

  Color get _bgColor {
    switch (widget.state) {
      case AnswerState.correct:
        return AppColors.correctGreen;
      case AnswerState.wrong:
        return AppColors.wrongRed;
      case AnswerState.idle:
        return Colors.white;
    }
  }

  Color get _textColor {
    if (widget.state == AnswerState.idle) return Colors.black87;
    return Colors.white;
  }

  IconData? get _icon {
    switch (widget.state) {
      case AnswerState.correct:
        return Icons.check_circle;
      case AnswerState.wrong:
        return Icons.cancel;
      case AnswerState.idle:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _bgColor == Colors.white
                    ? Colors.black.withValues(alpha: 0.08)
                    : _bgColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_icon != null) ...[
                Icon(_icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

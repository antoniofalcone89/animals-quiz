import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/animal.dart';
import '../theme/app_theme.dart';

class AnimalThumbnail extends StatefulWidget {
  final Animal animal;
  final int index;
  final bool guessed;
  final VoidCallback onTap;

  const AnimalThumbnail({
    super.key,
    required this.animal,
    required this.index,
    required this.guessed,
    required this.onTap,
  });

  @override
  State<AnimalThumbnail> createState() => _AnimalThumbnailState();
}

class _AnimalThumbnailState extends State<AnimalThumbnail> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: widget.guessed
                ? AppColors.correctGreen.withValues(alpha: 0.1)
                : AppColors.deepPurple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.guessed
                  ? AppColors.correctGreen.withValues(alpha: 0.3)
                  : AppColors.deepPurple.withValues(alpha: 0.15),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.guessed ? (widget.animal.emoji ?? '\u{2705}') : '?',
                      style: TextStyle(
                        fontSize: widget.guessed ? 40 : 36,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.guessed ? widget.animal.name : '#${widget.index + 1}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: widget.guessed ? AppColors.correctGreen : AppColors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (widget.guessed)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.correctGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/level.dart';
import '../theme/app_theme.dart';

class LevelCard extends StatefulWidget {
  final Level level;
  final double progress;
  final VoidCallback onTap;
  final bool isLocked;
  final String? requiredLevelName;

  const LevelCard({
    super.key,
    required this.level,
    required this.progress,
    required this.onTap,
    this.isLocked = false,
    this.requiredLevelName,
  });

  @override
  State<LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<LevelCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.levelAccents[(widget.level.id - 1) % AppColors.levelAccents.length];

    final isLocked = widget.isLocked;

    return GestureDetector(
      onTapDown: isLocked ? null : (_) => setState(() => _pressed = true),
      onTapUp: isLocked ? null : (_) => setState(() => _pressed = false),
      onTapCancel: isLocked ? null : () => setState(() => _pressed = false),
      onTap: isLocked ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor, accentColor.withValues(alpha: 0.5)],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.level.emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                widget.level.displayTitle,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.deepPurple,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${widget.level.questionCount} Questions',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: widget.progress,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_rounded, size: 32, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Complete 80% of',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            widget.requiredLevelName ?? '',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
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

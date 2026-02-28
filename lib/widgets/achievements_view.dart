import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/achievement.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public entry point
// ─────────────────────────────────────────────────────────────────────────────

class AchievementsView extends StatefulWidget {
  final List<Achievement> achievements;

  const AchievementsView({super.key, required this.achievements});

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 400 + widget.achievements.length * 60,
      ),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = widget.achievements.where((a) => a.isUnlocked).length;
    final total = widget.achievements.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB800), Color(0xFFFF6B35)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'achievements_title'.tr(),
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepPurple,
                      ),
                    ),
                    Text(
                      'achievements_progress'.tr(
                        args: [unlocked.toString(), total.toString()],
                      ),
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Grid ─────────────────────────────────────────────────
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 148,
          ),
          itemCount: widget.achievements.length,
          itemBuilder: (context, index) {
            final achievement = widget.achievements[index];
            final itemDelay = index * 0.06;
            final itemDuration = 0.35;
            final start = itemDelay;
            final end = (itemDelay + itemDuration).clamp(0.0, 1.0);

            final fadeAnim = CurvedAnimation(
              parent: _staggerController,
              curve: Interval(start, end, curve: Curves.easeOut),
            );
            final slideAnim = Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _staggerController,
                curve: Interval(start, end, curve: Curves.easeOutCubic),
              ),
            );

            return FadeTransition(
              opacity: fadeAnim,
              child: SlideTransition(
                position: slideAnim,
                child: _AchievementBadgeTile(
                  achievement: achievement,
                  index: index,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual Badge Tile
// ─────────────────────────────────────────────────────────────────────────────

class _AchievementBadgeTile extends StatefulWidget {
  final Achievement achievement;
  final int index;

  const _AchievementBadgeTile({
    required this.achievement,
    required this.index,
  });

  @override
  State<_AchievementBadgeTile> createState() => _AchievementBadgeTileState();
}

class _AchievementBadgeTileState extends State<_AchievementBadgeTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (widget.achievement.isUnlocked) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _onTap() {
    _showDetailDialog();
  }

  void _showDetailDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'achievement_detail',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) =>
          _AchievementDetailDialog(achievement: widget.achievement),
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    final color = a.isUnlocked ? a.color : Colors.grey[400]!;

    return GestureDetector(
      onTap: _onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            final glowValue = a.isUnlocked
                ? 0.4 + _glowController.value * 0.6
                : 0.0;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  // Base shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                  // Glow for unlocked
                  if (a.isUnlocked)
                    BoxShadow(
                      color: color.withValues(alpha: glowValue * 0.4),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                ],
                border: Border.all(
                  color: a.isUnlocked
                      ? color.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Badge Icon Circle ─────────────────────────
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: a.isUnlocked
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  color.withValues(alpha: 0.15),
                                  color.withValues(alpha: 0.30),
                                ],
                              )
                            : null,
                        color: a.isUnlocked
                            ? null
                            : Colors.grey.withValues(alpha: 0.10),
                      ),
                      child: Icon(
                        a.isUnlocked ? a.icon : Icons.lock_outline_rounded,
                        size: 26,
                        color: a.isUnlocked ? color : Colors.grey[400],
                      ),
                    ),
                    // Shimmer sweep for unlocked
                    if (a.isUnlocked)
                      ClipOval(
                        child: SizedBox(
                          width: 54,
                          height: 54,
                          child: AnimatedBuilder(
                            animation: _glowController,
                            builder: (_, __) => CustomPaint(
                              painter: _ShimmerSweepPainter(
                                progress: _glowController.value,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // ── Title ─────────────────────────────────────
                Text(
                  a.titleKey.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: a.isUnlocked
                        ? AppColors.deepPurple
                        : Colors.grey[500],
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                // ── Progress bar ──────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: a.progress,
                    minHeight: 4,
                    backgroundColor: Colors.grey.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      a.isUnlocked ? color : Colors.grey[400]!,
                    ),
                  ),
                ),
                if (a.progressLabel != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    a.progressLabel!,
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: a.isUnlocked ? color : Colors.grey[400],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer Sweep Painter
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerSweepPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ShimmerSweepPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final angle = progress * math.pi * 2 - math.pi / 2;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final x = cx + r * math.cos(angle);
    final y = cy + r * math.sin(angle);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.55),
          color.withValues(alpha: 0.0),
        ],
        radius: 0.45,
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: r * 0.5));

    canvas.drawCircle(Offset(x, y), r * 0.4, paint);
  }

  @override
  bool shouldRepaint(_ShimmerSweepPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _AchievementDetailDialog extends StatefulWidget {
  final Achievement achievement;

  const _AchievementDetailDialog({required this.achievement});

  @override
  State<_AchievementDetailDialog> createState() =>
      _AchievementDetailDialogState();
}

class _AchievementDetailDialogState extends State<_AchievementDetailDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.achievement.isUnlocked) {
      _particleController.forward();
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    final color = a.isUnlocked ? a.color : Colors.grey[400]!;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.78,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: a.isUnlocked ? 0.3 : 0.0),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon with optional particles ──────────────
              SizedBox(
                height: 90,
                width: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (a.isUnlocked)
                      AnimatedBuilder(
                        animation: _particleController,
                        builder: (_, __) => CustomPaint(
                          size: const Size(90, 90),
                          painter: _ParticleBurstPainter(
                            progress: _particleController.value,
                            color: color,
                          ),
                        ),
                      ),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: a.isUnlocked
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  color.withValues(alpha: 0.15),
                                  color.withValues(alpha: 0.35),
                                ],
                              )
                            : null,
                        color: a.isUnlocked
                            ? null
                            : Colors.grey.withValues(alpha: 0.12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        a.isUnlocked ? a.icon : Icons.lock_outline_rounded,
                        size: 36,
                        color: a.isUnlocked ? color : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Title ─────────────────────────────────────
              Text(
                a.titleKey.tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: a.isUnlocked ? AppColors.deepPurple : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),

              // ── Description ───────────────────────────────
              Text(
                a.descriptionKey.tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // ── Progress bar ──────────────────────────────
              if (!a.isUnlocked) ...[
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: a.progress),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          builder: (_, value, __) => LinearProgressIndicator(
                            value: value,
                            minHeight: 8,
                            backgroundColor:
                                Colors.grey.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ),
                    ),
                    if (a.progressLabel != null) ...[
                      const SizedBox(width: 10),
                      Text(
                        a.progressLabel!,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // ── Status pill ───────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: a.isUnlocked
                      ? color.withValues(alpha: 0.12)
                      : Colors.grey.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  a.isUnlocked
                      ? 'achievement_unlocked'.tr()
                      : 'achievement_locked'.tr(),
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: a.isUnlocked ? color : Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Particle Burst Painter
// ─────────────────────────────────────────────────────────────────────────────

class _ParticleBurstPainter extends CustomPainter {
  final double progress;
  final Color color;

  static const _particleCount = 10;
  static final _rng = math.Random(42);
  static final _angles = List.generate(
    _particleCount,
    (i) => _rng.nextDouble() * math.pi * 2,
  );
  static final _speeds = List.generate(
    _particleCount,
    (i) => 0.6 + _rng.nextDouble() * 0.4,
  );
  static final _sizes = List.generate(
    _particleCount,
    (i) => 2.5 + _rng.nextDouble() * 3.0,
  );

  _ParticleBurstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.width * 0.55;

    // Ease-out curve for burst
    final t = Curves.easeOut.transform(math.min(progress * 1.6, 1.0));
    final opacity = (1.0 - progress * 1.2).clamp(0.0, 1.0);

    for (int i = 0; i < _particleCount; i++) {
      final r = t * maxR * _speeds[i];
      final x = cx + r * math.cos(_angles[i]);
      final y = cy + r * math.sin(_angles[i]);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity * 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), _sizes[i] * (1.0 - t * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(_ParticleBurstPainter old) => old.progress != progress;
}

import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/achievement.dart';
import '../theme/app_theme.dart';

/// Shows a top-sliding achievement-unlocked toast.
/// Auto-dismisses after [displayDuration].
void showAchievementToast(
  BuildContext context,
  Achievement achievement, {
  Duration displayDuration = const Duration(seconds: 4),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _AchievementToastOverlay(
      achievement: achievement,
      displayDuration: displayDuration,
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

// ─────────────────────────────────────────────────────────────────────────────

class _AchievementToastOverlay extends StatefulWidget {
  final Achievement achievement;
  final Duration displayDuration;
  final VoidCallback onDismiss;

  const _AchievementToastOverlay({
    required this.achievement,
    required this.displayDuration,
    required this.onDismiss,
  });

  @override
  State<_AchievementToastOverlay> createState() =>
      _AchievementToastOverlayState();
}

class _AchievementToastOverlayState extends State<_AchievementToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    _timer = Timer(widget.displayDuration, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    final topPad = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPad + 14,
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: _dismiss,
        child: SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: _ToastCard(achievement: a),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ToastCard extends StatefulWidget {
  final Achievement achievement;
  const _ToastCard({required this.achievement});

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    final color = a.color;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Row(
          children: [
            // ── Animated badge icon ─────────────────────────
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _particleController,
                    builder: (_, __) => CustomPaint(
                      size: const Size(52, 52),
                      painter: _MiniParticlePainter(
                        progress: _particleController.value,
                        color: color,
                      ),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.15),
                          color.withValues(alpha: 0.35),
                        ],
                      ),
                      border: Border.all(
                        color: color.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(a.icon, size: 22, color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // ── Text ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'achievement_toast_label'.tr(),
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    a.titleKey.tr(),
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.deepPurple,
                    ),
                  ),
                  Text(
                    a.descriptionKey.tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // ── Dismiss hint ─────────────────────────────────
            Icon(Icons.close_rounded, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MiniParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  static const _count = 7;
  static final _rng = math.Random(17);
  static final _angles = List.generate(
    _count,
    (i) => _rng.nextDouble() * math.pi * 2,
  );
  static final _speeds = List.generate(
    _count,
    (i) => 0.5 + _rng.nextDouble() * 0.5,
  );

  _MiniParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.width * 0.52;
    final t = Curves.easeOut.transform(math.min(progress * 1.5, 1.0));
    final opacity = (1.0 - progress * 1.1).clamp(0.0, 1.0);

    for (int i = 0; i < _count; i++) {
      final r = t * maxR * _speeds[i];
      final x = cx + r * math.cos(_angles[i]);
      final y = cy + r * math.sin(_angles[i]);
      final paint = Paint()
        ..color = color.withValues(alpha: opacity * 0.75)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 2.5 * (1.0 - t * 0.4), paint);
    }
  }

  @override
  bool shouldRepaint(_MiniParticlePainter old) => old.progress != progress;
}

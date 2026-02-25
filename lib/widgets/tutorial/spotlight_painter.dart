import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class SpotlightPainter extends CustomPainter {
  final Rect? spotlightRect;
  final double borderRadius;
  final double overlayOpacity;
  final double pulseValue;
  final Color glowColor;

  SpotlightPainter({
    this.spotlightRect,
    this.borderRadius = 12,
    this.overlayOpacity = 0.82,
    this.pulseValue = 0.0,
    this.glowColor = const Color(0xFF9B6DFF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;

    if (spotlightRect == null) {
      // No spotlight — just draw the dark overlay
      final paint = Paint()..color = Colors.black.withValues(alpha: overlayOpacity);
      canvas.drawRect(fullRect, paint);
      return;
    }

    // Expand spotlight by pulse amount for breathing effect
    final pulseExpand = pulseValue * 4.0;
    final animatedRect = spotlightRect!.inflate(pulseExpand);
    final rr = RRect.fromRectAndRadius(
      animatedRect,
      Radius.circular(borderRadius + pulseExpand),
    );

    // Draw dark overlay with cutout
    final overlayPath = Path()..addRect(fullRect);
    final holePath = Path()..addRRect(rr);
    final combinedPath = Path.combine(PathOperation.difference, overlayPath, holePath);

    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: overlayOpacity);
    canvas.drawPath(combinedPath, overlayPaint);

    // Animated glow ring around the spotlight
    final glowOpacity = 0.35 + (pulseValue * 0.25);
    final glowWidth = 2.5 + (pulseValue * 1.5);

    // Outer glow (soft, wider)
    final outerGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowWidth + 4
      ..color = glowColor.withValues(alpha: glowOpacity * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(rr.inflate(2), outerGlowPaint);

    // Inner glow (sharper)
    final innerGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = glowWidth
      ..shader = ui.Gradient.sweep(
        animatedRect.center,
        [
          glowColor.withValues(alpha: glowOpacity),
          glowColor.withValues(alpha: glowOpacity * 0.4),
          glowColor.withValues(alpha: glowOpacity),
        ],
        [0.0, 0.5, 1.0],
        TileMode.clamp,
        0,
        2 * pi,
      );
    canvas.drawRRect(rr, innerGlowPaint);
  }

  @override
  bool shouldRepaint(SpotlightPainter old) =>
      old.spotlightRect != spotlightRect ||
      old.overlayOpacity != overlayOpacity ||
      old.pulseValue != pulseValue ||
      old.borderRadius != borderRadius;
}

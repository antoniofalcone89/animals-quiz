import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// A small circular golden coin icon drawn with canvas.
class CoinIcon extends StatelessWidget {
  final double size;
  final bool light;

  const CoinIcon({super.key, this.size = 22, this.light = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CoinPainter(light: light),
    );
  }
}

class _CoinPainter extends CustomPainter {
  final bool light;
  _CoinPainter({required this.light});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);

    // Outer coin ring
    final ringPaint = Paint()
      ..color = light ? const Color(0xFFFFD966) : const Color(0xFFF0A500)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r, ringPaint);

    // Inner lighter face
    final facePaint = Paint()
      ..color = light ? const Color(0xFFFFE680) : const Color(0xFFFFCC33)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r * 0.78, facePaint);

    // "$" symbol
    final textPainter = TextPainter(
      text: TextSpan(
        text: '\$',
        style: TextStyle(
          fontSize: r * 0.95,
          fontWeight: FontWeight.w900,
          color: light ? const Color(0xFFC87800) : const Color(0xFFA05F00),
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_CoinPainter old) => old.light != light;
}

class CoinBadge extends StatelessWidget {
  final int coins;
  final bool light;

  const CoinBadge({super.key, required this.coins, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: light
            ? Colors.white.withValues(alpha: 0.2)
            : AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: light
              ? Colors.white.withValues(alpha: 0.3)
              : AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CoinIcon(size: 20, light: light),
          const SizedBox(width: 5),
          Text(
            '$coins',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: light ? Colors.white : AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}

class PointsBadge extends StatelessWidget {
  final int points;
  final bool light;

  const PointsBadge({super.key, required this.points, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: light
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.deepPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: light
              ? Colors.white.withValues(alpha: 0.3)
              : AppColors.deepPurple.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars_rounded,
            size: 18,
            color: light ? Colors.white : AppColors.deepPurple,
          ),
          const SizedBox(width: 4),
          Text(
            '$points',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: light ? Colors.white : AppColors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}

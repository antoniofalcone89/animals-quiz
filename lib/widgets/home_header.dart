import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'coin_badge.dart';
import 'shimmer_loading.dart';

enum _BadgeInfoType { coins, points, streak }

class HomeHeader extends StatefulWidget {
  static const double height = 118;

  final String username;
  final int totalCoins;
  final int totalPoints;
  final int currentStreak;
  final bool isStreakBroken;
  final bool isStatsLoading;

  const HomeHeader({
    super.key,
    required this.username,
    required this.totalCoins,
    required this.totalPoints,
    required this.currentStreak,
    this.isStreakBroken = false,
    this.isStatsLoading = false,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> with TickerProviderStateMixin {
  late final AnimationController _streakPulseController;
  bool _showStreakNew = false;

  @override
  void initState() {
    super.initState();
    _streakPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );
  }

  @override
  void didUpdateWidget(covariant HomeHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStreak > oldWidget.currentStreak) {
      _streakPulseController
        ..reset()
        ..forward();
      setState(() => _showStreakNew = true);
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (mounted) setState(() => _showStreakNew = false);
      });
    }
  }

  @override
  void dispose() {
    _streakPulseController.dispose();
    super.dispose();
  }

  void _showBadgeInfo(BuildContext context, _BadgeInfoType type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      isScrollControlled: false,
      builder: (_) => _BadgeInfoSheet(type: type),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: HomeHeader.height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'hello_user'.tr(args: [widget.username.split(' ').first]),
              style: GoogleFonts.nunito(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.deepPurple,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                widget.isStatsLoading
                    ? _statsBadgeShimmer()
                    : _PressableWrapper(
                        onTap: () =>
                            _showBadgeInfo(context, _BadgeInfoType.coins),
                        child: CoinBadge(coins: widget.totalCoins),
                      ),
                const SizedBox(width: 8),
                widget.isStatsLoading
                    ? _statsBadgeShimmer()
                    : _PressableWrapper(
                        onTap: () =>
                            _showBadgeInfo(context, _BadgeInfoType.points),
                        child: PointsBadge(points: widget.totalPoints),
                      ),
                const SizedBox(width: 8),
                widget.isStatsLoading
                    ? _statsBadgeShimmer()
                    : _PressableWrapper(
                        onTap: () =>
                            _showBadgeInfo(context, _BadgeInfoType.streak),
                        child: _StreakBadge(
                          streak: widget.isStreakBroken
                              ? 0
                              : widget.currentStreak,
                          pulse: _streakPulseController,
                          showNewLabel: _showStreakNew,
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsBadgeShimmer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 86,
        height: 34,
        child: ShimmerLoading(
          baseColor: const Color(0xFFE5E5E5),
          highlightColor: const Color(0xFFF2F2F2),
        ),
      ),
    );
  }
}

class _PressableWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableWrapper({required this.child, required this.onTap});

  @override
  State<_PressableWrapper> createState() => _PressableWrapperState();
}

class _PressableWrapperState extends State<_PressableWrapper> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}

class _BadgeInfoSheet extends StatefulWidget {
  final _BadgeInfoType type;

  const _BadgeInfoSheet({required this.type});

  @override
  State<_BadgeInfoSheet> createState() => _BadgeInfoSheetState();
}

class _BadgeInfoSheetState extends State<_BadgeInfoSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _slide = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(curved);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor;
    final Widget icon;
    final String title;
    final String body;

    switch (widget.type) {
      case _BadgeInfoType.coins:
        accentColor = AppColors.gold;
        icon = CoinIcon(size: 40);
        title = 'info_coins_title'.tr();
        body = 'info_coins_body'.tr();
      case _BadgeInfoType.points:
        accentColor = AppColors.deepPurple;
        icon = Icon(Icons.stars_rounded, size: 40, color: accentColor);
        title = 'info_points_title'.tr();
        body = 'info_points_body'.tr();
      case _BadgeInfoType.streak:
        accentColor = Colors.orange;
        icon = Icon(
          Icons.local_fire_department_rounded,
          size: 40,
          color: accentColor,
        );
        title = 'info_streak_title'.tr();
        body = 'info_streak_body'.tr();
    }

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.15),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.12),
                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                ),
                child: Center(child: icon),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'tutorial_done'.tr(),
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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

class _StreakBadge extends StatelessWidget {
  final int streak;
  final Animation<double> pulse;
  final bool showNewLabel;

  const _StreakBadge({
    required this.streak,
    required this.pulse,
    required this.showNewLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final t = pulse.value;
        final scale = 1 + (0.18 * (1 - (2 * (t - 0.5)).abs()));
        final glowAlpha = (0.28 * (1 - (2 * (t - 0.5)).abs())).clamp(0.0, 0.28);

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.26)),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: glowAlpha),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  size: 18,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.orange.shade700,
                  ),
                ),
                if (showNewLabel) ...[
                  const SizedBox(width: 4),
                  Text(
                    'streak_new'.tr(),
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

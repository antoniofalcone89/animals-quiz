import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/leaderboard_entry.dart';
import '../services/service_locator.dart';
import '../theme/app_theme.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  List<LeaderboardEntry>? _entries;
  String? _currentUserId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = ServiceLocator.instance.authRepository;
      final entriesFuture =
          ServiceLocator.instance.leaderboardRepository.getLeaderboard();
      final userFuture = auth.getCurrentUser();
      final entries = await entriesFuture;
      final user = await userFuture;

      if (!mounted) return;
      setState(() {
        _entries = entries;
        _currentUserId = user?.id;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLeaderboard,
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(
            children: [
              const Icon(Icons.leaderboard_rounded, color: AppColors.deepPurple, size: 28),
              const SizedBox(width: 10),
              Text(
                'leaderboard'.tr(),
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepPurple,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _entries!.length,
            itemBuilder: (context, index) {
              final entry = _entries![index];
              return _LeaderboardTile(
                entry: entry,
                isCurrentUser: entry.userId == _currentUserId,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Unified tile ─────────────────────────────────────────────────────────────

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _LeaderboardTile({required this.entry, required this.isCurrentUser});

  bool get _isTop3 => entry.rank <= 3;

  static const _gold = Color(0xFFFFB800);
  static const _silver = Color(0xFFB0BEC5);
  static const _bronze = Color(0xFFBF8A52);

  Color get _medalColor => switch (entry.rank) {
        1 => _gold,
        2 => _silver,
        3 => _bronze,
        _ => AppColors.deepPurple,
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isCurrentUser
            ? AppColors.deepPurple.withValues(alpha: 0.08)
            : Colors.white,
        border: isCurrentUser
            ? Border.all(color: AppColors.deepPurple, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
            color: isCurrentUser
                ? AppColors.deepPurple.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isCurrentUser ? 12 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Leading: medal icon (top 3) or rank number
            SizedBox(
              width: 40,
              child: _isTop3
                  ? _MedalIcon(rank: entry.rank, size: 32)
                  : Center(
                      child: Text(
                        '${entry.rank}',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: isCurrentUser
                              ? AppColors.deepPurple
                              : Colors.grey[500],
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            // Avatar
            _Avatar(
              photoUrl: entry.photoUrl,
              blurred: _isTop3,
              medalColor: _isTop3 ? _medalColor : null,
            ),
            const SizedBox(width: 12),
            // Username + "you" badge
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      entry.username,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isCurrentUser ? AppColors.deepPurple : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.deepPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'you'.tr(),
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Points
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  size: 16,
                  color: _isTop3 ? _medalColor : AppColors.deepPurple,
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.totalPoints}',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isCurrentUser ? AppColors.deepPurple : Colors.black87,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  'points_abbr'.tr(),
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar (blurred for top 3, normal for others) ───────────────────────────

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final bool blurred;
  final Color? medalColor;

  const _Avatar({required this.photoUrl, required this.blurred, this.medalColor});

  @override
  Widget build(BuildContext context) {
    const size = 40.0;

    Widget image;
    if (photoUrl != null) {
      image = CachedNetworkImage(
        imageUrl: photoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _AvatarFallback(size: size, color: medalColor),
      );
      if (blurred) {
        image = ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: image,
        );
      }
    } else {
      image = _AvatarFallback(size: size, color: medalColor);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: medalColor != null
            ? Border.all(color: medalColor!, width: 2)
            : Border.all(color: AppColors.deepPurple.withValues(alpha: 0.15), width: 1.5),
      ),
      child: ClipOval(child: image),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final double size;
  final Color? color;

  const _AvatarFallback({required this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.deepPurple;
    return Container(
      width: size,
      height: size,
      color: c.withValues(alpha: 0.12),
      child: Icon(Icons.person_rounded, size: size * 0.55, color: c),
    );
  }
}

// ─── Medal icon ───────────────────────────────────────────────────────────────
//
//  Rank 1 → trophy          Icons.emoji_events_rounded      warm gold gradient
//  Rank 2 → military medal  Icons.military_tech_rounded     cool silver gradient
//  Rank 3 → premium badge   Icons.workspace_premium_rounded  rich bronze gradient

class _MedalIcon extends StatelessWidget {
  final int rank;
  final double size;

  const _MedalIcon({required this.rank, required this.size});

  @override
  Widget build(BuildContext context) {
    if (rank < 1 || rank > 3) return const SizedBox.shrink();

    final (icon, lightColor, darkColor) = switch (rank) {
      1 => (
          Icons.emoji_events_rounded,
          const Color(0xFFFFD54F),
          const Color(0xFFBF6F00),
        ),
      2 => (
          Icons.military_tech_rounded,
          const Color(0xFFECEFF1),
          const Color(0xFF546E7A),
        ),
      _ => (
          Icons.workspace_premium_rounded,
          const Color(0xFFD7A96A),
          const Color(0xFF7B4A1E),
        ),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [lightColor, darkColor],
          center: const Alignment(-0.35, -0.35),
          radius: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: darkColor.withValues(alpha: 0.50),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size * 0.58,
        color: Colors.white.withValues(alpha: 0.95),
      ),
    );
  }
}

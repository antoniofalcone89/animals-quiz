import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'coin_badge.dart';
import 'shimmer_loading.dart';

class HomeHeader extends StatelessWidget {
  static const double height = 118;

  final String username;
  final int totalCoins;
  final int totalPoints;
  final bool isStatsLoading;

  const HomeHeader({
    super.key,
    required this.username,
    required this.totalCoins,
    required this.totalPoints,
    this.isStatsLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'hello_user'.tr(args: [username.split(' ').first]),
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
                isStatsLoading
                    ? _statsBadgeShimmer()
                    : CoinBadge(coins: totalCoins),
                const SizedBox(width: 8),
                isStatsLoading
                    ? _statsBadgeShimmer()
                    : PointsBadge(points: totalPoints),
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

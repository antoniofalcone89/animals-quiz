import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'coin_badge.dart';

class HomeHeader extends StatelessWidget {
  final String username;
  final int totalCoins;
  final int totalPoints;

  const HomeHeader({
    super.key,
    required this.username,
    required this.totalCoins,
    required this.totalPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'hello_user'.tr(args: [username.split(' ').first]),
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.deepPurple,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CoinBadge(coins: totalCoins),
              const SizedBox(width: 8),
              PointsBadge(points: totalPoints),
            ],
          ),
        ],
      ),
    );
  }
}

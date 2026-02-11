import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'coin_badge.dart';

class HomeHeader extends StatelessWidget {
  final String username;
  final int totalCoins;

  const HomeHeader({
    super.key,
    required this.username,
    required this.totalCoins,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'hello_user'.tr(args: [username]),
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepPurple,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CoinBadge(coins: totalCoins),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Text(
            'play_today'.tr(),
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}

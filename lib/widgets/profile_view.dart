import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ProfileView extends StatelessWidget {
  final String username;
  final int totalCoins;

  const ProfileView({
    super.key,
    required this.username,
    required this.totalCoins,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.deepPurple.withValues(alpha: 0.1),
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: GoogleFonts.nunito(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: AppColors.deepPurple,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            username,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('\u{1FA99}', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Text(
                '$totalCoins ${'total_coins'.tr()}',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: const Icon(Icons.language, color: AppColors.deepPurple),
              title: Text(
                'language'.tr(),
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepPurple,
                ),
              ),
              trailing: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'it',
                    label: Text('IT', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  ),
                  ButtonSegment(
                    value: 'en',
                    label: Text('EN', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  ),
                ],
                selected: {currentLocale.languageCode},
                onSelectionChanged: (selected) {
                  context.setLocale(Locale(selected.first));
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.deepPurple;
                    }
                    return Colors.transparent;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return AppColors.deepPurple;
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

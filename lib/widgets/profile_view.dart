import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/env.dart';
import '../services/tutorial_service.dart';
import '../theme/app_theme.dart';
import 'coin_badge.dart';
import 'shimmer_loading.dart';

class ProfileView extends StatelessWidget {
  final String username;
  final int totalCoins;
  final int totalPoints;
  final bool isStatsLoading;
  final bool isGuest;
  final VoidCallback? onLogout;
  final ValueChanged<String>? onLocaleChanged;
  final VoidCallback? onLinkWithGoogle;
  final Future<void> Function(String email, String password)? onLinkWithEmail;

  const ProfileView({
    super.key,
    required this.username,
    required this.totalCoins,
    required this.totalPoints,
    this.isStatsLoading = false,
    this.isGuest = false,
    this.onLogout,
    this.onLocaleChanged,
    this.onLinkWithGoogle,
    this.onLinkWithEmail,
  });

  void _showLinkEmailDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'link_with_email'.tr(),
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            color: AppColors.deepPurple,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'email'.tr(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'email_required'.tr();
                  }
                  if (!value.contains('@')) {
                    return 'email_required'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'password'.tr(),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'password_required'.tr();
                  }
                  if (value.length < 6) {
                    return 'password_min_length'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'confirm_password'.tr(),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != passwordController.text) {
                    return 'passwords_must_match'.tr();
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                try {
                  await onLinkWithEmail?.call(
                    emailController.text,
                    passwordController.text,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('account_linked'.tr()),
                        backgroundColor: AppColors.correctGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('account_link_error'.tr()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: Text('link_account'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 48,
            backgroundColor: isGuest
                ? Colors.orange.withValues(alpha: 0.1)
                : AppColors.deepPurple.withValues(alpha: 0.1),
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: GoogleFonts.nunito(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: isGuest ? Colors.orange : AppColors.deepPurple,
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
          if (isGuest)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'guest_account'.tr(),
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isStatsLoading
                  ? _statsBadgeShimmer()
                  : CoinBadge(coins: totalCoins),
              const SizedBox(width: 10),
              isStatsLoading
                  ? _statsBadgeShimmer()
                  : PointsBadge(points: totalPoints),
            ],
          ),
          const SizedBox(height: 32),

          // Guest account linking section
          if (isGuest) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.deepPurple.withValues(alpha: 0.06),
                    AppColors.lightPurple.withValues(alpha: 0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.deepPurple.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.deepPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.deepPurple,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'link_account_title'.tr(),
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'link_account_description'.tr(),
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onLinkWithGoogle,
                      icon: const Text(
                        'G',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      label: Text(
                        'link_with_google'.tr(),
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLinkEmailDialog(context),
                      icon: Icon(
                        Icons.email_outlined,
                        size: 18,
                        color: AppColors.deepPurple.withValues(alpha: 0.7),
                      ),
                      label: Text(
                        'link_with_email'.tr(),
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.deepPurple.withValues(alpha: 0.7),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.deepPurple,
                        side: BorderSide(
                          color: AppColors.deepPurple.withValues(alpha: 0.25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

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
                    label: Text(
                      'IT',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                    ),
                  ),
                  ButtonSegment(
                    value: 'en',
                    label: Text(
                      'EN',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                selected: {currentLocale.languageCode},
                onSelectionChanged: (selected) {
                  final locale = selected.first;
                  context.setLocale(Locale(locale));
                  onLocaleChanged?.call(locale);
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
          if (Env.debugUnlockAll) ...[
            const SizedBox(height: 12),
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
                leading: const Icon(Icons.replay, color: Colors.orange),
                title: Text(
                  'Reset Tutorial',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: Colors.orange,
                  ),
                ),
                onTap: () async {
                  await TutorialService.resetTutorial();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tutorial reset — open level 1 to see it again')),
                    );
                  }
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
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
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                'logout'.tr(),
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
              onTap: onLogout,
            ),
          ),
        ],
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

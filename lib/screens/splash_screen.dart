import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/env.dart';
import '../models/game_state.dart';
import '../services/service_locator.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    if (Env.isMock) {
      if (mounted) setState(() => _checking = false);
      return;
    }

    final sl = ServiceLocator.instance;
    final authRepo = sl.authRepository;

    if (!authRepo.isSignedIn) {
      if (mounted) setState(() => _checking = false);
      return;
    }

    // User has a Firebase session — try to restore their profile
    try {
      final user = await authRepo.getCurrentUser().timeout(
        const Duration(seconds: 8),
        onTimeout: () => null,
      );
      if (user != null && mounted) {
        final gameState = GameState(quizRepository: sl.quizRepository);
        final username = authRepo.displayName ?? user.username;
        gameState.setUsername(username);
        gameState.setPhotoUrl(authRepo.photoUrl);
        gameState.setInitialStats(
          coins: user.totalCoins,
          points: user.totalPoints,
        );
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                HomeScreen(gameState: gameState),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 400),
          ),
          (route) => false,
        );
        return;
      }
    } catch (_) {
      // Profile fetch failed — fall through to normal splash
    }

    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.purpleGradient),
        child: SafeArea(
          child: _checking
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Column(
                  children: [
                    const SizedBox(height: 60),
                    // Decorative floating elements
                    const Text(
                      '\u{2B50} \u{1F43E} \u{1F981} \u{1F438} \u{2728}',
                      style: TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '\u{2728} \u{1F98B} \u{1F99C} \u{1F42C} \u{2B50}',
                      style: TextStyle(fontSize: 28),
                    ),
                    const Spacer(),
                    // App title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'welcome_title'.tr(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'welcome_subtitle'.tr(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Get Started button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const LoginScreen(),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                transitionDuration: const Duration(
                                  milliseconds: 400,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: Text(
                            'get_started'.tr(),
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
        ),
      ),
    );
  }
}

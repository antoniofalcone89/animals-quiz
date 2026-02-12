import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import '../services/service_locator.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();

  void _navigateToHome(GameState gameState) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            HomeScreen(gameState: gameState),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  GameState _createGameState(String username) {
    final sl = ServiceLocator.instance;
    final gameState = GameState(quizRepository: sl.quizRepository);
    gameState.setUsername(username);
    return gameState;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.purpleGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 50),
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
                const SizedBox(height: 40),
                // Title
                Text(
                  'welcome_title'.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'welcome_subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 48),
                // Username field
                TextField(
                  controller: _usernameController,
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'enter_name'.tr(),
                    hintStyle: GoogleFonts.nunito(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.deepPurple),
                  ),
                ),
                const SizedBox(height: 24),
                // Login with Google button (mock)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final username = _usernameController.text.isEmpty
                          ? 'Player'
                          : _usernameController.text;
                      final gameState = _createGameState(username);
                      _navigateToHome(gameState);
                    },
                    icon: Image.network(
                      'https://placehold.co/24x24/white/333?text=G',
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.g_mobiledata,
                        size: 28,
                        color: AppColors.deepPurple,
                      ),
                    ),
                    label: Text(
                      'login_google'.tr(),
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepPurple,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Continue as Guest
                TextButton(
                  onPressed: () {
                    final gameState = _createGameState('Guest');
                    _navigateToHome(gameState);
                  },
                  child: Text(
                    'continue_guest'.tr(),
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.9),
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
  bool _isLoading = false;
  String? _errorMessage;
  String? _guestNameError;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_clearGuestNameError);
  }

  void _clearGuestNameError() {
    if (_guestNameError != null) {
      setState(() => _guestNameError = null);
    }
  }

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

  Future<GameState> _createGameState(String username) async {
    final sl = ServiceLocator.instance;
    final gameState = GameState(quizRepository: sl.quizRepository);
    gameState.setUsername(username);
    return gameState;
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sl = ServiceLocator.instance;
      final authRepo = sl.authRepository;

      final success = await authRepo.signInWithGoogle();
      if (!success) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      var user = await authRepo.getCurrentUser();

      if (user == null) {
        final name = authRepo.displayName ?? 'Player';
        user = await authRepo.registerProfile(name);
      }

      final username = authRepo.displayName ?? user.username;
      final gameState = await _createGameState(username);
      gameState.setPhotoUrl(authRepo.photoUrl);
      gameState.setInitialStats(
        coins: user.totalCoins,
        points: user.totalPoints,
      );
      if (mounted) _navigateToHome(gameState);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'auth_error'.tr();
        });
      }
    }
  }

  Future<void> _handleGuestSignIn() async {
    if (_isLoading) return;

    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() => _guestNameError = 'name_required'.tr());
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _guestNameError = null;
    });

    try {
      final sl = ServiceLocator.instance;
      final authRepo = sl.authRepository;

      await authRepo.signInAnonymously();

      final user = await authRepo.registerProfile(username);

      final gameState = await _createGameState(user.username);
      gameState.setInitialStats(
        coins: user.totalCoins,
        points: user.totalPoints,
      );
      if (mounted) _navigateToHome(gameState);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'auth_error'.tr();
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.removeListener(_clearGuestNameError);
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[200],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Google Sign-In button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Image.network(
                            'https://placehold.co/24x24/white/333?text=G',
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.g_mobiledata,
                                  size: 28,
                                  color: AppColors.deepPurple,
                                ),
                          ),
                    label: Text(
                      _isLoading ? 'signing_in'.tr() : 'login_google'.tr(),
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
                const SizedBox(height: 32),
                // --- OR --- divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.4),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or_divider'.tr(),
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.4),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Guest name field
                TextField(
                  controller: _usernameController,
                  enabled: !_isLoading,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'enter_name'.tr(),
                    hintStyle: GoogleFonts.nunito(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: _guestNameError != null
                          ? BorderSide(color: Colors.red[300]!, width: 2)
                          : BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.deepPurple,
                    ),
                  ),
                ),
                if (_guestNameError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _guestNameError!,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[200],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Continue as Guest button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleGuestSignIn,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: Colors.white.withValues(
                          alpha: _isLoading ? 0.3 : 0.8,
                        ),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'guest_login'.tr(),
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(
                          alpha: _isLoading ? 0.4 : 1.0,
                        ),
                      ),
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

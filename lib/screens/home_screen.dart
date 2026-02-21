import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import '../services/service_locator.dart';
import '../theme/app_theme.dart';
import '../widgets/home_header.dart';
import '../widgets/leaderboard_view.dart';
import '../widgets/level_grid.dart';
import '../widgets/profile_view.dart';
import 'level_detail_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final GameState gameState;

  const HomeScreen({super.key, required this.gameState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.gameState.addListener(_onStateChanged);
    widget.gameState.loadLevels();
    widget.gameState.loadProgress();
  }

  @override
  void dispose() {
    widget.gameState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _handleLocaleChanged(String locale) {
    ServiceLocator.instance.setLocale(locale);
    widget.gameState.loadLevels();
  }

  Future<void> _handleLogout() async {
    final authRepo = ServiceLocator.instance.authRepository;
    await authRepo.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: SafeArea(
        child: _currentIndex == 0
            ? _buildHome()
            : _currentIndex == 1
                ? const LeaderboardView()
                : ProfileView(
                    username: widget.gameState.username,
                    totalCoins: widget.gameState.totalCoins,
                    onLogout: _handleLogout,
                    onLocaleChanged: _handleLocaleChanged,
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppColors.deepPurple,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: 'home'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.leaderboard_rounded), label: 'leaderboard'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.person_rounded), label: 'profile'.tr()),
        ],
      ),
    );
  }

  Widget _buildHome() {
    if (widget.gameState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.gameState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              widget.gameState.error!,
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.gameState.loadLevels();
                widget.gameState.loadProgress();
              },
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeHeader(
          username: widget.gameState.username,
          totalCoins: widget.gameState.totalCoins,
        ),
        Expanded(
          child: LevelGrid(
            gameState: widget.gameState,
            onLevelTap: (level) async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LevelDetailScreen(
                    level: level,
                    gameState: widget.gameState,
                  ),
                ),
              );
              setState(() {});
            },
          ),
        ),
      ],
    );
  }
}

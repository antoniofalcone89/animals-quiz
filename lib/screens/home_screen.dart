import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/quiz_data.dart';
import '../models/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/home_header.dart';
import '../widgets/level_grid.dart';
import '../widgets/profile_view.dart';
import 'level_detail_screen.dart';

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
    // Initialize level progress
    for (final level in quizLevels) {
      widget.gameState.initLevel(level.id, level.animals.length);
    }
    widget.gameState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.gameState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: SafeArea(
        child: _currentIndex == 0
            ? _buildHome()
            : _currentIndex == 2
                ? ProfileView(
                    username: widget.gameState.username,
                    totalCoins: widget.gameState.totalCoins,
                  )
                : _buildPlaceholder(),
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

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'coming_soon'.tr(),
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
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

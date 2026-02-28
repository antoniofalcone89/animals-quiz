import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/achievement.dart';
import '../models/game_state.dart';
import '../services/service_locator.dart';
import '../theme/app_theme.dart';
import '../widgets/achievement_toast.dart';
import '../widgets/home_header.dart';
import '../widgets/leaderboard_view.dart';
import '../widgets/level_grid.dart';
import '../widgets/profile_view.dart';
import 'daily_challenge_screen.dart';
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

  /// IDs of achievements already known to be unlocked — used to detect new ones.
  final Set<String> _knownUnlockedIds = {};

  /// While loading initial progress we skip toasts (avoid false positives).
  bool _initialLoadDone = false;

  /// Count of newly unlocked achievements not yet seen on the Profile tab.
  int _unseenAchievementsCount = 0;

  @override
  void initState() {
    super.initState();
    widget.gameState.addListener(_onStateChanged);
    widget.gameState.loadLevels();
    widget.gameState.loadProgress();
    widget.gameState.loadTodayChallenge();
  }

  @override
  void dispose() {
    widget.gameState.removeListener(_onStateChanged);
    super.dispose();
  }

  List<Achievement> _computeAchievements() {
    final gs = widget.gameState;
    return AchievementService.compute(
      totalPoints: gs.totalPoints,
      totalCoins: gs.totalCoins,
      currentStreak: gs.currentStreak,
      levelProgress: gs.levelProgress,
      hintsProgress: gs.hintsProgress,
      totalLevels: gs.levels.length,
    );
  }

  void _onStateChanged() {
    if (!mounted) return;
    if (_initialLoadDone) {
      _checkNewAchievements();
    }
    setState(() {});
  }

  void _checkNewAchievements() {
    final achievements = _computeAchievements();
    for (final a in achievements) {
      if (a.isUnlocked && !_knownUnlockedIds.contains(a.id)) {
        _knownUnlockedIds.add(a.id);
        // Only count as unseen if the user is not currently on the Profile tab.
        if (_currentIndex != 2) {
          _unseenAchievementsCount++;
        }
        // Delay slightly so the UI frame settles before the toast appears.
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) showAchievementToast(context, a);
        });
      }
    }
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

  Future<void> _handleLinkWithGoogle() async {
    final authRepo = ServiceLocator.instance.authRepository;
    try {
      final success = await authRepo.linkWithGoogle();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('account_linked'.tr()),
            backgroundColor: AppColors.correctGreen,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('account_link_error'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLinkWithEmail(String email, String password) async {
    final authRepo = ServiceLocator.instance.authRepository;
    try {
      await authRepo.linkWithEmailPassword(email, password);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      rethrow;
    }
  }

  void _handleDebugForceStreakBonus() {
    widget.gameState.debugForceStreakBonus();
    setState(() {});
  }

  Future<void> _openDailyChallenge() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DailyChallengeScreen(gameState: widget.gameState),
      ),
    );
    await widget.gameState.loadTodayChallenge();
    if (mounted) setState(() {});
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
                photoUrl: widget.gameState.photoUrl,
                totalCoins: widget.gameState.totalCoins,
                totalPoints: widget.gameState.totalPoints,
                currentStreak: widget.gameState.currentStreak,
                isStatsLoading: widget.gameState.isStatsLoading,
                isGuest: ServiceLocator.instance.authRepository.isAnonymous,
                onLogout: _handleLogout,
                onLocaleChanged: _handleLocaleChanged,
                onLinkWithGoogle: _handleLinkWithGoogle,
                onLinkWithEmail: _handleLinkWithEmail,
                onDebugForceStreakBonus: _handleDebugForceStreakBonus,
                levelProgress: widget.gameState.levelProgress,
                hintsProgress: widget.gameState.hintsProgress,
                totalLevels: widget.gameState.levels.length,
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 2 && _unseenAchievementsCount > 0) {
            setState(() {
              _unseenAchievementsCount = 0;
              _currentIndex = i;
            });
          } else {
            setState(() => _currentIndex = i);
          }
        },
        selectedItemColor: AppColors.deepPurple,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: 'home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.leaderboard_rounded),
            label: 'leaderboard'.tr(),
          ),
          BottomNavigationBarItem(
            icon: _ProfileNavIcon(unseenCount: _unseenAchievementsCount),
            label: 'profile'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    if (widget.gameState.isLoading) {
      return Column(
        children: [
          HomeHeader(
            username: widget.gameState.username,
            totalCoins: widget.gameState.totalCoins,
            totalPoints: widget.gameState.totalPoints,
            currentStreak: widget.gameState.currentStreak,
            isStreakBroken: widget.gameState.isStreakBroken,
            isStatsLoading: true,
          ),
          const Expanded(child: ClipRect(child: LevelGridSkeleton())),
        ],
      );
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
                widget.gameState.loadTodayChallenge();
              },
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        HomeHeader(
          username: widget.gameState.username,
          totalCoins: widget.gameState.totalCoins,
          totalPoints: widget.gameState.totalPoints,
          currentStreak: widget.gameState.currentStreak,
          isStreakBroken: widget.gameState.isStreakBroken,
          isStatsLoading: widget.gameState.isStatsLoading,
        ),
        if (widget.gameState.isStreakBroken)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.26),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'streak_broken'.tr(),
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: ClipRect(
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _DailyChallengeCard(
            gameState: widget.gameState,
            onPlay: _openDailyChallenge,
          ),
        ),
      ],
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onPlay;

  const _DailyChallengeCard({required this.gameState, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final challenge = gameState.todayChallenge;
    final isCompleted = challenge?.completed == true;
    final isLoading = gameState.isChallengeLoading && challenge == null;

    return GestureDetector(
      onTap: (challenge != null && !isLoading) ? onPlay : null,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isCompleted
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7B42F6), Color(0xFF5C2DB8)],
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  (isCompleted ? const Color(0xFF2E7D32) : AppColors.deepPurple)
                      .withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Left: icon + text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.local_fire_department_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'daily_challenge'.tr(),
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (isLoading)
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    else if (gameState.challengeError != null &&
                        challenge == null)
                      Text(
                        gameState.challengeError!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      )
                    else if (challenge != null) ...[
                      Text(
                        isCompleted
                            ? 'challenge_score'.tr(
                                args: [(challenge.score ?? 0).toString()],
                              )
                            : 'challenges_today'.tr(
                                args: [
                                  challenge.progress.toString(),
                                  challenge.animals.length.toString(),
                                ],
                              ),
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      if (!isCompleted && challenge.animals.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value:
                                challenge.progress / challenge.animals.length,
                            minHeight: 5,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.25,
                            ),
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Right: CTA button
              _ChallengeButton(
                isCompleted: isCompleted,
                isLoading: isLoading,
                hasChallenge: challenge != null,
                onTap: onPlay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengeButton extends StatefulWidget {
  final bool isCompleted;
  final bool isLoading;
  final bool hasChallenge;
  final VoidCallback onTap;

  const _ChallengeButton({
    required this.isCompleted,
    required this.isLoading,
    required this.hasChallenge,
    required this.onTap,
  });

  @override
  State<_ChallengeButton> createState() => _ChallengeButtonState();
}

class _ChallengeButtonState extends State<_ChallengeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.hasChallenge && !widget.isLoading;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            widget.isCompleted
                ? 'challenge_completed'.tr()
                : 'play_challenge'.tr(),
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: widget.isCompleted
                  ? const Color(0xFF2E7D32)
                  : AppColors.deepPurple,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile nav icon with animated badge dot
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileNavIcon extends StatefulWidget {
  final int unseenCount;
  const _ProfileNavIcon({required this.unseenCount});

  @override
  State<_ProfileNavIcon> createState() => _ProfileNavIconState();
}

class _ProfileNavIconState extends State<_ProfileNavIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.unseenCount > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_ProfileNavIcon old) {
    super.didUpdateWidget(old);
    if (widget.unseenCount > 0 && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.unseenCount == 0 && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.person_rounded),
        if (widget.unseenCount > 0)
          Positioned(
            top: -4,
            right: -6,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Transform.scale(
                scale: _pulseAnim.value,
                child: child,
              ),
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 3),
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.unseenCount > 9 ? '9+' : '${widget.unseenCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

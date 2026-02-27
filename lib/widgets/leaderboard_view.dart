import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/leaderboard_entry.dart';
import '../services/service_locator.dart';
import '../theme/app_theme.dart';
import 'shimmer_loading.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  List<LeaderboardEntry>? _globalEntries;
  List<LeaderboardEntry>? _dailyEntries;
  String? _currentUserId;
  bool _isLoadingGlobal = true;
  bool _isLoadingDaily = true;
  String? _globalError;
  String? _dailyError;

  final _globalScrollCtrl = ScrollController();
  final _dailyScrollCtrl = ScrollController();
  bool _showGlobalTopBtn = false;
  bool _showDailyTopBtn = false;
  bool _showFindingBanner = false;

  // Approximate item height: 40 avatar + 20 v-padding + 8 bottom margin
  static const _itemHeight = 68.0;
  static const _listPaddingTop = 10.0;
  // How many items above the user to show
  static const _leadingItems = 2;

  @override
  void initState() {
    super.initState();
    _globalScrollCtrl.addListener(() {
      final show = _globalScrollCtrl.offset > 120;
      if (show != _showGlobalTopBtn) setState(() => _showGlobalTopBtn = show);
    });
    _dailyScrollCtrl.addListener(() {
      final show = _dailyScrollCtrl.offset > 120;
      if (show != _showDailyTopBtn) setState(() => _showDailyTopBtn = show);
    });
    _loadLeaderboards();
  }

  @override
  void dispose() {
    _globalScrollCtrl.dispose();
    _dailyScrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboards() async {
    _loadLeaderboard(global: true);
    _loadLeaderboard(global: false);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await ServiceLocator.instance.authRepository
          .getCurrentUser();
      if (!mounted) return;
      setState(() => _currentUserId = user?.id);
      // Re-attempt scroll once we know who the user is
      _scrollToUser(entries: _globalEntries, ctrl: _globalScrollCtrl);
      _scrollToUser(entries: _dailyEntries, ctrl: _dailyScrollCtrl);
    } catch (_) {}
  }

  Future<void> _loadLeaderboard({required bool global}) async {
    setState(() {
      if (global) {
        _isLoadingGlobal = true;
        _globalError = null;
      } else {
        _isLoadingDaily = true;
        _dailyError = null;
      }
    });

    try {
      final repository = ServiceLocator.instance.leaderboardRepository;
      final entries = global
          ? await repository.getLeaderboard()
          : await repository.getDailyChallengeLeaderboard();

      if (!mounted) return;
      setState(() {
        if (global) {
          _globalEntries = entries;
          _isLoadingGlobal = false;
        } else {
          _dailyEntries = entries;
          _isLoadingDaily = false;
        }
      });
      // Scroll after the list has been laid out
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (global) {
          _scrollToUser(entries: _globalEntries, ctrl: _globalScrollCtrl);
        } else {
          _scrollToUser(entries: _dailyEntries, ctrl: _dailyScrollCtrl);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (global) {
          _globalError = e.toString();
          _isLoadingGlobal = false;
        } else {
          _dailyError = e.toString();
          _isLoadingDaily = false;
        }
      });
    }
  }

  Future<void> _scrollToUser({
    required List<LeaderboardEntry>? entries,
    required ScrollController ctrl,
  }) async {
    if (_currentUserId == null || entries == null) return;
    final index = entries.indexWhere((e) => e.userId == _currentUserId);
    if (index < 0) return;
    // Already at/near top — no need to scroll
    if (index < _leadingItems) return;

    final targetIndex = (index - _leadingItems).clamp(0, entries.length - 1);
    final offset = _listPaddingTop + targetIndex * _itemHeight;

    if (!ctrl.hasClients) return;
    final maxScroll = ctrl.position.maxScrollExtent;
    final clampedOffset = offset.clamp(0.0, maxScroll);
    if (clampedOffset <= 0) return;

    // Show "finding your position" banner
    if (mounted) setState(() => _showFindingBanner = true);

    await ctrl.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );

    // Keep banner visible briefly, then fade out
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _showFindingBanner = false);
  }

  Future<void> _scrollToTop(ScrollController ctrl) async {
    await ctrl.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.leaderboard_rounded,
                  color: AppColors.deepPurple,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  'leaderboard'.tr(),
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              labelColor: AppColors.deepPurple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.deepPurple,
              labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800),
              tabs: [
                Tab(text: 'leaderboard'.tr()),
                Tab(text: 'daily_challenge'.tr()),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                TabBarView(
                  children: [
                    _buildList(
                      entries: _globalEntries,
                      isLoading: _isLoadingGlobal,
                      error: _globalError,
                      onRetry: () => _loadLeaderboard(global: true),
                      scrollCtrl: _globalScrollCtrl,
                      showTopBtn: _showGlobalTopBtn,
                      onScrollToTop: () => _scrollToTop(_globalScrollCtrl),
                    ),
                    _buildList(
                      entries: _dailyEntries,
                      isLoading: _isLoadingDaily,
                      error: _dailyError,
                      onRetry: () => _loadLeaderboard(global: false),
                      isDaily: true,
                      scrollCtrl: _dailyScrollCtrl,
                      showTopBtn: _showDailyTopBtn,
                      onScrollToTop: () => _scrollToTop(_dailyScrollCtrl),
                    ),
                  ],
                ),
                // "Finding your position" banner
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: _FindingPositionBanner(visible: _showFindingBanner),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList({
    required List<LeaderboardEntry>? entries,
    required bool isLoading,
    required String? error,
    required VoidCallback onRetry,
    required ScrollController scrollCtrl,
    required bool showTopBtn,
    required VoidCallback onScrollToTop,
    bool isDaily = false,
  }) {
    if (isLoading) {
      return _LeaderboardShimmer();
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              error,
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text('retry'.tr())),
          ],
        ),
      );
    }

    final safeEntries = entries ?? const <LeaderboardEntry>[];
    if (safeEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            isDaily ? 'daily_leaderboard_empty'.tr() : 'coming_soon'.tr(),
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
          itemCount: safeEntries.length,
          itemBuilder: (context, index) {
            final entry = safeEntries[index];
            return _AnimatedTile(
              index: index,
              child: _LeaderboardTile(
                entry: entry,
                isCurrentUser: entry.userId == _currentUserId,
              ),
            );
          },
        ),
        // Bounce-in FAB
        Positioned(
          bottom: 16,
          right: 16,
          child: _BouncyFab(
            visible: showTopBtn,
            heroTag: isDaily ? 'daily_top' : 'global_top',
            onPressed: onScrollToTop,
          ),
        ),
      ],
    );
  }
}

// ─── Shimmer skeleton ─────────────────────────────────────────────────────────

class _LeaderboardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      itemCount: 10,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ShimmerLoading(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Rank placeholder
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                // Avatar placeholder
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                // Name placeholder
                Expanded(
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Score placeholder
                Container(
                  width: 48,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Staggered slide-in tile ──────────────────────────────────────────────────

class _AnimatedTile extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedTile({required this.index, required this.child});

  @override
  State<_AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<_AnimatedTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    // Cap stagger at 20 items so late items don't wait too long
    final staggerMs = (widget.index.clamp(0, 20) * 30).clamp(0, 600);
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: staggerMs), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ─── "Finding your position" banner ──────────────────────────────────────────

class _FindingPositionBanner extends StatelessWidget {
  final bool visible;
  const _FindingPositionBanner({required this.visible});

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, -1.5),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.deepPurple,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepPurple.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'leaderboard_finding_position'.tr(),
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bouncy FAB ───────────────────────────────────────────────────────────────

class _BouncyFab extends StatefulWidget {
  final bool visible;
  final String heroTag;
  final VoidCallback onPressed;

  const _BouncyFab({
    required this.visible,
    required this.heroTag,
    required this.onPressed,
  });

  @override
  State<_BouncyFab> createState() => _BouncyFabState();
}

class _BouncyFabState extends State<_BouncyFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(_BouncyFab old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible) {
      _ctrl.forward(from: 0);
    } else if (!widget.visible && old.visible) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FloatingActionButton.small(
        heroTag: widget.heroTag,
        onPressed: widget.onPressed,
        backgroundColor: AppColors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.keyboard_arrow_up_rounded, size: 24),
      ),
    );
  }
}

// ─── Unified tile ─────────────────────────────────────────────────────────────

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _LeaderboardTile({required this.entry, required this.isCurrentUser});

  bool get _isTop3 => entry.rank <= 3;

  static const _gold = Color(0xFFFFB800);
  static const _silver = Color(0xFFB0BEC5);
  static const _bronze = Color(0xFFBF8A52);

  Color get _medalColor => switch (entry.rank) {
    1 => _gold,
    2 => _silver,
    3 => _bronze,
    _ => AppColors.deepPurple,
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isCurrentUser
            ? AppColors.deepPurple.withValues(alpha: 0.08)
            : Colors.white,
        border: isCurrentUser
            ? Border.all(color: AppColors.deepPurple, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
            color: isCurrentUser
                ? AppColors.deepPurple.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isCurrentUser ? 12 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Leading: medal icon (top 3) or rank number
            SizedBox(
              width: 40,
              child: _isTop3
                  ? _MedalIcon(rank: entry.rank, size: 32)
                  : Center(
                      child: Text(
                        '${entry.rank}',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: isCurrentUser
                              ? AppColors.deepPurple
                              : Colors.grey[500],
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            // Avatar
            _Avatar(
              photoUrl: entry.photoUrl,
              blurred: true,
              medalColor: _isTop3 ? _medalColor : null,
            ),
            const SizedBox(width: 12),
            // Username + "you" badge
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      entry.username,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isCurrentUser
                            ? AppColors.deepPurple
                            : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.deepPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'you'.tr(),
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Points
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  size: 16,
                  color: _isTop3 ? _medalColor : AppColors.deepPurple,
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.totalPoints}',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isCurrentUser
                        ? AppColors.deepPurple
                        : Colors.black87,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  'points_abbr'.tr(),
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar (blurred for top 3, normal for others) ───────────────────────────

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final bool blurred;
  final Color? medalColor;

  const _Avatar({
    required this.photoUrl,
    required this.blurred,
    this.medalColor,
  });

  @override
  Widget build(BuildContext context) {
    const size = 40.0;

    Widget image;
    if (photoUrl != null) {
      image = CachedNetworkImage(
        imageUrl: photoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) =>
            _AvatarFallback(size: size, color: medalColor),
      );
      if (blurred) {
        image = ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: image,
        );
      }
    } else {
      image = _AvatarFallback(size: size, color: medalColor);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: medalColor != null
            ? Border.all(color: medalColor!, width: 2)
            : Border.all(
                color: AppColors.deepPurple.withValues(alpha: 0.15),
                width: 1.5,
              ),
      ),
      child: ClipOval(child: image),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final double size;
  final Color? color;

  const _AvatarFallback({required this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.deepPurple;
    return Container(
      width: size,
      height: size,
      color: c.withValues(alpha: 0.12),
      child: Icon(Icons.person_rounded, size: size * 0.55, color: c),
    );
  }
}

// ─── Medal icon ───────────────────────────────────────────────────────────────
//
//  Rank 1 → trophy          Icons.emoji_events_rounded      warm gold gradient
//  Rank 2 → military medal  Icons.military_tech_rounded     cool silver gradient
//  Rank 3 → premium badge   Icons.workspace_premium_rounded  rich bronze gradient

class _MedalIcon extends StatelessWidget {
  final int rank;
  final double size;

  const _MedalIcon({required this.rank, required this.size});

  @override
  Widget build(BuildContext context) {
    if (rank < 1 || rank > 3) return const SizedBox.shrink();

    final (icon, lightColor, darkColor) = switch (rank) {
      1 => (
        Icons.emoji_events_rounded,
        const Color(0xFFFFD54F),
        const Color(0xFFBF6F00),
      ),
      2 => (
        Icons.military_tech_rounded,
        const Color(0xFFECEFF1),
        const Color(0xFF546E7A),
      ),
      _ => (
        Icons.workspace_premium_rounded,
        const Color(0xFFD7A96A),
        const Color(0xFF7B4A1E),
      ),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [lightColor, darkColor],
          center: const Alignment(-0.35, -0.35),
          radius: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: darkColor.withValues(alpha: 0.50),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size * 0.58,
        color: Colors.white.withValues(alpha: 0.95),
      ),
    );
  }
}

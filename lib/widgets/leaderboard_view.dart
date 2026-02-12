import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/leaderboard_entry.dart';
import '../services/service_locator.dart';
import '../theme/app_theme.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  List<LeaderboardEntry>? _entries;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final entries = await ServiceLocator.instance.leaderboardRepository.getLeaderboard();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLeaderboard,
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(
            children: [
              const Icon(Icons.leaderboard_rounded, color: AppColors.deepPurple, size: 28),
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
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _entries!.length,
            itemBuilder: (context, index) {
              final entry = _entries![index];
              return _LeaderboardTile(entry: entry);
            },
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;

  const _LeaderboardTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;
    final medal = switch (entry.rank) {
      1 => '\u{1F947}',
      2 => '\u{1F948}',
      3 => '\u{1F949}',
      _ => null,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: isTop3 ? 2 : 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isTop3
              ? AppColors.gold.withValues(alpha: 0.15)
              : AppColors.deepPurple.withValues(alpha: 0.08),
          child: medal != null
              ? Text(medal, style: const TextStyle(fontSize: 20))
              : Text(
                  '${entry.rank}',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepPurple,
                  ),
                ),
        ),
        title: Text(
          entry.username,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isTop3 ? AppColors.deepPurple : Colors.black87,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('\u{1FA99}', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              '${entry.totalCoins}',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import '../theme/app_theme.dart';
import '../widgets/animal_thumbnail.dart';
import '../widgets/coin_badge.dart';
import 'quiz_screen.dart';

class LevelDetailScreen extends StatefulWidget {
  final Level level;
  final GameState gameState;

  const LevelDetailScreen({
    super.key,
    required this.level,
    required this.gameState,
  });

  @override
  State<LevelDetailScreen> createState() => _LevelDetailScreenState();
}

class _LevelDetailScreenState extends State<LevelDetailScreen> {
  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(
        backgroundColor: AppColors.deepPurple,
        foregroundColor: Colors.white,
        title: Text(
          widget.level.displayTitle,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CoinBadge(coins: widget.gameState.totalCoins, light: true),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: widget.level.animals.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.9,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final animal = widget.level.animals[index];
            final guessed = widget.gameState.isAnimalGuessed(widget.level.id, index);
            return AnimalThumbnail(
              animal: animal,
              index: index,
              guessed: guessed,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      level: widget.level,
                      animalIndex: index,
                      gameState: widget.gameState,
                    ),
                  ),
                );
                setState(() {});
              },
            );
          },
        ),
      ),
    );
  }
}

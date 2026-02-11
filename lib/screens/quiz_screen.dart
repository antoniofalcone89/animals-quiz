import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import '../theme/app_theme.dart';
import '../widgets/answer_button.dart';
import '../widgets/coin_badge.dart';

class QuizScreen extends StatefulWidget {
  final Level level;
  final int animalIndex;
  final GameState gameState;

  const QuizScreen({
    super.key,
    required this.level,
    required this.animalIndex,
    required this.gameState,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late int _currentIndex;
  late List<int> _questionOrder;
  int _sessionCoins = 0;
  int _sessionCorrect = 0;
  bool _answered = false;
  int? _selectedIndex;
  late List<String> _options;
  late int _correctOptionIndex;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _questionOrder = List.generate(widget.level.animals.length, (i) => i);
    // Start from the tapped animal, then continue through the rest
    final startIdx = _questionOrder.indexOf(widget.animalIndex);
    _questionOrder = [
      ..._questionOrder.sublist(startIdx),
      ..._questionOrder.sublist(0, startIdx),
    ];
    _currentIndex = 0;
    _generateOptions();
  }

  void _generateOptions() {
    final rng = Random();
    final animal = widget.level.animals[_questionOrder[_currentIndex]];
    final otherNames = widget.level.animals
        .where((a) => a.name != animal.name)
        .map((a) => a.name)
        .toList()
      ..shuffle(rng);

    final options = [animal.name, otherNames[0], otherNames[1]]..shuffle(rng);
    _options = options;
    _correctOptionIndex = options.indexOf(animal.name);
  }

  void _onAnswer(int index) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedIndex = index;
      if (index == _correctOptionIndex) {
        _sessionCoins += 10;
        _sessionCorrect++;
        widget.gameState.addCoins(10);
        widget.gameState.markAnimalCorrect(
          widget.level.id,
          _questionOrder[_currentIndex],
        );
      }
    });
  }

  void _next() {
    if (_currentIndex + 1 >= _questionOrder.length) {
      setState(() => _showResults = true);
      return;
    }
    setState(() {
      _currentIndex++;
      _answered = false;
      _selectedIndex = null;
      _generateOptions();
    });
  }

  AnswerState _getState(int index) {
    if (!_answered) return AnswerState.idle;
    if (index == _correctOptionIndex) return AnswerState.correct;
    if (index == _selectedIndex) return AnswerState.wrong;
    return AnswerState.idle;
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) return _buildResults();

    final animal = widget.level.animals[_questionOrder[_currentIndex]];
    final isCorrect = _answered && _selectedIndex == _correctOptionIndex;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Question ${_currentIndex + 1} of ${_questionOrder.length}',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CoinBadge(coins: widget.gameState.totalCoins, light: true),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Animal image / emoji container
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.deepPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.deepPurple.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(animal.emoji, style: const TextStyle(fontSize: 80)),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'What is the name of this animal?',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Answer options
            ...List.generate(_options.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnswerButton(
                  text: _options[i],
                  state: _getState(i),
                  onTap: _answered ? null : () => _onAnswer(i),
                ),
              );
            }),
            // Feedback text
            if (_answered) ...[
              const SizedBox(height: 8),
              AnimatedOpacity(
                opacity: _answered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? AppColors.correctGreen.withValues(alpha: 0.1)
                        : AppColors.wrongRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isCorrect
                        ? "That's the right answer! +10 Coins \u{1F389}"
                        : 'Oops! The correct answer is ${animal.name}',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isCorrect ? AppColors.correctGreen : AppColors.wrongRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'NEXT \u{2192}',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.purpleGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('\u{1F389}', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 24),
              Text(
                'Quiz Complete!',
                style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Score',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_sessionCorrect / ${_questionOrder.length}',
                      style: GoogleFonts.nunito(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('\u{1FA99}', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          '+$_sessionCoins Coins Earned',
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'BACK TO LEVEL',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepPurple,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

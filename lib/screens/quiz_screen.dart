import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import '../theme/app_theme.dart';
import '../widgets/animal_emoji_card.dart';
import '../widgets/coin_badge.dart';
import '../widgets/quiz_feedback.dart';
import '../widgets/quiz_hint_section.dart';
import '../widgets/quiz_input_section.dart';
import '../widgets/quiz_results.dart';

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
  bool _showWrongMessage = false;
  bool _showResults = false;
  bool _hasText = false;
  String? _revealedName;
  String? _currentFunFact;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

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
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _controller.text;
    final hasText = text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
    // Auto-submit when typed letter count matches the animal name letter count
    final animal = widget.level.animals[_currentAnimalIndex];
    final letterCount = animal.name.replaceAll(' ', '').length;
    if (text.length >= letterCount &&
        hasText &&
        !_answered &&
        !_showWrongMessage &&
        !_isCurrentAnimalGuessed()) {
      _onSubmit();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int get _currentAnimalIndex => _questionOrder[_currentIndex];

  int get _hintsRevealed => widget.gameState.getHintsRevealed(
        widget.level.id,
        _currentAnimalIndex,
      );

  bool _isCurrentAnimalGuessed() {
    return widget.gameState.isAnimalGuessed(
      widget.level.id,
      _currentAnimalIndex,
    );
  }

  Future<void> _useHint() async {
    final hintsRevealed = _hintsRevealed;
    final animal = widget.level.animals[_currentAnimalIndex];
    if (hintsRevealed >= animal.hints.length) return;

    final cost = GameState.hintCosts[hintsRevealed];
    if (widget.gameState.totalCoins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('not_enough_coins'.tr()),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await widget.gameState.buyHint(
      widget.level.id,
      _currentAnimalIndex,
    );
    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('not_enough_coins'.tr()),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {});
    }
  }

  String _insertSpaces(String typed, String name) {
    final buffer = StringBuffer();
    int typedIdx = 0;
    for (int i = 0; i < name.length && typedIdx < typed.length; i++) {
      if (name[i] == ' ') {
        buffer.write(' ');
      } else {
        buffer.write(typed[typedIdx]);
        typedIdx++;
      }
    }
    return buffer.toString();
  }

  Future<void> _onSubmit() async {
    final typed = _controller.text.trim();
    if (typed.isEmpty || _answered || _showWrongMessage) return;

    final animal = widget.level.animals[_currentAnimalIndex];
    final guess = _insertSpaces(typed, animal.name);

    final result = await widget.gameState.submitAnswer(
      widget.level.id,
      _currentAnimalIndex,
      guess,
    );

    if (result.correct) {
      final animal = widget.level.animals[_currentAnimalIndex];
      String? funFact;
      if (animal.funFacts.isNotEmpty) {
        funFact = animal.funFacts[Random().nextInt(animal.funFacts.length)];
      }
      setState(() {
        _answered = true;
        _revealedName = result.correctAnswer ?? animal.name;
        _sessionCoins += result.coinsAwarded;
        _sessionCorrect++;
        _currentFunFact = funFact;
      });
    } else {
      setState(() => _showWrongMessage = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        _controller.clear();
        _focusNode.requestFocus();
        setState(() => _showWrongMessage = false);
      });
    }
  }

  void _next() {
    if (_currentIndex + 1 >= _questionOrder.length) {
      setState(() => _showResults = true);
      return;
    }
    _controller.clear();
    setState(() {
      _currentIndex++;
      _answered = false;
      _showWrongMessage = false;
      _revealedName = null;
      _currentFunFact = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      return QuizResults(
        correctCount: _sessionCorrect,
        totalQuestions: _questionOrder.length,
        coinsEarned: _sessionCoins,
        onBackToLevel: () => Navigator.of(context).pop(),
      );
    }

    final animal = widget.level.animals[_currentAnimalIndex];
    final alreadyGuessed = _isCurrentAnimalGuessed() && !_answered;
    final hintsRevealed = _hintsRevealed;

    final int? nextHintCost = hintsRevealed < animal.hints.length
        ? GameState.hintCosts[hintsRevealed]
        : null;

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
          'question_of'.tr(args: [(_currentIndex + 1).toString(), _questionOrder.length.toString()]),
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
            AnimalEmojiCard(emoji: animal.emoji ?? '\u{2753}', imageUrl: animal.imageUrl),
            const SizedBox(height: 28),
            Text(
              'what_animal'.tr(),
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            if (!alreadyGuessed && !_answered && animal.hints.isNotEmpty)
              QuizHintSection(
                hints: animal.hints,
                hintsRevealed: hintsRevealed,
                nextHintCost: nextHintCost,
                canAfford: nextHintCost != null &&
                    widget.gameState.totalCoins >= nextHintCost,
                onRequestHint: _useHint,
                enabled: !_answered && !alreadyGuessed,
              ),
            const SizedBox(height: 16),
            QuizInputSection(
              animalName: animal.name,
              revealedName: alreadyGuessed ? animal.name : _revealedName,
              alreadyGuessed: alreadyGuessed,
              controller: _controller,
              focusNode: _focusNode,
              enabled: !_answered && !alreadyGuessed && !_showWrongMessage,
              questionIndex: _currentIndex,
              showError: _showWrongMessage,
              onSubmit: _onSubmit,
            ),
            if (!alreadyGuessed)
              QuizFeedback(
                showWrongMessage: _showWrongMessage,
                answered: _answered,
                onNext: _next,
                funFact: _currentFunFact,
              ),
            if (alreadyGuessed) ...[
              const SizedBox(height: 24),
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
                    'next'.tr(),
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
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/animal.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import '../theme/app_theme.dart';
import '../widgets/animal_emoji_card.dart';
import '../widgets/coin_badge.dart';
import '../widgets/quiz_feedback.dart';
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
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final guess = _controller.text.trim();
    if (guess.isEmpty || _answered || _showWrongMessage) return;

    final result = await widget.gameState.submitAnswer(
      widget.level.id,
      _questionOrder[_currentIndex],
      guess,
    );

    if (result.correct) {
      setState(() {
        _answered = true;
        _sessionCoins += result.coinsAwarded;
        _sessionCorrect++;
      });
    } else {
      setState(() => _showWrongMessage = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        _controller.clear();
        setState(() => _showWrongMessage = false);
        _focusNode.requestFocus();
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
    });
  }

  String _animalDisplayName(Animal animal) {
    final translated = animal.translationKey.tr();
    return translated == animal.translationKey ? animal.name : translated;
  }

  String _buildHint(String name) {
    return name.split('').map((_) => '_').join(' ');
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

    final animal = widget.level.animals[_questionOrder[_currentIndex]];

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
            AnimalEmojiCard(emoji: animal.emoji ?? '\u{2753}'),
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
            const SizedBox(height: 16),
            QuizInputSection(
              hint: _buildHint(_animalDisplayName(animal)),
              controller: _controller,
              focusNode: _focusNode,
              enabled: !_answered,
              questionIndex: _currentIndex,
              canSubmit: _hasText && !_answered && !_showWrongMessage,
              onSubmit: _onSubmit,
            ),
            QuizFeedback(
              showWrongMessage: _showWrongMessage,
              answered: _answered,
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }
}

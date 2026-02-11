import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import '../theme/app_theme.dart';
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

  void _onSubmit() {
    final guess = _controller.text.trim();
    if (guess.isEmpty || _answered || _showWrongMessage) return;
    final animal = widget.level.animals[_questionOrder[_currentIndex]];
    final correct = guess.toLowerCase() == animal.name.toLowerCase();
    if (correct) {
      setState(() {
        _answered = true;
        _sessionCoins += 10;
        _sessionCorrect++;
      });
      widget.gameState.addCoins(10);
      widget.gameState.markAnimalCorrect(
        widget.level.id,
        _questionOrder[_currentIndex],
      );
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

  String _buildHint(String name) {
    return name.split('').map((_) => '_').join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) return _buildResults();

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
            const SizedBox(height: 16),
            // Hint: underscores matching name length
            Text(
              _buildHint(animal.name),
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Text input
            TextField(
              key: ValueKey('quiz_input_$_currentIndex'),
              controller: _controller,
              focusNode: _focusNode,
              enabled: !_answered,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Type your answer...',
                hintStyle: GoogleFonts.nunito(fontSize: 18, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.deepPurple.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.deepPurple,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: (_) => _onSubmit(),
            ),
            const SizedBox(height: 16),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _hasText && !_answered && !_showWrongMessage
                    ? _onSubmit
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepPurple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.deepPurple.withValues(
                    alpha: 0.4,
                  ),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'SUBMIT',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            // Wrong answer feedback (temporary)
            if (_showWrongMessage)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.wrongRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "That's not right. Try again!",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.wrongRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Correct answer feedback + NEXT button
            if (_answered) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.correctGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "That's the right answer! +10 Coins \u{1F389}",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.correctGreen,
                  ),
                  textAlign: TextAlign.center,
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

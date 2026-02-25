import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import '../services/admob_service.dart';
import '../utils/string_similarity.dart';
import '../services/tutorial_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animal_emoji_card.dart';
import '../widgets/coin_badge.dart';
import '../widgets/quiz_feedback.dart';
import '../widgets/quiz_hint_section.dart'
    show HintButton, LetterRevealButton, RevealAnimalButton, RevealedHints;
import '../widgets/quiz_input_section.dart';
import '../widgets/quiz_results.dart';
import '../widgets/tutorial/tutorial_overlay.dart';
import '../widgets/tutorial/tutorial_step.dart';

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
  bool _hintsSheetOpen = false;
  String? _revealedName;
  String? _currentFunFact;
  RewardedAd? _rewardedAd;
  bool _isLoadingRewardedAd = false;
  bool _isShowingRewardedAd = false;
  bool _showTutorial = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // GlobalKeys for tutorial spotlight targets
  final GlobalKey _inputSectionKey = GlobalKey();
  final GlobalKey _hintButtonKey = GlobalKey();
  final GlobalKey _letterRevealKey = GlobalKey();
  final GlobalKey _revealAnimalKey = GlobalKey();
  final GlobalKey _coinBadgeKey = GlobalKey();

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
    _loadRewardedAd();
    _checkTutorial();
  }

  void _checkTutorial() {
    // Only show for the first level
    if (widget.level.id != 1) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final seen = await TutorialService.hasSeenTutorial();
      if (!seen && mounted) {
        setState(() => _showTutorial = true);
      }
    });
  }

  void _onTutorialComplete() {
    TutorialService.markTutorialSeen();
    setState(() => _showTutorial = false);
  }

  List<TutorialStep> _buildTutorialSteps() {
    return [
      TutorialStep(
        title: 'tutorial_welcome_title'.tr(),
        body: 'tutorial_welcome_body'.tr(),
        spotlightShape: SpotlightShape.none,
        icon: Icons.waving_hand_rounded,
      ),
      TutorialStep(
        targetKey: _inputSectionKey,
        title: 'tutorial_input_title'.tr(),
        body: 'tutorial_input_body'.tr(),
        icon: Icons.keyboard_rounded,
        spotlightPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      ),
      TutorialStep(
        targetKey: _hintButtonKey,
        title: 'tutorial_hint_title'.tr(),
        body: 'tutorial_hint_body'.tr(),
        icon: Icons.lightbulb_outline,
        spotlightPadding: const EdgeInsets.all(6),
      ),
      TutorialStep(
        targetKey: _letterRevealKey,
        title: 'tutorial_letter_title'.tr(),
        body: 'tutorial_letter_body'.tr(),
        icon: Icons.abc_rounded,
        spotlightPadding: const EdgeInsets.all(6),
      ),
      TutorialStep(
        targetKey: _revealAnimalKey,
        title: 'tutorial_reveal_title'.tr(),
        body: 'tutorial_reveal_body'.tr(),
        icon: Icons.help_outline_rounded,
        spotlightPadding: const EdgeInsets.all(6),
      ),
      TutorialStep(
        targetKey: _coinBadgeKey,
        title: 'tutorial_coins_title'.tr(),
        body: 'tutorial_coins_body'.tr(),
        spotlightShape: SpotlightShape.roundedRect,
        icon: Icons.monetization_on_outlined,
        spotlightPadding: const EdgeInsets.all(6),
      ),
      TutorialStep(
        title: 'tutorial_leaderboard_title'.tr(),
        body: 'tutorial_leaderboard_body'.tr(),
        spotlightShape: SpotlightShape.none,
        icon: Icons.leaderboard_rounded,
      ),
    ];
  }

  void _onTextChanged() {
    final text = _controller.text;
    final hasText = text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadRewardedAd() {
    if (!AdMobService.isSupportedPlatform) return;
    if (_rewardedAd != null || _isLoadingRewardedAd) return;

    _isLoadingRewardedAd = true;
    RewardedAd.load(
      adUnitId: AdMobService.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoadingRewardedAd = false;
        },
        onAdFailedToLoad: (_) {
          _rewardedAd = null;
          _isLoadingRewardedAd = false;
        },
      ),
    );
  }

  Future<void> _showRewardedAd(String animalName) async {
    if (!AdMobService.isSupportedPlatform) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ad_not_available'.tr())));
      }
      return;
    }

    final ad = _rewardedAd;
    if (ad == null || _isShowingRewardedAd) {
      _loadRewardedAd();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ad_not_ready'.tr())));
      }
      return;
    }

    _isShowingRewardedAd = true;
    var rewardEarned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isShowingRewardedAd = false;
        _loadRewardedAd();
        if (!rewardEarned && mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('ad_reward_not_earned'.tr())));
        }
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewardedAd = null;
        _isShowingRewardedAd = false;
        _loadRewardedAd();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('ad_not_available'.tr())));
        }
      },
    );

    ad.show(
      onUserEarnedReward: (_, __) {
        rewardEarned = true;
        _revealAnimal(animalName);
      },
    );
  }

  int get _currentAnimalIndex => _questionOrder[_currentIndex];

  int get _hintsRevealed =>
      widget.gameState.getHintsRevealed(widget.level.id, _currentAnimalIndex);

  bool _isCurrentAnimalGuessed() {
    return widget.gameState.isAnimalGuessed(
      widget.level.id,
      _currentAnimalIndex,
    );
  }

  int get _lettersRevealed =>
      widget.gameState.getLettersRevealed(widget.level.id, _currentAnimalIndex);

  void _showHintsSheet(List<String> hints, int hintsRevealed) {
    if (hintsRevealed <= 0) return;
    setState(() => _hintsSheetOpen = true);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'hints'.tr(),
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            RevealedHints(hints: hints, hintsRevealed: hintsRevealed),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _hintsSheetOpen = false);
    });
  }

  Future<void> _useLetterReveal() async {
    if (_lettersRevealed >= GameState.maxLetterReveals) return;

    if (widget.gameState.totalCoins < GameState.letterRevealCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('not_enough_coins'.tr()),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await widget.gameState.buyLetterReveal(
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
      final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 100;
      if (keyboardVisible) {
        _showHintsSheet(animal.hints, result.hintsRevealed);
      }
    }
  }

  Future<void> _showRevealAdDialog() async {
    final animal = widget.level.animals[_currentAnimalIndex];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.help_outline_rounded,
              color: AppColors.correctGreen,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'reveal_animal_title'.tr(),
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.deepPurple,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'reveal_animal_description'.tr(),
          style: GoogleFonts.nunito(fontSize: 15, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'cancel'.tr(),
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
            label: Text(
              'watch_ad'.tr(),
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.correctGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await _showRewardedAd(animal.name);
  }

  void _revealAnimal(String animalName) {
    widget.gameState
        .submitAnswer(
          widget.level.id,
          _currentAnimalIndex,
          animalName,
          adRevealed: true,
        )
        .then((result) {
          if (!mounted) return;
          String? funFact;
          final animal = widget.level.animals[_currentAnimalIndex];
          if (animal.funFacts.isNotEmpty) {
            funFact = animal.funFacts[Random().nextInt(animal.funFacts.length)];
          }
          _focusNode.unfocus();
          setState(() {
            _answered = true;
            _revealedName = result.correctAnswer ?? animalName;
            _sessionCoins += result.coinsAwarded;
            _sessionCorrect++;
            _currentFunFact = funFact;
          });
        });
  }

  String _insertSpaces(String typed, String name, List<int> revealedPositions) {
    final buffer = StringBuffer();
    int typedIdx = 0;
    for (int i = 0; i < name.length; i++) {
      if (name[i] == ' ') {
        buffer.write(' ');
      } else if (revealedPositions.contains(i)) {
        buffer.write(name[i]);
      } else if (typedIdx < typed.length) {
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
    final revealedPos = widget.gameState.getRevealedPositions(
      widget.level.id,
      _currentAnimalIndex,
      animal.name,
    );
    final guess = _insertSpaces(typed, animal.name, revealedPos);

    // Check correctness locally for instant feedback — no network wait.
    final isCorrect = isFuzzyMatch(guess, animal.name);

    if (isCorrect) {
      String? funFact;
      if (animal.funFacts.isNotEmpty) {
        funFact = animal.funFacts[Random().nextInt(animal.funFacts.length)];
      }
      _focusNode.unfocus();
      setState(() {
        _answered = true;
        _revealedName = animal.name;
        _sessionCorrect++;
        _currentFunFact = funFact;
      });

      // Persist to backend in the background; update coins when it responds.
      // On network failure we swallow silently — progress will appear unguessed
      // on next load, which is acceptable vs. delaying feedback every time.
      widget.gameState
          .submitAnswer(widget.level.id, _currentAnimalIndex, guess)
          .then((result) {
            if (!mounted) return;
            setState(() => _sessionCoins += result.coinsAwarded);
          })
          .catchError((_) {});
    } else {
      setState(() => _showWrongMessage = true);
      Future.delayed(const Duration(milliseconds: 1400), () {
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

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    // Once answered, ignore keyboard inset so the panel doesn't resize as the keyboard animates away
    final effectiveBottomInset = _answered ? 0.0 : bottomInset;
    final keyboardVisible = effectiveBottomInset > 100;

    final animal = widget.level.animals[_currentAnimalIndex];
    final alreadyGuessed = _isCurrentAnimalGuessed() && !_answered;
    final hintsRevealed = _hintsRevealed;
    final lettersRevealed = _lettersRevealed;
    final revealedPositions = widget.gameState.getRevealedPositions(
      widget.level.id,
      _currentAnimalIndex,
      animal.name,
    );
    final int? nextHintCost = hintsRevealed < animal.hints.length
        ? GameState.hintCosts[hintsRevealed]
        : null;
    final progress = (_currentIndex + 1) / _questionOrder.length;

    final scaffold = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.deepPurple,
      appBar: AppBar(
        backgroundColor: AppColors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'question_of'.tr(
            args: [
              (_currentAnimalIndex + 1).toString(),
              _questionOrder.length.toString(),
            ],
          ),
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CoinBadge(key: _coinBadgeKey, coins: widget.gameState.totalCoins, light: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 4,
          ),

          // Image zone — fills purple background
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_focusNode.hasFocus) {
                  _focusNode.unfocus();
                }
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: AnimalEmojiCard(
                      key: ValueKey(_currentIndex),
                      emoji: animal.emoji ?? '\u{2753}',
                      imageUrl: animal.imageUrl,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom panel — white sheet pinned above keyboard
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "View hints" chip when keyboard is visible and hints are bought
                      if (hintsRevealed > 0 &&
                          !_answered &&
                          !alreadyGuessed &&
                          keyboardVisible)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () =>
                                _showHintsSheet(animal.hints, hintsRevealed),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.deepPurple.withValues(
                                  alpha: 0.07,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.deepPurple.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline,
                                    size: 15,
                                    color: AppColors.deepPurple,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'hints'.tr(),
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.deepPurple,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: AppColors.deepPurple,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$hintsRevealed',
                                        style: GoogleFonts.nunito(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 15,
                                    color: AppColors.deepPurple,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Inline revealed hints — only when keyboard is hidden and sheet is not open
                      if (hintsRevealed > 0 &&
                          !_answered &&
                          !alreadyGuessed &&
                          !keyboardVisible &&
                          !_hintsSheetOpen)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: RevealedHints(
                            hints: animal.hints,
                            hintsRevealed: hintsRevealed,
                          ),
                        ),

                      // Input
                      QuizInputSection(
                        key: _inputSectionKey,
                        animalName: animal.name,
                        revealedName: alreadyGuessed
                            ? animal.name
                            : _revealedName,
                        alreadyGuessed: alreadyGuessed,
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled:
                            !_answered && !alreadyGuessed && !_showWrongMessage,
                        questionIndex: _currentIndex,
                        showError: _showWrongMessage,
                        onSubmit: _onSubmit,
                        revealedPositions: revealedPositions,
                      ),

                      const SizedBox(height: 12),

                      // Hint buttons row — visible above keyboard
                      if (!alreadyGuessed && !_answered)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (animal.hints.isNotEmpty)
                                HintButton(
                                  key: _hintButtonKey,
                                  hintsRevealed: hintsRevealed,
                                  totalHints: animal.hints.length,
                                  nextHintCost: nextHintCost,
                                  canAfford:
                                      nextHintCost != null &&
                                      widget.gameState.totalCoins >=
                                          nextHintCost,
                                  onRequestHint: _useHint,
                                  enabled: !_answered && !alreadyGuessed,
                                ),
                              LetterRevealButton(
                                key: _letterRevealKey,
                                lettersRevealed: lettersRevealed,
                                maxReveals: GameState.maxLetterReveals,
                                cost: GameState.letterRevealCost,
                                canAfford:
                                    widget.gameState.totalCoins >=
                                    GameState.letterRevealCost,
                                onReveal: _useLetterReveal,
                                enabled: !_answered && !alreadyGuessed,
                              ),
                              RevealAnimalButton(
                                key: _revealAnimalKey,
                                onReveal: _showRevealAdDialog,
                                enabled: !_answered && !alreadyGuessed,
                              ),
                            ],
                          ),
                        ),

                      // Correct / wrong feedback
                      if (!alreadyGuessed)
                        QuizFeedback(
                          showWrongMessage: _showWrongMessage,
                          answered: _answered,
                          onNext: _next,
                          funFact: _currentFunFact,
                        ),

                      // Already guessed — next button
                      if (alreadyGuessed) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
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

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        height: max(effectiveBottomInset, safeBottom) + 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!_showTutorial) return scaffold;

    return Stack(
      children: [
        scaffold,
        TutorialOverlay(
          steps: _buildTutorialSteps(),
          onComplete: _onTutorialComplete,
        ),
      ],
    );
  }
}

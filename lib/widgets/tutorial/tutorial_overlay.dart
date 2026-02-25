import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import 'spotlight_painter.dart';
import 'tutorial_step.dart';

class TutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onComplete;

  const TutorialOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 0;

  late final AnimationController _entryController;
  late final Animation<double> _entryAnimation;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  late final AnimationController _stepController;
  late final Animation<double> _stepAnimation;

  late final AnimationController _typeController;

  Rect? _fromRect;
  Rect? _toRect;
  double _fromBorderRadius = 12;
  double _toBorderRadius = 12;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entryAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    _pulseController.repeat(reverse: true);

    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _stepAnimation = CurvedAnimation(
      parent: _stepController,
      curve: Curves.easeInOutCubic,
    );

    _typeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _toRect = _getTargetRect(_currentStep);
    _toBorderRadius = _getBorderRadius(_currentStep);
    _fromRect = _toRect;
    _fromBorderRadius = _toBorderRadius;

    _entryController.forward();
    _typeController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _stepController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Rect? _getTargetRect(int stepIndex) {
    if (stepIndex >= widget.steps.length) return null;
    final step = widget.steps[stepIndex];
    if (step.targetKey == null || step.spotlightShape == SpotlightShape.none) {
      return null;
    }
    final renderObj = step.targetKey!.currentContext?.findRenderObject();
    if (renderObj is! RenderBox || !renderObj.hasSize) return null;
    final position = renderObj.localToGlobal(Offset.zero);
    final size = renderObj.size;
    return step.spotlightPadding.inflateRect(
      Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
    );
  }

  double _getBorderRadius(int stepIndex) {
    if (stepIndex >= widget.steps.length) return 12;
    final step = widget.steps[stepIndex];
    if (step.spotlightShape == SpotlightShape.circle) return 999;
    return 12;
  }

  void _goToStep(int step) {
    if (step >= widget.steps.length) {
      widget.onComplete();
      return;
    }

    _fromRect = _currentSpotlightRect;
    _fromBorderRadius = _currentBorderRadius;

    setState(() {
      _currentStep = step;
      _toRect = _getTargetRect(step);
      _toBorderRadius = _getBorderRadius(step);
    });

    _stepController.forward(from: 0);
    _typeController.forward(from: 0);
  }

  Rect? get _currentSpotlightRect {
    if (_fromRect == null && _toRect == null) return null;
    if (_fromRect == null) return _toRect;
    if (_toRect == null) {
      final t = _stepAnimation.value;
      return Rect.lerp(
        _fromRect,
        Rect.fromCenter(center: _fromRect!.center, width: 0, height: 0),
        t,
      );
    }
    return Rect.lerp(_fromRect, _toRect, _stepAnimation.value);
  }

  double get _currentBorderRadius {
    return _fromBorderRadius +
        (_toBorderRadius - _fromBorderRadius) * _stepAnimation.value;
  }

  void _next() => _goToStep(_currentStep + 1);
  void _skip() => widget.onComplete();

  Widget _buildStepDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.steps.length, (i) {
        final isActive = i == _currentStep;
        final isPast = i < _currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isActive ? 18 : 6,
          height: 6,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isActive
                ? AppColors.deepPurple
                : isPast
                    ? AppColors.deepPurple.withValues(alpha: 0.4)
                    : Colors.grey.withValues(alpha: 0.25),
          ),
        );
      }),
    );
  }

  Widget _buildStepDotsLight() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.steps.length, (i) {
        final isActive = i == _currentStep;
        final isPast = i < _currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isActive ? 18 : 6,
          height: 6,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isActive
                ? Colors.white
                : isPast
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.25),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];
    final isFullscreen = step.spotlightShape == SpotlightShape.none;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _entryAnimation,
        _pulseAnimation,
        _stepAnimation,
        _typeController,
      ]),
      builder: (context, _) {
        final spotlightRect = _currentSpotlightRect;
        final borderRadius = _currentBorderRadius;
        final entryValue = _entryAnimation.value;
        final pulseValue = _pulseAnimation.value;

        return DefaultTextStyle(
          style: const TextStyle(decoration: TextDecoration.none),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _next,
            child: Stack(
              children: [
                // Spotlight overlay
                Opacity(
                  opacity: entryValue,
                  child: CustomPaint(
                    size: MediaQuery.sizeOf(context),
                    painter: SpotlightPainter(
                      spotlightRect: spotlightRect,
                      borderRadius: borderRadius,
                      overlayOpacity: 0.82,
                      pulseValue: spotlightRect != null ? pulseValue : 0,
                      glowColor: AppColors.lightPurple,
                    ),
                  ),
                ),

                // Callout card
                if (isFullscreen)
                  _buildFullscreenCard(step, entryValue)
                else
                  _buildPositionedCallout(step, spotlightRect, entryValue),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFullscreenCard(TutorialStep step, double entryValue) {
    final typeProgress = _typeController.value;
    final bodyText = step.body;
    final visibleChars = (bodyText.length * typeProgress).floor();
    final displayedBody = bodyText.substring(0, visibleChars);

    final slideOffset = (1 - _stepAnimation.value.clamp(0.0, 1.0)) * 30;
    final cardOpacity =
        (_currentStep == 0 ? entryValue : _stepAnimation.value)
            .clamp(0.0, 1.0);

    return Center(
      child: Transform.translate(
        offset: Offset(0, slideOffset),
        child: Opacity(
          opacity: cardOpacity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7B42F6), Color(0xFF5A2DB5)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepPurple.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (step.icon != null)
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(step.icon, color: Colors.white, size: 32),
                    ),
                  if (step.icon != null) const SizedBox(height: 20),

                  Text(
                    step.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    displayedBody,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Step dots + Next button
                  Row(
                    children: [
                      _buildStepDotsLight(),
                      const Spacer(),
                      _buildNextButton(),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Skip
                  GestureDetector(
                    onTap: _skip,
                    child: Text(
                      'tutorial_skip'.tr(),
                      style: GoogleFonts.nunito(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionedCallout(
    TutorialStep step,
    Rect? spotlightRect,
    double entryValue,
  ) {
    if (spotlightRect == null) return const SizedBox.shrink();

    final screenSize = MediaQuery.sizeOf(context);
    final safeTop = MediaQuery.paddingOf(context).top;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    final spotlightCenterY = spotlightRect.center.dy;
    final showBelow = spotlightCenterY < screenSize.height * 0.5;

    final typeProgress = _typeController.value;
    final bodyText = step.body;
    final visibleChars = (bodyText.length * typeProgress).floor();
    final displayedBody = bodyText.substring(0, visibleChars);

    final slideOffset = (1 - _stepAnimation.value.clamp(0.0, 1.0)) * 20;
    final cardOpacity = _stepAnimation.value.clamp(0.0, 1.0);

    final double topPosition;
    final double bottomPosition;

    if (showBelow) {
      topPosition = spotlightRect.bottom + 16;
      bottomPosition = safeBottom + 80;
    } else {
      topPosition = safeTop + 52;
      bottomPosition = screenSize.height - spotlightRect.top + 16;
    }

    return Positioned(
      left: 20,
      right: 20,
      top: showBelow ? topPosition : null,
      bottom: showBelow ? null : bottomPosition,
      child: Transform.translate(
        offset: Offset(0, showBelow ? slideOffset : -slideOffset),
        child: Opacity(
          opacity: cardOpacity * entryValue,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppColors.deepPurple.withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with icon
                Row(
                  children: [
                    if (step.icon != null) ...[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.deepPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          step.icon,
                          color: AppColors.deepPurple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        step.title,
                        style: GoogleFonts.nunito(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Body
                Text(
                  displayedBody,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Step dots + skip + next
                Row(
                  children: [
                    _buildStepDots(),
                    const Spacer(),
                    GestureDetector(
                      onTap: _skip,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          'tutorial_skip'.tr(),
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _buildNextButton(compact: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton({bool compact = false}) {
    final isLast = _currentStep == widget.steps.length - 1;
    final label = isLast ? 'tutorial_done'.tr() : 'tutorial_next'.tr();

    return GestureDetector(
      onTap: _next,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 24,
          vertical: compact ? 8 : 12,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B42F6), Color(0xFF6C3FC5)],
          ),
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepPurple.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: compact ? 13 : 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (!isLast) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: compact ? 16 : 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

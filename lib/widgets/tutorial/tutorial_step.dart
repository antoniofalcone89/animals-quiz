import 'package:flutter/material.dart';

enum SpotlightShape { none, roundedRect, circle }

class TutorialStep {
  final GlobalKey? targetKey;
  final String title;
  final String body;
  final SpotlightShape spotlightShape;
  final EdgeInsets spotlightPadding;
  final IconData? icon;

  const TutorialStep({
    this.targetKey,
    required this.title,
    required this.body,
    this.spotlightShape = SpotlightShape.roundedRect,
    this.spotlightPadding = const EdgeInsets.all(8),
    this.icon,
  });
}

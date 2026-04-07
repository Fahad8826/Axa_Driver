import 'package:flutter/material.dart';

/// Central responsive layout helper.
///
/// Usage (top of every page's build method):
/// ```dart
/// final layout = AppLayout.of(context);
/// ```
/// Then use `layout.hPad`, `layout.cardRadius`, etc.
class AppLayout {
  AppLayout._({required this.screenWidth, required this.screenHeight});

  factory AppLayout.of(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AppLayout._(screenWidth: size.width, screenHeight: size.height);
  }

  final double screenWidth;
  final double screenHeight;

  // ── Page-level spacing ────────────────────────────────────────────────────
  /// Horizontal page padding — 5 % of screen width (same as profile page).
  double get hPad => screenWidth * 0.05;

  /// Vertical page padding — 2.2 % of screen height (same as profile page).
  double get vPad => screenHeight * 0.022;

  /// Convenient EdgeInsets for page-level scroll padding.
  EdgeInsets get pagePadding =>
      EdgeInsets.symmetric(horizontal: hPad, vertical: vPad);

  // ── Section spacing ───────────────────────────────────────────────────────
  /// Gap between sections (e.g. between cards).
  double get sectionGap => screenHeight * 0.018;

  /// Small vertical gap inside cards.
  double get innerGapSm => screenHeight * 0.010;

  /// Medium vertical gap inside cards.
  double get innerGapMd => screenHeight * 0.016;

  // ── Typography scaling ────────────────────────────────────────────────────
  /// Title / heading font size (~20 sp on a 844-pt screen).
  double get titleFontSize => screenHeight * 0.024;

  /// Body font size (~13 sp).
  double get bodyFontSize => screenHeight * 0.016;

  /// Small label font size (~11 sp).
  double get labelFontSize => screenHeight * 0.013;

  // ── Summary card specifics ────────────────────────────────────────────────
  /// Number value inside a stat pill (~22 sp).
  double get statValueFontSize => screenHeight * 0.026;

  /// Label text below stat value (~11 sp).
  double get statLabelFontSize => screenHeight * 0.013;

  /// Horizontal padding inside a stat pill.
  double get statPillHPad => screenWidth * 0.045;

  /// Vertical padding inside a stat pill.
  double get statPillVPad => screenHeight * 0.010;

  // ── Decorative circle in summary card ─────────────────────────────────────
  double get decorCircleSize => screenWidth * 0.40;

  // ── Card & button heights ─────────────────────────────────────────────────
  /// Standard small button height.
  double get buttonHeightSm => screenHeight * 0.046;

  /// Avatar / product image size for the current-delivery card.
  double get productImageLg => screenWidth * 0.18;

  /// Avatar / product image size for next-delivery cards.
  double get productImageSm => screenWidth * 0.16;

  // ── Icon sizes ────────────────────────────────────────────────────────────
  double get iconSm => screenWidth * 0.04;
}

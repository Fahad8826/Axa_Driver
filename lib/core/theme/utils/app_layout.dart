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
double get hPad => screenWidth * 0.04;
double get vPad => screenHeight * 0.016;
EdgeInsets get pagePadding =>
    EdgeInsets.symmetric(horizontal: hPad, vertical: vPad);

// ── Section spacing ───────────────────────────────────────────────────────
double get sectionGap => screenHeight * 0.014;
double get innerGapSm => screenHeight * 0.007;
double get innerGapMd => screenHeight * 0.012;

// ── Typography scaling ────────────────────────────────────────────────────
double get titleFontSize => screenHeight * 0.020;
double get bodyFontSize => screenHeight * 0.014;
double get labelFontSize => screenHeight * 0.012;

// ── Summary card specifics ────────────────────────────────────────────────
double get statValueFontSize => screenHeight * 0.022;
double get statLabelFontSize => screenHeight * 0.012;
double get statPillHPad => screenWidth * 0.03;
double get statPillVPad => screenHeight * 0.007;

// ── Decorative circle ─────────────────────────────────────────────────────
double get decorCircleSize => screenWidth * 0.32;

// ── Card & button heights ─────────────────────────────────────────────────
double get buttonHeightSm => screenHeight * 0.040;
double get productImageLg => screenWidth * 0.14;
double get productImageSm => screenWidth * 0.12;

// ── Icon sizes ────────────────────────────────────────────────────────────
double get iconSm => screenWidth * 0.035;
}

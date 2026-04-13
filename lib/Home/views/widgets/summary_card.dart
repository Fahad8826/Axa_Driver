import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/utils/app_layout.dart';
import '../../../core/theme/apptheme.dart';
import '../../model/home_model.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.summary});

  final TodaySummaryModel? summary;

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout.of(context);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Stack(
        children: [
          // ── Decorative circle ────────────────────────────────────────────
          Positioned(
            right: -layout.decorCircleSize * 0.22,
            top: -layout.decorCircleSize * 0.22,
            child: Container(
              width: layout.decorCircleSize,
              height: layout.decorCircleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),

          // ── Dot pattern ──────────────────────────────────────────────────
          Positioned.fill(child: CustomPaint(painter: _DotPatternPainter())),

          // ── Content ──────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              layout.hPad,
              layout.innerGapMd,
              layout.hPad,
              layout.innerGapMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "Today's Summary",
                  style: GoogleFonts.poppins(
                    fontSize: layout.titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),

                SizedBox(height: layout.innerGapMd),

                // Stat pills — each takes equal width via Expanded
                Row(
                  children: [
                    Expanded(
                      child: _StatPill(
                        value: summary?.totalAssigned.toString() ?? '0',
                        label: 'Assigned',
                        layout: layout,
                      ),
                    ),
                    SizedBox(width: layout.hPad * 0.4),
                    Expanded(
                      child: _StatPill(
                        value: summary?.completed.toString() ?? '0',
                        label: 'Completed',
                        layout: layout,
                      ),
                    ),
                    SizedBox(width: layout.hPad * 0.4),
                    Expanded(
                      child: _StatPill(
                        value: summary?.pending.toString() ?? '0',
                        label: 'Pending',
                        layout: layout,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STAT PILL
// ─────────────────────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.value,
    required this.label,
    required this.layout,
  });

  final String value;
  final String label;
  final AppLayout layout;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // White pill — only the number inside
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: layout.statPillVPad),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: layout.statValueFontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              height: 1.1,
            ),
          ),
        ),

        // Label sits below the pill on the blue background
        SizedBox(height: layout.innerGapMd * 0.5),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: layout.statLabelFontSize,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DOT PATTERN PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    const spacing = 18.0;
    const radius = 1.8;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:axa_driver/core/theme/apptheme.dart';
import 'package:axa_driver/scanner/controller/scanner_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerView extends StatelessWidget {
  const ScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ScannerController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Torch
          IconButton(
            icon: const Icon(Icons.flashlight_on_rounded, color: Colors.white),
            onPressed: () => ctrl.cameraController.toggleTorch(),
          ),
          // Flip
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
            onPressed: () => ctrl.cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Full screen camera feed ────────────────────────────────────
          MobileScanner(
            controller: ctrl.cameraController,
            onDetect: ctrl.onDetect,
          ),

          // ── Dark overlay + bracket frame ───────────────────────────────
          _ScanOverlay(),

          // ── Hint text ─────────────────────────────────────────────────
          Obx(() => ctrl.isProcessing.value
              ? const SizedBox.shrink()
              : const Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Point camera at the QR code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )),

          // ── Error banner ───────────────────────────────────────────────
          Obx(() {
            if (ctrl.error.value.isEmpty) return const SizedBox.shrink();
            return Positioned(
              bottom: 48,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.statusCancelled,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ctrl.error.value,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13),
                      ),
                    ),
                    GestureDetector(
                      onTap: ctrl.retryScanner,
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // ── Processing overlay ─────────────────────────────────────────
          Obx(() {
            if (!ctrl.isProcessing.value) return const SizedBox.shrink();
            return Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Verifying...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Please wait',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Dark overlay with transparent scan window + blue bracket corners
// ─────────────────────────────────────────────────────────────────────────────
class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const boxSize = 240.0;
      final cx = constraints.maxWidth / 2;
      final cy = constraints.maxHeight / 2;
      final left = cx - boxSize / 2;
      final top = cy - boxSize / 2;

      return Stack(
        children: [
          // Top dim
          Positioned(
            top: 0, left: 0, right: 0, height: top,
            child: _dim(),
          ),
          // Bottom dim
          Positioned(
            top: top + boxSize, left: 0, right: 0, bottom: 0,
            child: _dim(),
          ),
          // Left dim
          Positioned(
            top: top, left: 0, width: left, height: boxSize,
            child: _dim(),
          ),
          // Right dim
          Positioned(
            top: top, left: left + boxSize, right: 0, height: boxSize,
            child: _dim(),
          ),

          // Blue bracket corners
          Positioned(
            left: left,
            top: top,
            width: boxSize,
            height: boxSize,
            child: Stack(children: [
              _BracketCorner(alignment: Alignment.topLeft),
              _BracketCorner(alignment: Alignment.topRight),
              _BracketCorner(alignment: Alignment.bottomLeft),
              _BracketCorner(alignment: Alignment.bottomRight),
            ]),
          ),
        ],
      );
    });
  }

  Widget _dim() => Container(color: Colors.black.withOpacity(0.6));
}

// ─────────────────────────────────────────────────────────────────────────────
//  Blue bracket corner painter
// ─────────────────────────────────────────────────────────────────────────────
class _BracketCorner extends StatelessWidget {
  const _BracketCorner({required this.alignment});
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment == Alignment.topLeft ||
        alignment == Alignment.topRight;
    final isLeft = alignment == Alignment.topLeft ||
        alignment == Alignment.bottomLeft;

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: 36,
        height: 36,
        child: CustomPaint(
          painter: _BracketPainter(isTop: isTop, isLeft: isLeft),
        ),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  const _BracketPainter({required this.isTop, required this.isLeft});
  final bool isTop;
  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;
    final dx = isLeft ? size.width * 0.75 : -size.width * 0.75;
    final dy = isTop ? size.height * 0.75 : -size.height * 0.75;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_BracketPainter old) => false;
}
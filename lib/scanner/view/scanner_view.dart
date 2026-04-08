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
        title: const Text('Scan QR Code'),
        elevation: 0,
        actions: [
          // Torch toggle
          IconButton(
            icon: const Icon(Icons.flashlight_on_rounded),
            onPressed: () => ctrl.cameraController.toggleTorch(),
          ),
          // Flip camera
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded),
            onPressed: () => ctrl.cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Camera feed ──────────────────────────────────────────────────
          MobileScanner(
            controller: ctrl.cameraController,
            onDetect: ctrl.onDetect,
          ),

          // ── Scan frame overlay ───────────────────────────────────────────
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Corner accents
                  _Corner(alignment: Alignment.topLeft),
                  _Corner(alignment: Alignment.topRight),
                  _Corner(alignment: Alignment.bottomLeft),
                  _Corner(alignment: Alignment.bottomRight),
                ],
              ),
            ),
          ),

          // ── Hint text ────────────────────────────────────────────────────
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: const Text(
              'Point camera at the QR code',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),

          // ── Processing overlay ───────────────────────────────────────────
          Obx(() {
            if (ctrl.isProcessing.value) {
              return Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Verifying...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // ── Error snackbar-style banner ───────────────────────────────────
          Obx(() {
            if (ctrl.error.value.isEmpty) return const SizedBox.shrink();
            return Positioned(
              bottom: 60,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ctrl.error.value,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    GestureDetector(
                      onTap: ctrl.retryScanner,
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
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

// ── Corner accent widget ───────────────────────────────────────────────────
class _Corner extends StatelessWidget {
  const _Corner({required this.alignment});
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: 28,
        height: 28,
        child: CustomPaint(
          painter: _CornerPainter(isTop: isTop, isLeft: isLeft),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({required this.isTop, required this.isLeft});
  final bool isTop;
  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;
    final dx = isLeft ? size.width : -size.width;
    final dy = isTop ? size.height : -size.height;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) => false;
}
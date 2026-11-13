import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/theme.dart';
import '../core/utils.dart';

/// Skrin kamera imbas QR. Memulangkan teks QR melalui context.pop(text).
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handled = false;
  bool _torch = false;
  DateTime _lastWarning = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      if (raw == null || raw.trim().isEmpty) continue;
      if (extractVerificationKey(raw) == null) {
        // QR bukan kod HAFA (cth. URL biasa) — beri amaran, teruskan mengimbas
        if (DateTime.now().difference(_lastWarning).inSeconds >= 3) {
          _lastWarning = DateTime.now();
          showMsg(context, 'This QR code is not a HAFA code.');
        }
        continue;
      }
      _handled = true;
      HapticFeedback.mediumImpact();
      context.pop(raw);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(fit: StackFit.expand, children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
          errorBuilder: (context, error, child) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.no_photography_rounded, color: Colors.white70, size: 56),
                const SizedBox(height: 14),
                const Text('Camera unavailable', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                  'Allow camera access for HAFA in Android Settings > Apps > HAFA > Permissions, then try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
              ]),
            ),
          ),
        ),
        const IgnorePointer(child: CustomPaint(painter: _ScanOverlayPainter())),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              _roundButton(Icons.close_rounded, () => context.pop()),
              const Spacer(),
              _roundButton(_torch ? Icons.flash_on_rounded : Icons.flash_off_rounded, () {
                _controller.toggleTorch();
                setState(() => _torch = !_torch);
              }),
            ]),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 56,
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Scan HAFA QR Code', style: heading(22, color: Colors.white)),
              const SizedBox(height: 6),
              Text('Align the product QR code inside the frame',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.white.o(0.85), fontSize: 14)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) => Material(
        color: Colors.black.o(0.45),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(12), child: Icon(icon, color: Colors.white, size: 24)),
        ),
      );
}

class _ScanOverlayPainter extends CustomPainter {
  const _ScanOverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.width * 0.68;
    final rect = Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.42), width: side, height: side);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(22));

    final overlay = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRRect(rrect),
    );
    canvas.drawPath(overlay, Paint()..color = Colors.black.o(0.55));

    // Sudut emas
    final corner = Paint()
      ..color = HC.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const len = 34.0;
    final l = rect.left, t = rect.top, r = rect.right, b = rect.bottom;
    canvas.drawPath(Path()..moveTo(l, t + len)..lineTo(l, t + 14)..quadraticBezierTo(l, t, l + 14, t)..lineTo(l + len, t), corner);
    canvas.drawPath(Path()..moveTo(r - len, t)..lineTo(r - 14, t)..quadraticBezierTo(r, t, r, t + 14)..lineTo(r, t + len), corner);
    canvas.drawPath(Path()..moveTo(l, b - len)..lineTo(l, b - 14)..quadraticBezierTo(l, b, l + 14, b)..lineTo(l + len, b), corner);
    canvas.drawPath(Path()..moveTo(r - len, b)..lineTo(r - 14, b)..quadraticBezierTo(r, b, r, b - 14)..lineTo(r, b - len), corner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

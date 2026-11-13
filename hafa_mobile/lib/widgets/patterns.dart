import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Corak songket. Mesti diletakkan dalam [Stack] (guna Positioned.fill secara dalaman).
class SongketPattern extends StatelessWidget {
  const SongketPattern({super.key, this.opacity = 0.05});
  final double opacity;

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: IgnorePointer(
          child: RepaintBoundary(child: CustomPaint(painter: _SongketPainter(opacity))),
        ),
      );
}

class _SongketPainter extends CustomPainter {
  _SongketPainter(this.opacity);
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HC.gold.o(opacity)
      ..style = PaintingStyle.fill;
    const tile = 80.0;
    final shape = Path()
      ..moveTo(40, 0)
      ..lineTo(60, 20)
      ..lineTo(40, 40)
      ..lineTo(20, 20)
      ..close()
      ..moveTo(40, 40)
      ..lineTo(60, 60)
      ..lineTo(40, 80)
      ..lineTo(20, 60)
      ..close()
      ..addOval(Rect.fromCircle(center: const Offset(40, 40), radius: 3))
      ..addOval(Rect.fromCircle(center: const Offset(0, 0), radius: 2))
      ..addOval(Rect.fromCircle(center: const Offset(80, 0), radius: 2))
      ..addOval(Rect.fromCircle(center: const Offset(0, 80), radius: 2))
      ..addOval(Rect.fromCircle(center: const Offset(80, 80), radius: 2));
    for (double y = 0; y < size.height; y += tile) {
      for (double x = 0; x < size.width; x += tile) {
        canvas.save();
        canvas.translate(x, y);
        canvas.drawPath(shape, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_SongketPainter old) => old.opacity != opacity;
}

/// Corak geometri Islam (garis heksagon).
class IslamicPattern extends StatelessWidget {
  const IslamicPattern({super.key, this.opacity = 0.05});
  final double opacity;

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: IgnorePointer(
          child: RepaintBoundary(child: CustomPaint(painter: _IslamicPainter(opacity))),
        ),
      );
}

class _IslamicPainter extends CustomPainter {
  _IslamicPainter(this.opacity);
  final double opacity;

  Path _hexagon(List<Offset> pts) {
    final p = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final o in pts.skip(1)) {
      p.lineTo(o.dx, o.dy);
    }
    return p..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HC.gold.o((opacity * 6).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    const tile = 60.0;
    final outer = _hexagon(const [Offset(30, 5), Offset(50, 20), Offset(50, 40), Offset(30, 55), Offset(10, 40), Offset(10, 20)]);
    final inner = _hexagon(const [Offset(30, 15), Offset(42, 22), Offset(42, 38), Offset(30, 45), Offset(18, 38), Offset(18, 22)]);
    for (double y = 0; y < size.height; y += tile) {
      for (double x = 0; x < size.width; x += tile) {
        canvas.save();
        canvas.translate(x, y);
        canvas.drawPath(outer, paint);
        canvas.drawPath(inner, paint);
        canvas.drawCircle(const Offset(30, 30), 5, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_IslamicPainter old) => old.opacity != opacity;
}

/// Pembahagi hiasan bertanda bintang.
class HeritageDivider extends StatelessWidget {
  const HeritageDivider({super.key, this.margin = const EdgeInsets.symmetric(vertical: 20)});
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(height: 1, color: HC.gold.o(0.5)),
    );
    return Padding(
      padding: margin,
      child: Row(children: [
        line,
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.star_rounded, size: 18, color: HC.gold),
        ),
        line,
      ]),
    );
  }
}

/// Kepala bergradien hijau dengan corak songket.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.child,
    this.patternOpacity = 0.08,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 28),
    this.rounded = true,
  });

  final Widget child;
  final double patternOpacity;
  final EdgeInsets padding;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: HC.gradient,
        borderRadius: rounded ? const BorderRadius.vertical(bottom: Radius.circular(28)) : null,
      ),
      child: ClipRRect(
        borderRadius: rounded ? const BorderRadius.vertical(bottom: Radius.circular(28)) : BorderRadius.zero,
        child: Stack(children: [
          SongketPattern(opacity: patternOpacity),
          Padding(padding: padding, child: SizedBox(width: double.infinity, child: child)),
        ]),
      ),
    );
  }
}

/// Latar skrin penuh bergradien (onboarding).
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child, this.songket = 0.06, this.islamic = 0});
  final Widget child;
  final double songket;
  final double islamic;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: HC.gradient),
      child: Stack(children: [
        SongketPattern(opacity: songket),
        if (islamic > 0) IslamicPattern(opacity: islamic),
        Positioned.fill(child: child),
      ]),
    );
  }
}

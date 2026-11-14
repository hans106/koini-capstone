import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/koini_theme.dart';

class GoalProgress extends StatelessWidget {
  const GoalProgress(this.progress, {super.key, this.color = KColors.gold});
  final double progress;
  final Color color;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: LinearProgressIndicator(
      value: progress,
      minHeight: 9,
      color: color,
      backgroundColor: KColors.field,
    ),
  );
}

class Constellation extends StatelessWidget {
  const Constellation(this.progress, {super.key});
  final double progress;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Rasi impian ${(progress * 100).round()}%',
    child: SizedBox(
      width: double.infinity,
      height: 54,
      child: CustomPaint(painter: _ConstellationPainter(progress)),
    ),
  );
}

class _ConstellationPainter extends CustomPainter {
  const _ConstellationPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const heights = [.77, .32, .67, .42, .30, .58, .18, .52, .30, .78];
    final points = [
      for (var i = 0; i < heights.length; i++)
        Offset(11 + (size.width - 22) * i / 9, size.height * heights[i]),
    ];
    final count = (progress * 10).floor();
    for (var i = 1; i < points.length; i++) {
      final paint = Paint()
        ..color = i < count ? KColors.gold : KColors.soft.withValues(alpha: .55)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2;
      if (i < count) {
        canvas.drawLine(points[i - 1], points[i], paint);
      } else {
        for (var part = 0; part < 6; part += 2) {
          canvas.drawLine(
            Offset.lerp(points[i - 1], points[i], part / 6)!,
            Offset.lerp(points[i - 1], points[i], (part + 1) / 6)!,
            paint,
          );
        }
      }
    }
    for (var i = 0; i < points.length; i++) {
      final outlined = i == count || (i == 9 && count < 10);
      final radius = outlined ? 11.5 : 10.0;
      final star = Path();
      for (var vertex = 0; vertex < 10; vertex++) {
        final angle = vertex * math.pi / 5 - math.pi / 2;
        final length = vertex.isEven ? radius : radius * .48;
        final point =
            points[i] + Offset(math.cos(angle), math.sin(angle)) * length;
        if (vertex == 0) {
          star.moveTo(point.dx, point.dy);
        } else {
          star.lineTo(point.dx, point.dy);
        }
      }
      star.close();
      canvas.drawPath(
        star,
        Paint()
          ..color = i <= count || i == 9 ? KColors.gold : KColors.line
          ..style = outlined ? PaintingStyle.stroke : PaintingStyle.fill
          ..strokeWidth = 1.6
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ConstellationPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

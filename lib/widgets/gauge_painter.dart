import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/stitch_theme.dart';

class GaugePainter extends CustomPainter {
  final double value; // 0 to 120 dB
  final double maxValue;

  GaugePainter({required this.value, this.maxValue = 120});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    
    // 1. Draw Segments
    final segmentRect = Rect.fromCircle(center: center, radius: radius);
    final innerRadius = radius * 0.6;
    
    void drawSegment(double startAngle, double sweepAngle, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      final path = Path()
        ..moveTo(center.dx + innerRadius * cos(startAngle), center.dy + innerRadius * sin(startAngle))
        ..arcTo(segmentRect, startAngle, sweepAngle, false)
        ..lineTo(center.dx + innerRadius * cos(startAngle + sweepAngle), center.dy + innerRadius * sin(startAngle + sweepAngle))
        ..arcTo(Rect.fromCircle(center: center, radius: innerRadius), startAngle + sweepAngle, -sweepAngle, false)
        ..close();
      
      canvas.drawPath(path, paint);
    }

    // Segments mapping from HTML (adapted to Pi)
    // Conic gradient 0-180deg mapped to -Pi to 0
    final double radScale = pi / 180;
    
    // Using simple equal segments for categories or following HTML logic
    final segments = [
      {'start': 0.0, 'end': 51.0, 'color': StitchColors.silent},
      {'start': 52.0, 'end': 77.0, 'color': StitchColors.moderate},
      {'start': 78.0, 'end': 102.0, 'color': StitchColors.noisy},
      {'start': 103.0, 'end': 128.0, 'color': StitchColors.danger},
      {'start': 129.0, 'end': 180.0, 'color': StitchColors.damage},
    ];

    for (final seg in segments) {
      final start = (seg['start'] as double) * radScale - pi;
      final end = (seg['end'] as double) * radScale - pi;
      drawSegment(start, end - start, (seg['color'] as Color));
      
      // Draw white tick/separator
      final separatorPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      canvas.drawLine(
        Offset(center.dx + innerRadius * cos(end), center.dy + innerRadius * sin(end)),
        Offset(center.dx + radius * cos(end), center.dy + radius * sin(end)),
        separatorPaint,
      );
    }

    // 2. Draw Needle
    // needleAngle mapping: 0 -> -Pi, 120 -> 0
    final needleAngle = ((value / maxValue) * pi) - pi;
    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final needleLength = radius * 0.85;
    final needleEnd = Offset(
      center.dx + needleLength * cos(needleAngle),
      center.dy + needleLength * sin(needleAngle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);

    // 3. Center Cap
    final capPaint = Paint()..color = Colors.black;
    canvas.drawCircle(center, 12, capPaint);
    
    final capBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 12, capBorderPaint);

    // Shadow for cap
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 14, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

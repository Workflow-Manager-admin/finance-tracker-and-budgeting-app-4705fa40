import 'dart:math';
import 'package:flutter/material.dart';

/// PUBLIC_INTERFACE
/// Draws a stylized pie chart for category analytics.
class SpendingPieChart extends StatelessWidget {
  final Map<String, double> categoryData;
  final List<Color>? colorPalette;

  const SpendingPieChart({super.key, required this.categoryData, this.colorPalette});

  @override
  Widget build(BuildContext context) {
    final keys = categoryData.keys.toList();
    final values = categoryData.values;
    final total = values.fold<double>(0.0, (a, b) => a + b);

    final List<Color> colors = colorPalette ??
        [
          Colors.pinkAccent,
          Colors.cyanAccent,
          Colors.deepPurpleAccent,
          Colors.tealAccent,
          Colors.orangeAccent,
          Colors.lightGreenAccent,
          Colors.blueGrey,
        ];

    return Column(
      children: [
        SizedBox(
          height: 180,
          width: 180,
          child: CustomPaint(
            painter: _PieChartPainter(
              values: values.map((val) => val / (total == 0 ? 1 : total)).toList(),
              colors: colors,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (int i = 0; i < keys.length; i++)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 14, height: 14, color: colors[i % colors.length]),
                const SizedBox(width: 6),
                Text(
                  keys[i],
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
                ),
              ]),
          ],
        )
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    double startAngle = -pi / 2;
    final paint = Paint()
      ..style = PaintingStyle.fill;
    for (int i = 0; i < values.length; ++i) {
      final sweep = values[i] * 2 * pi;
      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCenter(center: Offset(size.width/2, size.height/2), width: size.width, height: size.height),
        startAngle,
        sweep,
        true,
        paint,
      );
      startAngle += sweep;
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

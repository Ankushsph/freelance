import 'package:flutter/material.dart';

class AnalyticsChart extends StatelessWidget {
  final List<double> currentData;
  final List<double> previousData;

  const AnalyticsChart({
    Key? key,
    required this.currentData,
    required this.previousData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ChartPainter(
        currentData: currentData,
        previousData: previousData,
      ),
      child: Container(),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> currentData;
  final List<double> previousData;

  ChartPainter({
    required this.currentData,
    required this.previousData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (currentData.isEmpty || previousData.isEmpty) return;

    // Find max value for scaling
    final allData = [...currentData, ...previousData];
    final maxValue = allData.reduce((a, b) => a > b ? a : b);
    final minValue = allData.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    final safeRange = range == 0 ? 1 : range;

    // Draw grid lines
    _drawGridLines(canvas, size);

    // Draw previous period line (gray)
    _drawLine(
      canvas,
      size,
      previousData,
      Colors.grey.shade400,
      minValue,
      safeRange,
    );

    // Draw current period line (purple)
    _drawLine(
      canvas,
      size,
      currentData,
      const Color(0xFF6B4CE6),
      minValue,
      safeRange,
    );
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Vertical lines
    for (int i = 0; i <= 6; i++) {
      final x = (size.width / 6) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double> data,
    Color color,
    double minValue,
    double range,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedValue = (data[i] - minValue) / range;
      final y = size.height - (normalizedValue * size.height * 0.8) - (size.height * 0.1);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()..color = color;
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedValue = (data[i] - minValue) / range;
      final y = size.height - (normalizedValue * size.height * 0.8) - (size.height * 0.1);
      
      // Outer dot
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      // Inner white dot
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

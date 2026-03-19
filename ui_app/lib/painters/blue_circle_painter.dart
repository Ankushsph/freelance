import 'package:flutter/material.dart';

/// Custom painter for rendering the expanding blue circle overlay animation
class BlueCirclePainter extends CustomPainter {
  final double radius;
  final Offset center;
  final double opacity;

  const BlueCirclePainter({
    required this.radius,
    required this.center,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(BlueCirclePainter oldDelegate) {
    return radius != oldDelegate.radius || opacity != oldDelegate.opacity;
  }
}

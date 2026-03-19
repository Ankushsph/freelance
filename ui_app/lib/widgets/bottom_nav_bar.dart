import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../painters/blue_circle_painter.dart';

const double kBottomNavHeight = 105;

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTap;
  final bool visible;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
    required this.visible,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with TickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _positionAnimation;

  // Blue circle animation state
  late AnimationController _blueCircleController;
  late Animation<double> _circleRadiusAnimation;
  late Animation<double> _circleFadeAnimation;
  OverlayEntry? _blueCircleOverlay;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000), // Rocket animation duration
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.3).animate( // Shrink rocket
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _positionAnimation = Tween<double>(begin: 0.0, end: -200.0).animate( // Move rocket forward more
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
      }
    });

    // Initialize blue circle animation controller
    _blueCircleController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Reduced to 2 seconds
      vsync: this,
    );

    // Animation for circle radius expansion
    _circleRadiusAnimation = Tween<double>(
      begin: 0.0, // Start from zero (rocket tip)
      end: 0.0, // Will be calculated dynamically based on screen size
    ).animate(
      CurvedAnimation(
        parent: _blueCircleController,
        curve: Curves.easeInOut,
      ),
    );

    // Animation for fade-out effect
    _circleFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _blueCircleController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOut), // Last 300ms of animation
      ),
    );

    // Add listener for blue circle animation completion
    _blueCircleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Remove overlay and show dialog
        _removeBlueCircleOverlay();
        if (mounted) {
          widget.onItemTap(2);
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _blueCircleController.dispose();
    _removeBlueCircleOverlay();
    super.dispose();
  }

  void _onBoostTap() {
    // Prevent multiple animations
    if (_blueCircleController.isAnimating) {
      return;
    }

    HapticFeedback.mediumImpact();
    
    // Start rocket button animation
    _animationController.forward();
    
    // Create and insert blue circle overlay
    _blueCircleOverlay = _createBlueCircleOverlay();
    Overlay.of(context).insert(_blueCircleOverlay!);
    
    // Start blue circle animation
    _blueCircleController.forward(from: 0.0);
  }

  /// Calculate the center position of the rocket tip (top of rocket)
  Offset _getRocketButtonCenter() {
    final screenSize = MediaQuery.of(context).size;
    final x = screenSize.width / 2;
    final y = screenSize.height - kBottomNavHeight - 35; // Rocket tip position
    return Offset(x, y);
  }

  /// Calculate maximum radius needed to cover entire screen from center point
  double _calculateMaxRadius(Size screenSize, Offset center) {
    final corners = [
      const Offset(0, 0),
      Offset(screenSize.width, 0),
      Offset(0, screenSize.height),
      Offset(screenSize.width, screenSize.height),
    ];

    return corners
        .map((corner) => (corner - center).distance)
        .reduce(math.max);
  }

  /// Create overlay entry for blue circle animation
  OverlayEntry _createBlueCircleOverlay() {
    final screenSize = MediaQuery.of(context).size;
    final center = _getRocketButtonCenter();
    final maxRadius = _calculateMaxRadius(screenSize, center);

    // Update the radius animation end value
    _circleRadiusAnimation = Tween<double>(
      begin: 0.0, // Start from rocket tip
      end: maxRadius,
    ).animate(
      CurvedAnimation(
        parent: _blueCircleController,
        curve: Curves.easeInOut,
      ),
    );

    return OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: _blueCircleController,
        builder: (context, child) {
          return Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: BlueCirclePainter(
                  radius: _circleRadiusAnimation.value,
                  center: center,
                  opacity: _circleFadeAnimation.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Remove blue circle overlay
  void _removeBlueCircleOverlay() {
    _blueCircleOverlay?.remove();
    _blueCircleOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: widget.visible ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: widget.visible ? 1 : 0,
        child: SizedBox(
          height: kBottomNavHeight,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              /// Background with curve
              CustomPaint(
                size: Size(width, 85),
                painter: _CurvePainter(),
              ),

              /// Rocket Button
              Positioned(
                top: 0,
                child: GestureDetector(
                  onTap: _onBoostTap,
                  onTapDown: (_) {
                    HapticFeedback.selectionClick();
                    setState(() => _isPressed = true);
                  },
                  onTapUp: (_) {
                    setState(() => _isPressed = false);
                  },
                  onTapCancel: () {
                    setState(() => _isPressed = false);
                  },
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _positionAnimation.value),
                        child: Transform.scale(
                          scale: _scaleAnimation.value * (_isPressed ? 0.92 : 1.0),
                          child: Opacity(
                            opacity: _animationController.value < 0.7 ? 1.0 : (1.0 - ((_animationController.value - 0.7) / 0.3)), // Fade out rocket in last 30% of animation
                            child: _rocketButton(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              /// Items
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _item(0, Icons.calendar_month, "Schedule"),
                      _item(1, Icons.local_fire_department, "Trend"),
                      const SizedBox(width: 64),
                      _item(3, Icons.bar_chart_rounded, "Analytics"),
                      _item(4, Icons.smart_toy_outlined, "AI"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rocketButton() {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff6366F1),
            Color(0xff3B82F6),
            Color(0xff06B6D4),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.rocket,
            size: 28,
            color: Color(0xff6366F1),
          ),
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, String text) {
    final active = widget.selectedIndex == index;
    final color = const Color(0xff6366F1);
    final isPremium = index == 1 || index == 3 || index == 4;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onItemTap(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 26,
                color: color,
              ),
              if (isPremium)
                const Positioned(
                  top: -5,
                  right: -8,
                  child: Icon(Icons.star, color: Colors.orange, size: 12),
                )
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Curve Painter - Smooth curve with notch for rocket
class _CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final notchRadius = 45.0;
    final notchDepth = 5.0;

    path.moveTo(0, 15);
    path.lineTo(w / 2 - notchRadius, 15);


    path.quadraticBezierTo(
      w / 2 - notchRadius + 10, 15,
      w / 2 - notchRadius + 15, notchDepth,
    );


    path.arcTo(
      Rect.fromCircle(
        center: Offset(w / 2, notchDepth),
        radius: notchRadius - 15,
      ),
      math.pi,
      -math.pi,
      false,
    );


    path.quadraticBezierTo(
      w / 2 + notchRadius - 10, 15,
      w / 2 + notchRadius, 15,
    );

    path.lineTo(w, 15);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
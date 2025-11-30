import 'package:flutter/material.dart';

class CampusGuardianLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final Color iconColor;

  const CampusGuardianLogo({
    super.key,
    this.size = 150.0,
    this.color, // Defaults to primary blue
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // Default blue if not provided
    final shieldColor = color ?? const Color(0xFF1976D2);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. The Shield Shape
          CustomPaint(
            size: Size(size, size),
            painter: _ShieldPainter(color: shieldColor),
          ),
          // 2. The Icon (Graduation Cap)
          Positioned(
            top: size * 0.25, // Adjust vertical position
            child: Icon(
              Icons.school_rounded,
              size: size * 0.5,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw a perfect Shield shape
class _ShieldPainter extends CustomPainter {
  final Color color;

  _ShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Logic to draw a shield:
    // Start top left, go right, go down, curve to bottom center, curve up to left.
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h * 0.1); // Start slightly down from top-left
    path.lineTo(w, h * 0.1); // Top line to right
    path.lineTo(w, h * 0.5); // Right side down to middle

    // The curve to the bottom tip
    path.quadraticBezierTo(
      w, h * 0.8, // Control point
      w * 0.5, h, // End point (Bottom tip)
    );

    // The curve back up to the left side
    path.quadraticBezierTo(
      0, h * 0.8, // Control point
      0, h * 0.5, // End point (Left middle)
    );

    path.close();

    // Add a subtle shadow for depth
    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 4.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
import 'dart:ui';

import 'package:flutter/material.dart';

class CustomDottedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final Radius radius;

  const CustomDottedBorder(
      {super.key,
      required this.child,
      required this.color,
      required this.radius});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(color: color, radius: radius),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final Radius radius;

  _DottedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double dashWidth = 16;
    double dashSpace = 8;

    Path path = Path()
      ..moveTo(radius.x, 0)
      ..lineTo(size.width - radius.x, 0)
      ..arcToPoint(Offset(size.width, radius.y), radius: radius)
      ..lineTo(size.width, size.height - radius.y)
      ..arcToPoint(Offset(size.width - radius.x, size.height), radius: radius)
      ..lineTo(radius.x, size.height)
      ..arcToPoint(Offset(0, size.height - radius.y), radius: radius)
      ..lineTo(0, radius.y)
      ..arcToPoint(Offset(radius.x, 0), radius: radius);

    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        pathMetric.getTangentForOffset(distance)?.position;
        canvas.drawPath(
            pathMetric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

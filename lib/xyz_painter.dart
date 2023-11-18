import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:point_cloud/interface/vector.dart';

class XyzPainter extends CustomPainter {
  final List<Offset> points;
  final double scale;
  final Offset translate;
  final Vector centerXYZ;
  final List<Offset> translatePoint;
  final double highestY;
  final double bottomLine;
  final double topLine;
  final double centerLine;
  XyzPainter(
      this.points,
      this.scale,
      this.translate,
      this.centerXYZ,
      this.translatePoint,
      this.highestY,
      this.bottomLine,
      this.topLine,
      this.centerLine);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;
    canvas.drawRect(
        const Rect.fromLTWH(0, 0, double.infinity, double.infinity), paint);
    if (scale > 1.0) {
      canvas.scale(scale);
    }
    paint.color = Colors.blue;
    paint.strokeWidth = 1.0;

    Offset startBottomLine = Offset(0, bottomLine);
    Offset endBottomLine = Offset(size.width, bottomLine);
    Offset startingPointTopLine = Offset(0, topLine);
    Offset endPointTopLine = Offset(size.width, topLine);

    if (translatePoint.length == 2) {
      final paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 1.0;
      canvas.drawLine(translatePoint[0], translatePoint[1], paint);
    }

    paint.color = Colors.red;
    paint.strokeWidth = 1;
    canvas.drawLine(startBottomLine, endBottomLine, paint);

    paint.color = Colors.red;
    paint.strokeWidth = 1;
    canvas.drawLine(startingPointTopLine, endPointTopLine, paint);

    paint.color = Colors.green.withOpacity(0.5);
    paint.strokeWidth = 1;

    Offset greenLineStartPoint = Offset(0, centerLine);
    Offset greenLineEndPoint = Offset(size.width, centerLine);

    canvas.drawLine(greenLineStartPoint, greenLineEndPoint, paint);

    paint.color = Colors.blue;
    paint.strokeWidth = 1;
    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(XyzPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.scale != scale ||
        oldDelegate.translate != translate;
  }

  @override
  bool hitTest(Offset position) => true;
}

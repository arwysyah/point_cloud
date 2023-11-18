import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:point_cloud/interface/vector.dart';
import 'package:point_cloud/utils/painter_constant.dart';

class XyzPainter2 extends CustomPainter {
  final List<Vector> points;
  final double scale;
  final Offset translate;
  final Vector centerXYZ;
  final List<Offset> translatePoint;
  final double targetZ;
  final maxZ = double.infinity;
  final bool isLineExist;
  final double opacity;

  Offset center;
  List<Offset> clickedPoints;
  double angle;
  int initialScale = 15;

  XyzPainter2(
      this.points,
      this.scale,
      this.translate,
      this.centerXYZ,
      this.translatePoint,
      this.targetZ,
      this.center,
      this.clickedPoints,
      this.angle,
      this.initialScale,
      this.isLineExist,
      this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    List<Offset> cuttedPlanePoints = [];

    final transformedPoints = points.map((point) {
      final pointX = -point.getDX() * initialScale;
      final pointY = -point.getDY() * initialScale;
      final transformedX = pointX * scale + translate.dx + heightOfSize / 2;

      final transformedY = yStartingPoint + pointY * scale + translate.dy;

      if (transformedY > linePosition - lineWidth &&
          transformedY < linePosition + lineWidth) {
        cuttedPlanePoints.add(Offset(transformedX, transformedY));
      }

      return Offset(transformedX, transformedY);
    }).toList();

    for (var point in clickedPoints) {
      paint.color = Colors.red;
      canvas.drawCircle(point, 1, paint);
    }

    if (clickedPoints.length > 1) {
      final startOffset = Offset(clickedPoints[0]!.dx, clickedPoints[0]!.dy);
      final middleOffset = Offset(clickedPoints[1]!.dx, clickedPoints[1]!.dy);

      canvas.drawLine(startOffset, middleOffset, paint);
    }
    if (clickedPoints.length > 2) {
      final startOffset = Offset(clickedPoints[0]!.dx, clickedPoints[0]!.dy);
      final middleOffset = Offset(clickedPoints[1]!.dx, clickedPoints[1]!.dy);
      final endOffset = Offset(clickedPoints[2]!.dx, clickedPoints[2]!.dy);
      canvas.drawLine(startOffset, middleOffset, paint);
      canvas.drawLine(middleOffset, endOffset, paint);
      canvas.drawLine(endOffset, startOffset, paint);
    }

    if (isLineExist) {
      paint.strokeWidth = 2 * scale;
      paint.color = Colors.red.withOpacity(0.4);
      paint.strokeWidth = 2;
      canvas.drawLine(p1, p2, paint);
      paint.color = Colors.blue;
      paint.strokeWidth = lineWidth * scale;
      canvas.drawPoints(PointMode.points, cuttedPlanePoints, paint);
    }
    paint.strokeWidth = 1.0;
    paint.color = Colors.grey.withOpacity(opacity);
    canvas.drawPoints(PointMode.points, transformedPoints, paint);
  }

  @override
  bool shouldRepaint(XyzPainter2 oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.scale != scale ||
        oldDelegate.translate != translate;
  }

  @override
  bool hitTest(Offset position) => true;
}

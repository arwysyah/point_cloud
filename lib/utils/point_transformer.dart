import 'package:flutter/material.dart';
import 'package:point_cloud/interface/vector.dart';
import 'package:point_cloud/utils/painter_constant.dart';
import 'xyz_variable.dart';

List<Offset> transformThePoints(
    List<Vector> arg, double yLineAxis, void setStateZ) {
  List<Vector> data = [];
  return arg.map((point) {
    final dx = point.getDX();
    final dz = point.getDZ();
    final pointY = -dz * angleZ * defaultScale * scaleAsMultiplier;
    final transformedY = yStartingPoint + pointY + centerZ * 41 + translate.dy;
    if (transformedY > yLineAxis - lineWidth &&
        transformedY < yLineAxis + lineWidth) {
      if (data.isEmpty) {
        setStateZ;
      }
    }
    return Offset(dx * scaleOfPoint + heightOfSize / 1.2, transformedY);
  }).toList();
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:point_cloud/interface/vector.dart';

Vector rotatePoint(Vector point, Offset center, double angle) {
  final double cosTheta = cos(angle);
  final double sinTheta = sin(angle);
  final translatedX = point.dx - center.dx;
  final translatedY = point.dy - center.dy;
  final rotatedX = translatedX * cosTheta - translatedY * sinTheta + center.dx;
  final rotatedY = translatedX * sinTheta + translatedY * cosTheta + center.dy;

  return Vector(rotatedX, rotatedY, point.dz);
}

List<Vector> rotateXYPoint(List<Vector> points, Offset center, double angle) {
  List<Vector> data = points;
  final resultanVector = data.map((point) {
    final double cosTheta = cos(angle);
    final double sinTheta = sin(angle);
    final translatedX = point.dx - center.dx;
    final translatedY = point.dy - center.dy;
    final rotatedX =
        translatedX * cosTheta - translatedY * sinTheta + center.dx;
    final rotatedY =
        translatedX * sinTheta + translatedY * cosTheta + center.dy;

    return Vector(rotatedX * -1, rotatedY, point.dz);
  }).toList();

  return resultanVector;
}

double calculateRotationAngle(List<Offset> clickedPoints) {
  final p1 = clickedPoints[0];
  final p2 = clickedPoints[1];
  final p3 = clickedPoints[2];
  double angle1 = atan2(p2.dy - p1.dy, p2.dx - p1.dx);
  double angle2 = atan2(p3.dy - p1.dy, p3.dx - p1.dx);
  return angle2 - angle1;
}

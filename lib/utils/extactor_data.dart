import 'package:flutter/material.dart';
import 'package:point_cloud/interface/vector.dart';
import 'package:point_cloud/utils/painter_constant.dart';

class PointCloudUtils {
  static List<Vector> extractData(
    List<Vector> data,
    double scale,
    Offset translate,
  ) {
    List<Vector> tempData = [...data];

    tempData = tempData.map((point) {
      final pointX = -point.getDX() * smallScale;
      final pointY = -point.getDY() * smallScale;
      final transformedX = pointX * scale + translate.dx + xOffest;
      final transformedY = yOffset + pointY * scale + translate.dy;

      if (transformedY > linePosition - lineWidth &&
          transformedY < linePosition + lineWidth) {
        tempData.add(Vector(point.dx, point.dy, point.dz));
      }

      return Vector(transformedX, transformedY, point.dz);
    }).toList();

    return tempData;
  }

  static List<Vector> findCuttedPoint(
    List<Vector> arg,
    double scale,
    Offset translate,
  ) {
    return arg.where((point) {
      final pointY = -point.getDY() * smallScale;
      final transformedY = yStartingPoint + pointY * scale + translate.dy;
      return transformedY > linePosition - lineWidth &&
          transformedY < linePosition + lineWidth;
    }).toList();
  }

  static List<Vector> limitTheData(
    List<Vector> data,
    double dataAddition,
    double dataSubtraction,
    double scale,
    Offset translate,
  ) {
    return data.where((point) {
      final pointY = -point.getDY() * smallScale;
      final transformedY = yStartingPoint + pointY * scale + translate.dy;
      return transformedY > linePosition + lineWidth &&
          transformedY < linePosition + lineWidth;
    }).toList();
  }
}

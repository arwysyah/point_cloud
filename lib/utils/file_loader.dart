import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:point_cloud/interface/vector.dart';
import 'package:point_cloud/interface/vector3D.dart';
import 'dart:async';
import 'package:point_cloud/utils/file_loader_interface.dart';
import 'package:point_cloud/utils/painter_constant.dart';

class FileLoader {
  List<Vector> points = [];
  FileLoader(this.points);

  Future<List<Vector>> loadFile(
      BuildContext context, double targetZCoordinate) async {
    List<Vector> tempPoints = [];
    List<XYZObject> originalTempPoints = [];

    try {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['xyz']);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Loading file...'),
        duration: Duration(minutes: 1),
      ));

      if (result == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return tempPoints;
      }

      final file = File(result.files.single.path!);
      final contents = await file.readAsString();

      final lines = contents.split('\n');
      originalTempPoints = lines.where((line) => line.isNotEmpty).map((line) {
        final parts = line.split(' ');

        double x = double.parse(parts[2]);
        double y = double.parse(parts[3]);
        double z = double.parse(parts[4]);
        int r = int.parse(parts[0]);
        int c = int.parse(parts[1]);

        return XYZObject(
          x,
          y,
          z,
          r,
          c,
        );
      }).toList();

      tempPoints = originalTempPoints.map((line) {
        double x = line.dx;
        double y = line.dy;
        double z = line.dz;

        return Vector(
          x,
          y,
          z,
        );
      }).toList();

      points = tempPoints;
      originalPoints = originalTempPoints;

      highestZAxis = _getHighestZPoint(tempPoints);
      lowestZAxis = _getLowestZPoint(tempPoints);

      centerXAxis = _getCenterX(tempPoints);
      centerYAxis = _getCenterY(tempPoints);
      centerZAxis = _getCenterZ(tempPoints);
      highestYAxis = _getHighestY(tempPoints);
      lowestYAxis = _getLowestY(tempPoints);
      listOfCutPoint = findCuttedPoint(tempPoints, 1.0, Offset.zero);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('File loaded successfully.'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error loading file.'),
        duration: Duration(seconds: 2),
      ));
    }

    return tempPoints;
  }

  List<Vector> get point => points;
  List<XYZObject> get originalPointCloud => originalPoints;
  List<Vector> get newPoint => listOfCutPoint;
  double get highestZCoord => highestZAxis;
  double get lowestZCoord => lowestZAxis;
  double get centerXCoord => centerXAxis;
  double get centerYCoord => centerYAxis;
  double get centerZCoord => centerZAxis;

  double get highestYCoord => highestYAxis;
  double get lowestYCoord => lowestYAxis;

  double _getHighestZPoint(List<Vector> points) {
    return points.map((point) => point.dz).reduce((a, b) => a > b ? a : b);
  }

  double _getLowestZPoint(List<Vector> points) {
    return points.map((point) => point.dz).reduce((a, b) => a < b ? a : b);
  }

  List<Vector> findCuttedPoint(
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

  double _getHighestY(List<Vector> points) {
    return points.reduce((a, b) => a.getDY() > b.getDY() ? a : b).dy;
  }

  double _getLowestY(List<Vector> points) {
    return points.reduce((a, b) => a.getDY() < b.getDY() ? a : b).dy;
  }

  double _getCenterX(List<Vector> points) {
    return points.map((point) => point.getDX()).reduce((a, b) => a + b) /
        points.length;
  }

  double _getCenterY(List<Vector> points) {
    return points.map((point) => point.getDY()).reduce((a, b) => a + b) /
        points.length;
  }

  double _getCenterZ(List<Vector> points) {
    return points.map((point) => point.getDZ()).reduce((a, b) => a + b) /
        points.length;
  }
}

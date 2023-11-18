import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:point_cloud/interface/vector.dart';
import 'package:point_cloud/interface/vector3D.dart';

class PointCloudExporter {
  BuildContext context;
  List<XYZObject> points;
  double zTargets;

  PointCloudExporter(this.context, this.points, this.zTargets);

  List<XYZObject> getClosestPoint(List<XYZObject> data, double targetZ) {

    
    final List<XYZObject> dataPoints = [...data];
    Map<int, List<XYZObject>> groupedData = {};

    for (XYZObject datum in dataPoints) {
      int key = datum.getDC();
      if (!groupedData.containsKey(key)) {
        groupedData[key] = [];
      }
      groupedData[key]!.add(datum);
    }

    List<XYZObject> closestPoints = [];

    for (List<XYZObject> group in groupedData.values) {
      XYZObject closestPoint = group[0];
      double closestDistance = (group[0].getDZ() - targetZ).abs();
      for (int i = 1; i < group.length; i++) {
        double distance = (group[i].getDZ() - targetZ).abs();
        if (distance < closestDistance) {
          closestDistance = distance;
          closestPoint = group[i];
        }
      }

      closestPoints.add(closestPoint);
    }
    return closestPoints;
  }


  Future<List<XYZObject>> findClosestPoints() {

    List<XYZObject> newPoints = getClosestPoint(points, zTargets);
    final centerX =
        newPoints.map((point) => point.getDX()).reduce((a, b) => a + b) /
            newPoints.length;
    final centerY =
        newPoints.map((point) => point.getDY()).reduce((a, b) => a + b) /
            newPoints.length;

    final centerZ =
        newPoints.map((point) => point.getDZ()).reduce((a, b) => a + b) /
            newPoints.length;
    final lastR = newPoints[newPoints.length - 1].dr;
    final lastG = newPoints[newPoints.length - 1].dc + 1;
    newPoints.add(XYZObject(centerX, centerY, centerZ, lastR, lastG));
    return Future.value(newPoints);
  }

  Future<void> exportToXYZ(List<Vector> data, BuildContext context,
      double targetZ, double limit) async {
    final entities = StringBuffer();
    for (final coord in data) {
      final x = coord.getDX();
      final y = coord.getDY();
      final z = coord.getDZ();

      entities.writeln("$x $y $z");
    }
    await exportToFile(entities.toString(), "xyz", context);
  }

  Future<void> exportToDxf(List<XYZObject> data, double limit) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Exporting ....."),
      ),
    );
    const header =
        '999\nDXF CLOUD\n0\nSECTION\n2\nHEADER\n9\n\$ACADVER\n1\nAC1006\n0\nENDSEC\n0\nSECTION\n2\nENTITIES\n';

    final entities = StringBuffer();
    const numbers = 1000;
    for (final coord in data) {
      final x = coord.getDX() * numbers;
      final y = coord.getDY() * numbers;
      final z = coord.getDZ() * numbers;

      entities.write('0\nPOINT\n8\n0\n10\n$x\n20\n$y\n30\n$z\n');
    }

    var footer = '0\nENDSEC\n0\nEOF\n';

    final dxf = header + entities.toString() + footer;
    await exportToFile(dxf, "dxf", context);
  }

  Future<void> exportToFile(
      String data, String extension, BuildContext context) async {
    String dir = Directory.current.path;

    String folderPath = '';
    String symbols = '/';

    if (Platform.isMacOS) {
      folderPath = '$dir/Documents';
      symbols = '/';
    } else {
      folderPath = dir;
      symbols = '\\';
    }
    String time =
        DateTime.now().toString().replaceAll(":", ".").replaceAll(" ", "_");
    String filename = '$folderPath${symbols}points-$time.$extension';
    final file = File(filename);

    file.createSync();
    file.writeAsStringSync(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("File saved $filename"),
      ),
    );
    log(filename);
  }
}

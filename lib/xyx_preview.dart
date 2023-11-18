import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:point_cloud/interface/vector.dart';
import 'package:point_cloud/interface/vector3D.dart';
import 'package:point_cloud/utils/exporter_plane.dart';
import 'package:point_cloud/utils/file_loader_interface.dart';
import 'package:point_cloud/utils/painter_constant.dart';
import 'package:point_cloud/utils/xyz_variable.dart';
import 'package:point_cloud/xyz_painter2.dart';

class XYZPreview extends StatefulWidget {
  final double zResult;
  final Vector centerXYZ;
  final String title;

  const XYZPreview(this.zResult, this.centerXYZ, this.title, {super.key});

  @override
  State<XYZPreview> createState() => _XYZPreviewState();
}

class _XYZPreviewState extends State<XYZPreview> {
  static const isLineExist = false;
  double itemScale = scale;
  Offset itemTranslatePosition = translate +
      Offset(heightOfSize.floorToDouble(), interval.floorToDouble());

  List<Vector> data = [];

  double targetZ = 0.0;
  Offset center = const Offset(0, 0);
  List<Offset> clickedPoints = [];
  double angle = 0.0;
  int defaultScale = 30;

  Future<List<Vector>> getPoints() async {
    final file = PointCloudExporter(context, originalPoints, zResult);
    final dataResult = await file.findClosestPoints();

    List<Vector> listOfPoints = dataResult.map((e) {
      final x = e.dx;
      final y = e.dy;
      final z = e.dz;
      return Vector(x, y, z);
    }).toList();
    setState(() {
      data = listOfPoints;
    });
    return [];
  }

  @override
  void initState() {
    super.initState();

    getPoints();
  }

  @override
  Widget build(BuildContext context) {
    final centerPoint = widget.centerXYZ;
    final titles = widget.title;
    final List<Offset> translatePoint = [];
    const strokeWidth = 1.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(titles),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Stack(
                    children: [
                      Positioned(
                          left: 0,
                          top: 0,
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                              onScaleStart: (details) {
                                previousScale = itemScale;
                                previousTranslate = itemTranslatePosition;
                                currentFocalPoint = details.focalPoint;
                              },
                              onScaleUpdate: (details) {
                                setState(() {
                                  double deltaScale = details.scale;
                                  Offset deltaTranslate =
                                      details.focalPoint - currentFocalPoint;
                                  itemScale = previousScale * deltaScale;
                                  itemTranslatePosition = previousTranslate +
                                      deltaTranslate / scale;
                                });
                              },
                              onDoubleTap: () {
                                setState(() {
                                  itemScale = 1.0;
                                  itemTranslatePosition = Offset.zero;
                                });
                              },
                              child: CustomPaint(
                                painter: XyzPainter2(
                                    data,
                                    itemScale,
                                    itemTranslatePosition,
                                    centerPoint,
                                    translatePoint,
                                    targetZ,
                                    center,
                                    clickedPoints,
                                    angle,
                                    defaultScale,
                                    isLineExist,
                                    strokeWidth),
                              )))
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
